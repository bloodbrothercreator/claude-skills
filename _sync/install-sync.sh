#!/bin/bash
# Start the 15-minute background sync on this Mac (safe to run again).
set -eu
PLIST="$HOME/Library/LaunchAgents/com.izaak.claude-skills-sync.plist"
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>com.izaak.claude-skills-sync</string>
  <key>ProgramArguments</key><array><string>/bin/bash</string><string>$HOME/.claude/skills/_sync/sync.sh</string></array>
  <key>StartInterval</key><integer>900</integer>
  <key>RunAtLoad</key><true/>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/claude-skills-sync.log</string>
</dict>
</plist>
EOF
launchctl bootout "gui/$(id -u)/com.izaak.claude-skills-sync" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "Skills sync is on: every 15 minutes. Log: ~/Library/Logs/claude-skills-sync.log"
