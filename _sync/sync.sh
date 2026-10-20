#!/bin/bash
# Keep ~/.claude/skills in step with GitHub: save this Mac's changes, take the other Macs', push.
# Runs every 15 minutes from ~/Library/LaunchAgents/com.izaak.claude-skills-sync.plist, or by hand.
set -u
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin"
DIR="$HOME/.claude/skills"
LOG="$HOME/Library/Logs/claude-skills-sync.log"
log() { echo "$(date '+%F %T') $*" >> "$LOG"; }
cd "$DIR" || { log "no $DIR"; exit 1; }

# One run at a time (the timer and a manual run can overlap).
LOCK="$HOME/Library/Caches/claude-skills-sync.lock"
mkdir -p "$HOME/Library/Caches"
# A lock left by a run that was killed doesn't block syncing for more than 10 minutes.
[ -d "$LOCK" ] && [ -n "$(find "$LOCK" -maxdepth 0 -mmin +10)" ] && rmdir "$LOCK"
mkdir "$LOCK" 2>/dev/null || exit 0
trap 'rmdir "$LOCK"' EXIT

HOST="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"
# Where each skill came from, per Mac (one file each, so two Macs never edit the same file).
LOCKFILE="$HOME/.agents/.skill-lock.json"
if [ -f "$LOCKFILE" ]; then
  /usr/bin/python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1]))["skills"]; json.dump({k:v.get("source","") for k,v in sorted(d.items())}, open(sys.argv[2],"w"), indent=1)' \
    "$LOCKFILE" "_sync/sources/$HOST.json" 2>>"$LOG" || log "couldn't read the skills lock file"
fi

git add -A
git diff --cached --quiet || git commit -qm "Skills from $HOST" || { log "commit failed"; exit 1; }
if ! git pull -q --rebase --autostash 2>>"$LOG"; then
  git rebase --abort 2>/dev/null
  log "pull failed: the same skill changed on two Macs; fix by hand in $DIR"
  exit 1
fi
git push -q 2>>"$LOG" || { log "push failed"; exit 1; }
log "synced"
