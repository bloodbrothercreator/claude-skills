# Code templates (from ShapeUp, Next 16 + Drizzle)

These are working files copied from bloodbrothercreator/shape-up (PR #21). Adapt the names (`@/lib/db`, the `profiles` table, `isAllowed`, `requireUser`) to the target app. App-specific tool code is left out; `TOOLS` is just `{ name, description, input: zod, readOnly, run(userId, input, now) }[]`.
Contents:
- `src/lib/oauth/constants.ts`
- `src/lib/oauth/tokens.ts`
- `src/app/.well-known/oauth-protected-resource/api/mcp/route.ts`
- `src/app/.well-known/oauth-authorization-server/route.ts`
- `src/app/oauth/authorize/params.ts`
- `src/app/oauth/authorize/actions.ts`
- `src/app/oauth/authorize/page.tsx`
- `src/app/oauth/token/route.ts`
- `src/app/api/mcp/route.ts`
- `src/app/auth/sign-in/return-path.ts`
- Proxy matcher (src/proxy.ts)
- Schema (Drizzle)


## `src/lib/oauth/constants.ts`

```ts
export const OAUTH_CLIENT_ID = 'shapeup-claude';
export const OAUTH_REDIRECTS = ['https://claude.ai/api/mcp/auth_callback'];
export const OAUTH_SCOPE = 'mcp';

export const CODE_TTL_S = 60;
export const ACCESS_TTL_S = 3600;
export const REFRESH_TTL_S = 30 * 24 * 3600;

// Token endpoint answers 429 above this many oauth_tokens rows created in the last minute.
export const TOKEN_RATE_LIMIT_PER_MIN = 30;
```

## `src/lib/oauth/tokens.ts`

```ts
import 'server-only';
import { createHash, randomBytes, timingSafeEqual } from 'node:crypto';
import { and, count, desc, eq, gt, inArray, isNull, max, min, sql } from 'drizzle-orm';
import { isAllowed } from '@/lib/auth/require-user';
import { db } from '@/lib/db';
import { oauthTokens, profiles } from '@/lib/db/schema';
import { parseServerEnv } from '@/lib/env';
import { ACCESS_TTL_S, CODE_TTL_S, OAUTH_CLIENT_ID, OAUTH_SCOPE, REFRESH_TTL_S, TOKEN_RATE_LIMIT_PER_MIN } from './constants';

export type TokenPair = {
  access_token: string;
  refresh_token: string;
  token_type: 'Bearer';
  expires_in: 3600;
  scope: 'mcp';
};

export class OAuthError extends Error {
  constructor(
    public code: 'invalid_grant' | 'invalid_request' | 'invalid_client' | 'unsupported_grant_type',
    message: string = code,
  ) {
    super(message);
    this.name = 'OAuthError';
  }
}

export function hashToken(t: string): string {
  return createHash('sha256').update(t).digest('hex');
}

export function pkceMatches(verifier: string, challenge: string): boolean {
  if (verifier.length < 43 || verifier.length > 128) return false;
  const a = Buffer.from(createHash('sha256').update(verifier).digest('base64url'));
  const b = Buffer.from(challenge);
  return a.length === b.length && timingSafeEqual(a, b);
}

const secret = () => randomBytes(32).toString('base64url');
const later = (now: Date, s: number) => new Date(now.getTime() + s * 1000);

export async function issueCode(p: {
  userId: string;
  redirectUri: string;
  codeChallenge: string;
  resource: string;
}): Promise<string> {
  const code = secret();
  const now = new Date();
  await db.insert(oauthTokens).values({
    userId: p.userId,
    kind: 'code',
    tokenHash: hashToken(code),
    familyId: crypto.randomUUID(),
    clientId: OAUTH_CLIENT_ID,
    redirectUri: p.redirectUri,
    codeChallenge: p.codeChallenge,
    resource: p.resource,
    expiresAt: later(now, CODE_TTL_S),
    createdAt: now,
  });
  return code;
}

type Tx = Parameters<Parameters<typeof db.transaction>[0]>[0];

async function issuePair(tx: Tx, row: { userId: string; familyId: string; resource: string }, now: Date): Promise<TokenPair> {
  const access = secret();
  const refresh = secret();
  const base = { userId: row.userId, familyId: row.familyId, clientId: OAUTH_CLIENT_ID, resource: row.resource, createdAt: now };
  await tx.insert(oauthTokens).values([
    { ...base, kind: 'access', tokenHash: hashToken(access), expiresAt: later(now, ACCESS_TTL_S) },
    { ...base, kind: 'refresh', tokenHash: hashToken(refresh), expiresAt: later(now, REFRESH_TTL_S) },
  ]);
  return { access_token: access, refresh_token: refresh, token_type: 'Bearer', expires_in: ACCESS_TTL_S, scope: OAUTH_SCOPE };
}

// Marks one live token of `kind` used; the WHERE usedAt IS NULL makes parallel callers race to a single winner.
// Run it in the same transaction as issuePair: a loser then blocks on the row lock until the new pair is committed.
async function consume(tx: Tx, kind: 'code' | 'refresh', raw: string, now: Date) {
  const [row] = await tx
    .update(oauthTokens)
    .set({ usedAt: now })
    .where(
      and(
        eq(oauthTokens.tokenHash, hashToken(raw)),
        eq(oauthTokens.kind, kind),
        isNull(oauthTokens.usedAt),
        isNull(oauthTokens.revokedAt),
        gt(oauthTokens.expiresAt, now),
      ),
    )
    .returning();
  return row;
}

export async function exchangeCode(p: {
  code: string;
  clientId: string;
  redirectUri: string;
  verifier: string;
  resource: string | null;
}): Promise<TokenPair> {
  if (p.clientId !== OAUTH_CLIENT_ID) throw new OAuthError('invalid_client');
  const now = new Date();
  const result = await db.transaction(async (tx) => {
    const row = await consume(tx, 'code', p.code, now);
    if (!row) return new OAuthError('invalid_grant', 'Code is invalid, used or expired');
    // Failed checks still burn the code, so they return (commit) rather than throw (roll back).
    if (row.clientId !== p.clientId || row.redirectUri !== p.redirectUri) return new OAuthError('invalid_grant', 'redirect_uri mismatch');
    if (!row.codeChallenge || !pkceMatches(p.verifier, row.codeChallenge)) return new OAuthError('invalid_grant', 'PKCE check failed');
    if (p.resource !== null && p.resource !== row.resource) return new OAuthError('invalid_grant', 'resource mismatch');
    return issuePair(tx, row, now);
  });
  if (result instanceof OAuthError) throw result;
  return result;
}

export async function refreshTokens(p: { refreshToken: string; clientId: string }): Promise<TokenPair> {
  if (p.clientId !== OAUTH_CLIENT_ID) throw new OAuthError('invalid_client');
  const now = new Date();
  const pair = await db.transaction(async (tx) => {
    const row = await consume(tx, 'refresh', p.refreshToken, now);
    return row ? issuePair(tx, row, now) : null;
  });
  if (pair) return pair;

  // Runs only after our transaction ended, so a concurrent winner's new pair is already committed and gets revoked too.

  const [stale] = await db
    .select({ familyId: oauthTokens.familyId, usedAt: oauthTokens.usedAt })
    .from(oauthTokens)
    .where(and(eq(oauthTokens.tokenHash, hashToken(p.refreshToken)), eq(oauthTokens.kind, 'refresh')));
  // A replayed refresh token means it leaked: kill the whole family.
  if (stale?.usedAt) {
    await db
      .update(oauthTokens)
      .set({ revokedAt: now })
      .where(and(eq(oauthTokens.familyId, stale.familyId), isNull(oauthTokens.revokedAt)));
  }
  throw new OAuthError('invalid_grant', 'Refresh token is invalid, used or expired');
}

export async function verifyAccess(token: string, resource: string): Promise<{ userId: string; familyId: string } | null> {
  const now = new Date();
  const [row] = await db
    .select({ userId: oauthTokens.userId, familyId: oauthTokens.familyId, email: profiles.email })
    .from(oauthTokens)
    .innerJoin(profiles, eq(profiles.userId, oauthTokens.userId))
    .where(
      and(
        eq(oauthTokens.tokenHash, hashToken(token)),
        eq(oauthTokens.kind, 'access'),
        eq(oauthTokens.resource, resource),
        isNull(oauthTokens.revokedAt),
        gt(oauthTokens.expiresAt, now),
      ),
    );
  if (!row) return null;
  // Profile emails come from verified Neon Auth sign-ins. Parsed per call so allowlist changes apply at once.
  if (!isAllowed({ email: row.email, emailVerified: true }, parseServerEnv(process.env).ALLOWED_EMAILS)) return null;
  return { userId: row.userId, familyId: row.familyId };
}

export async function revokeFamily(userId: string, familyId: string): Promise<void> {
  await db
    .update(oauthTokens)
    .set({ revokedAt: new Date() })
    .where(and(eq(oauthTokens.userId, userId), eq(oauthTokens.familyId, familyId), isNull(oauthTokens.revokedAt)));
}

export async function listFamilies(userId: string): Promise<{ familyId: string; createdAt: Date; lastUsedAt: Date | null }[]> {
  const now = new Date();
  const lastUsedAt = max(oauthTokens.createdAt);
  return db
    .select({ familyId: oauthTokens.familyId, createdAt: sql<Date>`${min(oauthTokens.createdAt)}`.mapWith(oauthTokens.createdAt), lastUsedAt })
    .from(oauthTokens)
    .where(eq(oauthTokens.userId, userId))
    .groupBy(oauthTokens.familyId)
    .having(
      sql`bool_or(${and(inArray(oauthTokens.kind, ['access', 'refresh']), isNull(oauthTokens.revokedAt), gt(oauthTokens.expiresAt, now))})`,
    )
    .orderBy(desc(lastUsedAt));
}

export async function tooManyRecent(): Promise<boolean> {
  const [{ n }] = await db
    .select({ n: count() })
    .from(oauthTokens)
    .where(gt(oauthTokens.createdAt, new Date(Date.now() - 60_000)));
  return n > TOKEN_RATE_LIMIT_PER_MIN;
}
```

## `src/app/.well-known/oauth-protected-resource/api/mcp/route.ts`

```ts
import { OAUTH_SCOPE } from '@/lib/oauth/constants';

export function GET(request: Request) {
  const origin = new URL(request.url).origin;
  return Response.json(
    {
      resource: `${origin}/api/mcp`,
      authorization_servers: [origin],
      scopes_supported: [OAUTH_SCOPE],
      bearer_methods_supported: ['header'],
    },
    { headers: { 'Access-Control-Allow-Origin': '*' } },
  );
}
```

## `src/app/.well-known/oauth-authorization-server/route.ts`

```ts
import { OAUTH_SCOPE } from '@/lib/oauth/constants';

export function GET(request: Request) {
  const origin = new URL(request.url).origin;
  return Response.json(
    {
      issuer: origin,
      authorization_endpoint: `${origin}/oauth/authorize`,
      token_endpoint: `${origin}/oauth/token`,
      response_types_supported: ['code'],
      grant_types_supported: ['authorization_code', 'refresh_token'],
      code_challenge_methods_supported: ['S256'],
      token_endpoint_auth_methods_supported: ['none'],
      scopes_supported: [OAUTH_SCOPE],
    },
    { headers: { 'Access-Control-Allow-Origin': '*' } },
  );
}
```

## `src/app/oauth/authorize/params.ts`

```ts
import { headers } from 'next/headers';
import { OAUTH_CLIENT_ID, OAUTH_REDIRECTS } from '@/lib/oauth/constants';

type Sp = Record<string, string | string[] | undefined>;
export type AuthorizeParams = { redirectUri: string; state: string | null; codeChallenge: string; resource: string };

// Any failure is shown on the page and never redirected, so a bad redirect_uri can't be used to bounce visitors.
export function parseAuthorizeParams(
  sp: Sp,
  origin: string,
): { ok: true; value: AuthorizeParams } | { ok: false; error: string } {
  const get = (k: string) => {
    const v = sp[k];
    return Array.isArray(v) ? undefined : v;
  };
  if (Object.values(sp).some(Array.isArray)) return { ok: false, error: 'A parameter was sent twice.' };
  if (get('client_id') !== OAUTH_CLIENT_ID) return { ok: false, error: 'Unknown app.' };
  const redirectUri = get('redirect_uri');
  if (!redirectUri || !OAUTH_REDIRECTS.includes(redirectUri)) return { ok: false, error: 'That return address isn’t allowed.' };
  if (get('response_type') !== 'code') return { ok: false, error: 'Unsupported response type.' };
  const codeChallenge = get('code_challenge');
  if (!codeChallenge || get('code_challenge_method') !== 'S256') return { ok: false, error: 'A PKCE S256 challenge is required.' };
  const expected = `${origin}/api/mcp`;
  const resource = get('resource') ?? expected;
  if (resource !== expected) return { ok: false, error: 'That resource isn’t this server.' };
  return { ok: true, value: { redirectUri, state: get('state') ?? null, codeChallenge, resource } };
}

// Same origin the route handlers get from request.url: the host this page was served on.
export async function requestOrigin(): Promise<string> {
  const h = await headers();
  const host = h.get('x-forwarded-host') ?? h.get('host');
  if (!host) throw new Error('No host header');
  const proto = h.get('x-forwarded-proto') ?? (host.startsWith('localhost') ? 'http' : 'https');
  return `${proto}://${host}`;
}

