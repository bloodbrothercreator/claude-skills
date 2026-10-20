"""Write README.md: every skill in this repo, grouped by where it came from. Run by the GitHub Action on each push."""
import glob, json, os, re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REPO = "bloodbrothercreator/claude-skills"


def frontmatter(path):
    text = open(path, encoding="utf-8", errors="replace").read()
    m = re.match(r"---\n(.*?)\n---", text, re.S)
    fm = m.group(1) if m else ""
    d = re.search(r"^description:\s*(.*?)(?=^\w[\w-]*:|\Z)", fm, re.S | re.M)
    return re.sub(r"\s+", " ", d.group(1)).strip().strip(">|").strip().strip("\"'").lstrip("-– ") if d else ""


def short(desc):
    desc = re.sub(r"^You MUST use this ", "Use this ", desc)
    d = re.split(r"(?<=[a-z0-9)])\. |\s+(?:Use (?:when|for|this|it)|Trigger|Triggers|TRIGGER)\b", desc, maxsplit=1)[0].strip().rstrip(".")
    return d if len(d) <= 100 else d[:98].rsplit(" ", 1)[0].rstrip(",;:—-") + "…"


def sources():
    out = {}
    for f in sorted(glob.glob(os.path.join(ROOT, "_sync", "sources", "*.json"))):
        out.update(json.load(open(f)))
    return out


def main():
    src = sources()
    groups = {}
    for f in sorted(glob.glob(os.path.join(ROOT, "*", "SKILL.md"))):
        name = os.path.basename(os.path.dirname(f))
        if name.startswith(("_", ".")):
            continue
        groups.setdefault(src.get(name, "Homemade or added by hand"), []).append((name, short(frontmatter(f))))
    total = sum(len(v) for v in groups.values())
    lines = [
        "# Claude skills library",
        "",
        f"All {total} personal Claude Code skills, shared between Izaak's Macs. This list rebuilds itself after every change.",
        "",
        "## How it works",
        "",
        "- On each Mac, `~/.claude/skills` **is** this repo. Every 15 minutes a background job saves new or changed skills, pulls the other Mac's changes and pushes (`_sync/sync.sh`, log in `~/Library/Logs/claude-skills-sync.log`).",
        "- Add a skill the normal way (ask Claude, or `npx skills add <repo> -g -a claude-code --copy`). It reaches the other Mac within about 15 minutes.",
        "- Sync straight away: `bash ~/.claude/skills/_sync/sync.sh`.",
        "- **Set up another Mac** (keeps the skills it already has and adds them here):",
        "",
        "```bash",
        f"gh repo clone {REPO} /tmp/claude-skills && bash /tmp/claude-skills/_sync/setup-new-mac.sh",
        "```",
        "",
        "- Plugins, app plugins and connectors aren't folders, so they're listed in [PLUGINS.md](PLUGINS.md) with the commands to add them.",
        "- `_references/` holds the shared files the LinkedIn skills read and write (your story bank and voice profile). It's linked to `~/.claude/references`.",
        "",
        "## Skills by source",
        "",
    ]
    order = sorted(groups, key=lambda g: (g == "Homemade or added by hand", -len(groups[g]), g.lower()))
    lines += [f"- [{g}](#{re.sub(r'[^a-z0-9 -]', '', g.lower()).replace(' ', '-')}) ({len(groups[g])})" for g in order]
    for g in order:
        link = f"[{g}](https://github.com/{g})" if re.fullmatch(r"[\w.-]+/[\w.-]+", g) else g
        lines += ["", f"### {g}", "", f"From {link}." if link != g else "Made for BBM, or added without the installer.", ""]
        lines += [f"- **`/{n}`**" + (f": {d}" if d else "") for n, d in groups[g]]
    open(os.path.join(ROOT, "README.md"), "w").write("\n".join(lines) + "\n")
    print(f"README.md: {total} skills in {len(groups)} groups")


if __name__ == "__main__":
    main()
