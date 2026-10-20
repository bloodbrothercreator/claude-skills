---
name: bbm-add-skill
description: Izaak's house rule for adding Claude skills or plugins. Use whenever Izaak asks to add, install or download a skill, plugin or tool, from a reel, a link, a repo or just a name, or asks "do we have a skill for X". It installs the skill, adds it to the GlenDesk "AI Tools & How to Use" board and syncs the shared skills library.
---

# Adding a skill (Izaak's rule)

Every skill Izaak asks for goes to three places: this Mac, the shared skills library on GitHub, and the GlenDesk board "AI Tools & How to Use".

1. **Find it.** From a reel, read the caption (the Instagram page's `og:description` has the full script). Find the source repo (`gh search repos`, `npx skills find`). Check what we already have (`ls ~/.claude/skills`, `claude plugin list`).
2. **Check it before installing.** Look for hooks (`hooks/hooks.json`), add-on servers (`.mcp.json`), scripts that call the internet, and anything that runs in every session. Plain instruction skills are fine. Anything that runs by itself, sends data elsewhere, uses his logins to scrape sites, or changes settings: explain it in plain English and ask first.
3. **Install it** for Claude Code on this Mac: `npx -y skills@latest add <owner/repo> -g -a claude-code --copy -y -s <skill> ...` (add `--full-depth` if it's not found). Plugins: `claude plugin marketplace add <owner/repo>` then `claude plugin install <name>@<marketplace>`, and add them to `~/.claude/skills/PLUGINS.md`.
4. **Sync the library:** `bash ~/.claude/skills/_sync/sync.sh`. The repo is `bloodbrothercreator/claude-skills` (private). GitHub rebuilds its README skill list by itself.
5. **Add it to the board:** https://bbmos.app/me/boards/37aa38f6-30a8-4137-80cb-7f49e654e60f, in Izaak's Chrome (Claude in Chrome).
   - Re-read the board first: Izaak edits it too.
   - The board has five rows: From the videos (pink), Always on (purple), Skill packs (blue), Claude app plugins (green), Built in (grey). "Not installed - and why" is red.
   - A skill from a video gets its own column at the right end of "From the videos": the reel's link card, then one note: "How to Use:" with plain-English bullets (`/commands` in code style), then **Skills (N):** the names, and **Get it:** the repo link. Otherwise add it to the matching pack's column.
   - Adding cards: GlenDesk's own paste format (`bbmos-board-cards:v1:` + `{cards, arrows}` JSON, see christmas-calendar-pm `src/components/boards/board-canvas.tsx` onPaste). Paste a reel's URL on the canvas to get its link card with a preview.
6. **Tell Izaak** in plain English what it does and how to use it, plus anything left out and why.