export const FORWARDED = ['client_id', 'redirect_uri', 'response_type', 'code_challenge', 'code_challenge_method', 'state', 'resource'];

export function fromForm(fd: FormData): Record<string, string | string[] | undefined> {
  return Object.fromEntries(
    FORWARDED.flatMap((k) => {
      const v = fd.getAll(k).map(String);
      return v.length === 0 ? [] : [[k, v.length === 1 ? v[0] : v]];
    }),
  );
}
```

## `src/app/oauth/authorize/actions.ts`

```ts
'use server';

import { redirect } from 'next/navigation';
import { requireUser } from '@/lib/auth/require-user';
import { issueCode } from '@/lib/oauth/tokens';
import { fromForm, parseAuthorizeParams, requestOrigin } from './params';

// Never trust the page: re-check the user and every parameter before redirecting anywhere.
async function checked(formData: FormData) {
  const user = await requireUser();
  const parsed = parseAuthorizeParams(fromForm(formData), await requestOrigin());
  if (!parsed.ok) throw new Error(parsed.error);
  return { user, p: parsed.value };
}

function back(redirectUri: string, params: Record<string, string | null>): never {
  const url = new URL(redirectUri);
  for (const [k, v] of Object.entries(params)) if (v !== null) url.searchParams.set(k, v);
  redirect(url.toString());
}

