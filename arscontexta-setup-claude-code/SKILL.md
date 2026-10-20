---
name: arscontexta-setup-claude-code
description: Fixes and working method for running the Ars Contexta plugin's /arscontexta:setup (v0.8.x) in Claude Code or the Claude desktop app, and for repairing a vault it generated. Use whenever the user runs or continues /arscontexta:setup, asks to build an Ars Contexta vault or "knowledge system", answers the setup's "Tell me about what you want to track" question, or reports that a generated vault's skills, hooks, queue or kernel validation misbehave — even if they don't mention these gotchas.
---

# Ars Contexta setup in Claude Code: what actually works

The plugin's setup skill (`<plugin>/skills/setup/SKILL.md`, plugin root under `~/.claude/plugins/cache/agenticnotetaking/arscontexta/<version>/`) is the procedure. Follow it. This skill covers where that procedure breaks in Claude Code, and the fixes that worked.

## 1. Run the setup inline, not as a forked skill

The setup's frontmatter has `context: fork`, so invoking it through the Skill tool runs it in a subagent. That subagent can't see the conversation (so it never gets the user's answer) and can't stop for the Phase 4 approval. It returns "missing context" and does nothing.

Instead, `Read` the setup's SKILL.md and its `reference/` files yourself and run Phases 2–6 in the main session. Ask the opening question in plain prose. Present the proposal, and collect approval, folder and opt-ins (semantic search) in one AskUserQuestion.

## 2. Pick a permanent folder before Phase 5

Sessions often start in a throwaway scratch folder, and a vault generated there is lost. Get a real location first: follow the user's project-folder convention if they have one (e.g. a `new-project` skill that puts content work in `~/Projects/content/<name>`). Then move the session there with the directory tools before writing anything.

Don't run a house "add standard files" script on top of the vault: the setup writes its own CLAUDE.md.

## 3. Delegate the 16 skill transforms

Skill templates live in `<plugin>/skill-sources/*/SKILL.md` (about 8k lines in total). Transforming them in the main context wastes it. Spawn about 5 parallel subagents, each taking 3–4 skills, with these instructions:

- `cp` the source, then edit in place. Never regenerate: the quality gates and handoff formats must survive. Line count should stay within about 10%.
- Replace scalar placeholders (`{vocabulary.notes}`, `{vocabulary.topic_maps}`, `{DOMAIN:x}`, plus unlisted ones like `{vocabulary.topic_map_plural}` and `{vocabulary.domain}`) with literal values. Keep each skill's Step 0 "read ops/derivation-manifest.md" block.
- YAML keys stay structural (`description:`, `topics:`, `type: moc`).
- Give them the complete rename map for commands.

Write `ops/derivation.md`, `ops/derivation-manifest.md` and `ops/config.yaml` **before** spawning, because the agents read them.

## 4. Fixes to apply after the transforms

Check each of these. Every one surfaced in a real run.

| Problem | Fix |
|---|---|
| `tasks` and `stats` collide with Claude Code built-ins `/tasks` and `/stats` | Rename them (e.g. `brain-tasks`, `brain-stats`) and record the rename in the manifest |
| Queue phase IDs drift when reflect/reweave/verify are renamed | connect and revisit write their domain phase names, so ralph's `phase_order` and every `current_phase: "..."` literal (check, validate, rethink) must use the same names. Keep task types `claim`, `enrichment` and `extract`, since seed and extract write those literally. Grep `"verify"\|"reflect"\|"reweave"` afterwards. |
| Bare `/health`, `/architect`, `/reseed`, `/ask`, `/add-domain` in skills | They're plugin commands, so prefix them with `/arscontexta:` (skip paths like `ops/health/`) |
| `/archive-batch` and `/enrich` are referenced but don't exist anywhere | Add one line to CLAUDE.md saying to do archival and enrichment inline |
| Skills say a hub's "Core Ideas" section, but a custom hub template uses typed sections | Add one line to CLAUDE.md mapping "Core Ideas" to those sections, rather than editing 13 references |
| `/next` has its own hard-coded thresholds (inbox > 5) | Align them with CLAUDE.md and `maintenance_conditions`. Add `self_evolution.observation_threshold` and `tension_threshold` to config.yaml, since `/next` reads them. |
| A subagent's report says a file is wrong | It may have read the file before another agent finished. Re-check before "fixing". |

## 5. Hooks: don't double-register

The plugin's own `hooks/hooks.json` already runs SessionStart orientation, PostToolUse(Write) validation and auto-commit for **any** folder with a `.arscontexta` marker. If you also register the setup's project hooks for those three, they run twice, and the duplicate auto-commits race on `.git/index.lock`.

- Register only session capture in the vault's `.claude/settings.json`. Keep standalone copies of all four scripts in `.claude/hooks/`, and document in CLAUDE.md how to register the other three if the plugin is ever removed.
- Register session capture on **SessionEnd**, not Stop. Stop fires after every reply, which floods `ops/sessions/` and trips the unprocessed-sessions condition.
- `CLAUDE_CONVERSATION_ID` is often unset. Read `session_id` from the hook's stdin JSON as a fallback (`jq -r '.session_id // empty'`).
- Hook templates are in `<plugin>/platforms/claude-code/hooks/*.template`. Fill the `{{VAR:-default}}` and `{DOMAIN:x}` markers with sed, drop the `# {{IF_...}}` marker lines, then run `bash -n` on each.

## 6. Helper scripts don't ship with the plugin

The feature blocks reference `ops/scripts/rename-note.sh`, `backlinks.sh`, `validate-schema.sh` and `ops/scripts/graph/{orphan-notes,dangling-links,link-density}.sh`, but the plugin doesn't include them. Skills fall back to inline analysis if they're missing, but CLAUDE.md must not point at files that don't exist.

Either write a small set (a shared `lib.sh` with a frontmatter reader, wiki-link extractor and BSD/GNU date helper) plus a self-test that builds a throwaway vault and asserts each script, or remove the references. Wiki links resolve by filename anywhere in the vault. Strip `|alias` and `#heading`, and exclude `templates/` and `.claude/` from link sources, because they contain placeholder links.

## 7. Pass kernel validation

Run `bash <plugin>/reference/validate-kernel.sh .` from the vault root.

- **Primitive 1** fails if more than about 20% of `.md` files lack frontmatter. It scans everything except README.md, SKILL.md and CLAUDE.md, so give `ops/reminders.md`, `tasks.md`, `changelog.md` and `user-overrides.md` a `description` frontmatter. `ops/derivation-manifest.md` must start with `---`: move its comment lines inside the YAML.
- `ops/queue/queue.json` needs `schema_version: 3` and a `maintenance_conditions` object.
- Expect one WARN for semantic search if qmd was deferred. That's fine, as long as the install steps are documented.
- Parse YAML with ruby if PyYAML is missing: `LANG=en_US.UTF-8 ruby -Eutf-8 -ryaml -e '...'`. Plain `ruby` chokes on em dashes under US-ASCII.

Finish with `git init` and one initial commit. Run the git init **after** the generation writes, so the plugin's auto-commit hook doesn't make dozens of partial commits. Tell the user to restart Claude Code (or open a new session in the vault folder) so the skills and hooks load.
