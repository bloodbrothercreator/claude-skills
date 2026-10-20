---
name: neon-via-vercel
description: Using Neon when the Neon org is "managed by Vercel" (databases created through Vercel → Storage), plus the Vercel CLI fallback when the Vercel MCP lacks team scope. Use when Neon MCP create_project is refused, when wiring DATABASE_URL / Neon Auth into a Vercel project, when setting Vercel env vars from the CLI, or when `vercel` commands fail on team scope. Complements the neon, neon-auth and neon-postgres-branches skills.
---

# Neon via Vercel

## Creating the database
- If the Neon org is managed by Vercel, Neon MCP `create_project` is refused. Create the DB in the Vercel dashboard: **Storage → Create → Neon**, connected to the project. Ask the user first (cloud resource).
- After that the Neon MCP still works for everything else: branches, SQL, Neon Auth config, trusted domains (`add_auth_trusted_domain`).
- The integration sets `DATABASE_URL` and `DATABASE_URL_UNPOOLED` (prefix `DATABASE`) for Production + Preview, pointing at the `main` branch. For local work make a Neon `dev` branch and put its URLs in `.env.local`, not main's.
- Neon Auth (`better_auth`) is pre-provisioned on new branches. Email OTP needs no toggle. Add the deployed URL as a trusted domain on the branch the deployment uses.

## Vercel CLI when the Vercel MCP lacks team scope
- Ask the user to run `vercel login` (interactive). Then use `VERCEL_TELEMETRY_DISABLED=1 npx vercel@latest --scope <team> ...`.
- `vercel link` appends `VERCEL_OIDC_TOKEN` to `.env.local`; that is expected, keep the file uncommitted.
- Add env vars by piping the value: `printf '%s' "$VALUE" | vercel env add NAME production --yes` (repeat for `preview`). In zsh, if you wrap this, use a shell **function**, not a string variable holding the command (zsh doesn't word-split variables).
- Never echo secret values into chat or files that get committed.

## Local checks
- `next dev --experimental-https` needs a system mkcert trust install (asks for a password). Use plain `http://localhost:3000` for local checks in Chromium instead.