export async function allowAction(formData: FormData) {
  const { user, p } = await checked(formData);
  const code = await issueCode({ userId: user.id, redirectUri: p.redirectUri, codeChallenge: p.codeChallenge, resource: p.resource });
  back(p.redirectUri, { code, state: p.state });
}

export async function denyAction(formData: FormData) {
  const { p } = await checked(formData);
  back(p.redirectUri, { error: 'access_denied', state: p.state });
}
```

## `src/app/oauth/authorize/page.tsx`

```ts
import { requireUser } from '@/lib/auth/require-user';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { allowAction, denyAction } from './actions';
import { FORWARDED, parseAuthorizeParams, requestOrigin } from './params';

export default async function AuthorizePage({ searchParams }: { searchParams: Promise<Record<string, string | string[] | undefined>> }) {
  const sp = await searchParams; // first, so the page renders per request
  await requireUser();
  const parsed = parseAuthorizeParams(sp, await requestOrigin());

  return (
    <main className="mx-auto flex min-h-dvh w-full max-w-sm flex-col justify-center px-5 pt-[max(3rem,env(safe-area-inset-top))] pb-[max(1.5rem,env(safe-area-inset-bottom))]">
      {parsed.ok ? (
        <Card className="gap-6 rounded-[1.5rem] py-6">
          <CardHeader className="gap-2 px-6">
            <CardTitle>
              <h1 className="text-[1.75rem] leading-tight font-bold tracking-tight">Claude wants to read and log your ShapeUp data</h1>
            </CardTitle>
            <CardDescription className="text-[0.9375rem]">
              You’ll go back to <span className="font-semibold text-foreground">{new URL(parsed.value.redirectUri).host}</span>. You can disconnect it any time.
            </CardDescription>
          </CardHeader>
          <CardContent className="flex flex-col gap-3 px-6">
            {(
              [
                [allowAction, 'Allow', 'default'],
                [denyAction, 'Deny', 'outline'],
              ] as const
            ).map(([action, label, variant]) => (
              <form key={label} action={action}>
                {FORWARDED.map((k) => {
                  const v = sp[k];
                  return typeof v === 'string' ? <input key={k} type="hidden" name={k} value={v} /> : null;
                })}
                <Button type="submit" variant={variant} className="h-14 w-full rounded-full text-[1.0625rem] font-semibold">
                  {label}
                </Button>
              </form>
            ))}
          </CardContent>
        </Card>
      ) : (
        <Card role="alert" className="gap-2 rounded-[1.5rem] py-6">
          <CardHeader className="gap-2 px-6">
            <CardTitle>
              <h1 className="text-[1.75rem] leading-tight font-bold tracking-tight">This sign-in link doesn’t work</h1>
            </CardTitle>
            <CardDescription className="text-[0.9375rem]">{parsed.error} Start connecting again from Claude.</CardDescription>
          </CardHeader>
        </Card>
      )}
    </main>
  );
}
```

## `src/app/oauth/token/route.ts`

```ts
import { exchangeCode, OAuthError, refreshTokens, tooManyRecent } from '@/lib/oauth/tokens';

