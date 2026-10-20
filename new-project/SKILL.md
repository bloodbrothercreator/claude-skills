---
name: new-project
description: Start a new project the standard way. Creates the folder under ~/Projects (code/, content/ or sandbox/), scaffolds it with the user's default stack (Next.js + Vercel + Neon for websites, Expo + Supabase for phone apps, SwiftUI for iPhone-only apps, plain folders for video, design, copy and research work), adds the project CLAUDE.md, docs and env files, sets up git, and offers a private GitHub repo. Use whenever the user wants to start, create, set up, spin up or begin a website, web app, phone app, experiment, video, design, research or any other new piece of work, even if they never say "new project" (for example "let's build a booking site", "I want to make an app for my gym", "set up a folder for my next reel"). Also use when bringing an existing repo onto this Mac. Not for adding features to a project that already exists.
---

# New project

Every project on this Mac lives in `~/Projects` and is set up the same way, so any Claude session can open any project and know where everything is. Follow these steps in order; each one exists because skipping it caused a mess somewhere else.

## 1. Pin down type, name and description

| Type | Use for | Lives in |
|---|---|---|
| `website` | Websites and web apps | `~/Projects/code/<name>` |
| `phone` | iPhone + Android apps | `~/Projects/code/<name>` |
| `iphone` | iPhone-only native apps | `~/Projects/code/<name>` |
| `content` | Video, design, copywriting, research, data work | `~/Projects/content/<name>` |
| `sandbox` | Experiments, tutorials, throwaway tests | `~/Projects/sandbox/<name>` |

- Infer what you can from the request. Ask only for what's missing, in one AskUserQuestion call.
- Name: lowercase-with-dashes, short (≤ 30 characters), e.g. `gym-booking`. The same name is used for the folder, the GitHub repo and the Vercel project, so pick it once.
- If the user only has a rough idea and hasn't planned it, offer the `vibe-check` skill first. Its plan or PRD goes in the new project's `docs/` folder afterwards.
- Check the idea board (`~/Projects/content/ideas/README.md`, after a `git pull`). If this project matches an idea there, follow the `ideas` skill's "Take one on" step so the idea is marked as building and linked to the new project, and reuse its scope.

## 2. Check the name is free

```bash
ls -d ~/Projects/*/<name> ~/Projects/archive/*/<name> 2>/dev/null   # local, including archived
gh repo view bloodbrothercreator/<name> >/dev/null 2>&1 && echo "taken on GitHub"
```

If either exists, suggest a variation instead of overwriting anything.

## 3. Scaffold with the official tool

Opt out of tool telemetry by prefixing commands with `NEXT_TELEMETRY_DISABLED=1 EXPO_NO_TELEMETRY=1 DO_NOT_TRACK=1` (the user's privacy rule). These are also exported in `~/.zshrc`.

- **website:** `cd ~/Projects/code && npx create-next-app@latest <name> --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --use-npm --yes`. Then set up shadcn/ui following the `shadcn` skill.
- **phone:** `cd ~/Projects/code && npx create-expo-app@latest <name>`. Then follow the `expo-overview` and `expo-project-structure` skills for the layout inside it.
- **iphone:** needs Xcode (`ls -d /Applications/Xcode.app`). If it's missing, stop and tell the user to install it from the App Store first. Otherwise create the project in Xcode (File → New → Project → iOS App, Interface: SwiftUI, saved into `~/Projects/code/` with the project name), then continue.
- **content / sandbox:** no scaffold; the next step creates the folder.

The framework decides the folder layout inside a code project. Don't build a parallel structure next to it.

## 4. Add the standard files

```bash
~/.claude/skills/new-project/scripts/add-house-files.sh <type> ~/Projects/<area>/<name> "<one-line description>"
```

This adds what every project here has, and never overwrites existing files:
- **Code and sandbox projects:** `CLAUDE.md`, `docs/`, `.env.example`, `.gitignore` rules (secrets ignored, `.env.example` kept), and `git init`.
- **Content projects:** `CLAUDE.md`, `brief.md`, and `source/` (untouched originals), `working/` (drafts) and `exports/` (finished files, dated).

Then fill in the **Commands** section of the project `CLAUDE.md` from what the scaffold created (for example `npm run dev` from `package.json`), so later sessions don't have to work it out again.

## 5. First commit and GitHub (code projects)

```bash
cd ~/Projects/<area>/<name> && git add -A && git commit -m "Initial commit"
```

Then **ask** before creating anything online: "Create a private GitHub repo `bloodbrothercreator/<name>` and push to it?" On yes:

```bash
gh repo create bloodbrothercreator/<name> --private --source . --remote origin --push
```

For sandbox projects, only do this if the user asks. Content projects don't use git by default, because large media files don't belong in it.

## 6. Cloud services only when needed

Don't create empty cloud resources up front. When the project first needs them:
- **Website database:** create a Neon project named `<name>` with the Neon connector. Put the connection string in `.env.local` and the variable *name* in `.env.example`.
- **Website hosting:** create or link the Vercel project when the user first wants it online.
- **Phone app data or logins:** create a Supabase project named `<name>` with the Supabase connector.

## 7. Move into the project

Work for this project should happen inside its folder, so its `CLAUDE.md` loads and nothing gets written elsewhere. In the Claude desktop app, move the session there with the `change_directory` tool (absolute path). Elsewhere, tell the user to open that folder.

## 8. Report

Tell the user, in a few lines: where the project lives, what was set up (scaffold, files, git, GitHub if created), and the obvious next step (for example "run it" or "plan the first screen").

## Bringing an existing repo onto this Mac

Clone it into `~/Projects/code/<name>` (`gh repo clone bloodbrothercreator/<name> ~/Projects/code/<name>`), then run step 4. The script only adds files that are missing, so it won't disturb anything.
