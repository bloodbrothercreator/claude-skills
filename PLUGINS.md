# Plugins, app plugins and connectors

These aren't skill folders, so the sync can't copy them. Add them once on each Mac.

## Claude Code plugins (run in Terminal)

| Plugin | What it does | Add it |
|---|---|---|
| Superpowers | Planning, debugging and checking skills Claude uses on its own | `claude plugin install superpowers@claude-plugins-official` |
| Claude Code Setup | Suggests skills, hooks and add-ons for a project | `claude plugin install claude-code-setup@claude-plugins-official` |
| Ponytail | Smallest change that does the job, short replies | `claude plugin marketplace add DietrichGebert/ponytail && claude plugin install ponytail@ponytail` |
| Ars Contexta | Builds a linked-notes knowledge vault | `claude plugin marketplace add agenticnotetaking/arscontexta && claude plugin install arscontexta@agenticnotetaking` |

Left off on purpose: claude-mem, oh-my-claudecode, autoharness, FreeLLMAPI, Agent Reach, Strix (reasons on the GlenDesk board "AI Tools & How to Use").

REA (`reverse-engineer-anything` skill) works best with its add-on: `npx -y rea-agents@latest setup --client claude-code`. It changes Claude's settings and can install decompiler apps, so only run it on purpose.

## Claude app plugins

Small Business, Sales, Marketing, Finance, Data, Design, Product Management, Operations, Productivity, Brand Voice, Adobe for Creativity, PDF Viewer, Cowork Plugin Management. They come with the Claude account (Customize → Plugins), so every Mac signed in to it has them.

## Connectors

Claude app → Settings → Connectors. Connected on the Mac Studio (Oct 2026): Vercel, Neon, Supabase, Figma, Canva, Adobe (needs sign-in), Notion, Claude Docs, Gmail, Google Drive and Sheets, Microsoft 365, ClickUp, Shopify, Klaviyo, Claude in Chrome.

## Project skills

Skills inside a project (for example Christmas Calendar's Clerk and Neon skills in `.claude/skills`) travel with that project's own repo, not this one.