const reply = (body: object, status = 200) => Response.json(body, { status, headers: { 'Cache-Control': 'no-store' } });
const fail = (error: OAuthError['code'], status = 400) => reply({ error }, status);

// Never log the request body: it carries codes, verifiers and refresh tokens.
export async function POST(request: Request) {
  if (!request.headers.get('content-type')?.toLowerCase().startsWith('application/x-www-form-urlencoded')) return fail('invalid_request');
  let form: URLSearchParams;
  try {
    form = new URLSearchParams(await request.text());
  } catch {
    return fail('invalid_request');
  }
  const p = (k: string) => form.get(k) || null;
  const grant = p('grant_type');
  if (grant !== 'authorization_code' && grant !== 'refresh_token') return fail(grant ? 'unsupported_grant_type' : 'invalid_request');

  try {
    if (await tooManyRecent()) return reply({ error: 'temporarily_unavailable' }, 429);
    const clientId = p('client_id');
    if (grant === 'authorization_code') {
      const [code, redirectUri, verifier] = [p('code'), p('redirect_uri'), p('code_verifier')];
      if (!clientId || !code || !redirectUri || !verifier) return fail('invalid_request');
      const resource = p('resource');
      if (resource !== null && resource !== `${new URL(request.url).origin}/api/mcp`) return fail('invalid_grant');
      return reply(await exchangeCode({ code, clientId, redirectUri, verifier, resource }));
    }
    const refreshToken = p('refresh_token');
    if (!clientId || !refreshToken) return fail('invalid_request');
    return reply(await refreshTokens({ refreshToken, clientId }));
  } catch (e) {
    if (e instanceof OAuthError) return fail(e.code);
    console.error('oauth/token failed', e instanceof Error ? e.name : 'unknown');
    return reply({ error: 'server_error' }, 500);
  }
}
```

## `src/app/api/mcp/route.ts`

```ts
import { createMcpHandler, withMcpAuth } from 'mcp-handler';
import { z, ZodError } from 'zod';
import { COACH_PROMPT, PLAN_MODES, planWeekPrompt } from '@/lib/coach/prompts';
import { TOOLS, ToolError } from '@/lib/coach/tools';
import { OAUTH_CLIENT_ID } from '@/lib/oauth/constants';
import { verifyAccess } from '@/lib/oauth/tokens';

