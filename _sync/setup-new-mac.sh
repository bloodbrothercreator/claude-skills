#!/bin/bash
# Join another Mac to the shared skills library. Keeps every skill this Mac already has (they get added
# to the library), backs up the old folders, then turns on the 15-minute sync.
set -eu
REPO="bloodbrothercreator/claude-skills"
C="$HOME/.claude"
STAMP="$(date +%Y%m%d-%H%M%S)"
command -v gh >/dev/null || { echo "Install the GitHub CLI first: brew install gh, then gh auth login"; exit 1; }
[ -d "$C/skills/.git" ] && { echo "This Mac is already set up. Run: bash ~/.claude/skills/_sync/sync.sh"; exit 0; }

NEW="$C/skills-library-$STAMP"
gh repo clone "$REPO" "$NEW" -- -q

# Skills only this Mac has go into the library (nothing in the library is overwritten).
if [ -d "$C/skills" ]; then
  for d in "$C/skills"/*/; do
    n="$(basename "$d")"
    [ -e "$NEW/$n" ] || cp -R "$d" "$NEW/$n"
  done
  mv "$C/skills" "$C/skills.backup-$STAMP"
fi
# The LinkedIn skills' shared files.
if [ -d "$C/references" ] && [ ! -L "$C/references" ]; then
  mkdir -p "$NEW/_references"
  cp -Rn "$C/references/" "$NEW/_references/" 2>/dev/null || true
  mv "$C/references" "$C/references.backup-$STAMP"
fi
mv "$NEW" "$C/skills"
[ -e "$C/references" ] || ln -s "$C/skills/_references" "$C/references"

bash "$C/skills/_sync/sync.sh"
bash "$C/skills/_sync/install-sync.sh"
echo "Done. Old folders were kept as ~/.claude/skills.backup-$STAMP (delete once you're happy)."
echo "Plugins aren't folders: see ~/.claude/skills/PLUGINS.md for the ones to add on this Mac."