export const runtime = 'nodejs';

const METADATA_PATH = '/.well-known/oauth-protected-resource/api/mcp';
const text = (t: string, isError?: true) => ({ content: [{ type: 'text' as const, text: t }], ...(isError && { isError }) });

const handler = createMcpHandler(
  (server) => {
    for (const t of TOOLS) {
      server.registerTool(
        t.name,
        {
          description: t.description,
          // Advertise t.input's JSON Schema but let every value through, so we parse it below and word the error ourselves.
          inputSchema: { '~standard': { version: 1, vendor: 'shapeup', validate: (value: unknown) => ({ value }), jsonSchema: t.input['~standard'].jsonSchema } },
          annotations: { readOnlyHint: t.readOnly, destructiveHint: false, openWorldHint: false },
        },
        async (args, ctx) => {
          const userId = ctx.http?.authInfo?.extra?.userId as string;
          try {
            return text(JSON.stringify(await t.run(userId, t.input.parse(args), new Date())));
          } catch (e) {
            if (e instanceof ToolError) return text(e.message, true);
            if (e instanceof ZodError) return text(`Invalid input: ${e.issues.map((i) => `${i.path.join('.') || 'input'} ${i.message}`).join('; ')}`, true);
            // Safe fields only: a query error's message carries the SQL params, i.e. the tool input.
            console.error(`coach tool ${t.name} failed:`, e instanceof Error ? e.name : typeof e, (e as { cause?: { code?: string } })?.cause?.code ?? '');
            return text('Something went wrong, nothing was changed', true);
          }
        },
      );
    }
    const say = (t: string) => ({ messages: [{ role: 'user' as const, content: { type: 'text' as const, text: t } }] });
    server.registerPrompt('coach', { description: "Coach Izaak in ShapeUp's firm-but-fair tone" }, () => say(COACH_PROMPT));
    server.registerPrompt(
      'plan_week',
      { description: "Plan Izaak's next week: the schedule and 1–2 challenges", argsSchema: z.object({ mode: z.enum(PLAN_MODES).describe('no-nonsense, fun, adventurous or date') }) },
      ({ mode }) => say(planWeekPrompt(mode)),
    );
  },
  { serverInfo: { name: 'shapeup', version: '1.0.0' } },
);

const authed = (resource: string) =>
  withMcpAuth(
    handler,
    async (_req, bearer) => {
      try {
        const access = bearer ? await verifyAccess(bearer, resource) : null;
        return access ? { token: bearer!, clientId: OAUTH_CLIENT_ID, scopes: ['mcp'], extra: { userId: access.userId } } : undefined;
      } catch (e) {
        // Swallowed so mcp-handler never logs the error object (its query params hold the token hash); answers 401.
        console.error('coach token check failed:', e instanceof Error ? e.name : typeof e);
        return undefined;
      }
    },
    { required: true, resourceMetadataPath: METADATA_PATH },
  );

async function mcp(request: Request): Promise<Response> {
  const origin = new URL(request.url).origin;
  const res = await authed(`${origin}/api/mcp`)(request);
  // The helper's challenge adds error fields and trusts proxy headers; Claude gets exactly ours.
  if (res.status === 401) res.headers.set('WWW-Authenticate', `Bearer resource_metadata="${origin}${METADATA_PATH}", scope="mcp"`);
  return res;
}

export { mcp as DELETE, mcp as GET, mcp as POST };
```

## `src/app/auth/sign-in/return-path.ts`

```ts
// Same-origin only, so `?next=` can't send a freshly signed-in user to another site.
// Returns an absolute URL: a normalised pathname like `//evil.test` (from `/.//evil.test`) would be protocol-relative.
export function returnPath(loc: { search: string; origin: string }): string {
  const next = new URLSearchParams(loc.search).get('next');
  if (!next?.startsWith('/')) return '/';
  const url = new URL(next, loc.origin);
  return url.origin === loc.origin && !url.pathname.startsWith('//') ? url.href : '/';
}
```

## Proxy matcher (src/proxy.ts)

```ts
13:  matcher: [
14-    '/((?!_next/|favicon\\.ico|manifest\\.webmanifest|sw\\.js|icons/|apple-icon|api/tick|api/test|api/mcp|\\.well-known|oauth/token|.*\\.(?:png|jpg|jpeg|gif|svg|webp|ico)$).*)',
15-  ],
16-};
```

## Schema (Drizzle)

```ts
56:export const oauthTokenKindEnum = pgEnum('oauth_token_kind', ['code', 'access', 'refresh']);
57-export const challengeStatusEnum = pgEnum('challenge_status', ['open', 'done', 'missed']);
58-export const habitKindEnum = pgEnum('habit_kind', ['tick', 'number']);
59-
60-// Column helpers
61-
62-const id = () => uuid().primaryKey().defaultRandom();
63-const day = () => date({ mode: 'string' });
64-const tstz = () => timestamp({ withTimezone: true });
65-const createdAt = () => tstz().notNull().defaultNow();
66-const userId = () =>
67-  uuid()
68-    .notNull()
69-    .references(() => profiles.userId, { onDelete: 'cascade' });
70-
71-// Tables
72-
--
439:export const oauthTokens = pgTable('oauth_tokens', {
440-  id: id(),
441-  userId: userId(),
442:  kind: oauthTokenKindEnum().notNull(),
443-  tokenHash: text().notNull().unique(),
444-  familyId: uuid().notNull(),
```
