#!/bin/bash
# Adds the standard project files to a project folder. Safe to re-run: it never overwrites existing files.
set -euo pipefail

usage() { echo "usage: $0 <website|phone|iphone|sandbox|content> <project-dir> [one-line description]" >&2; exit 1; }
[ $# -ge 2 ] || usage
type=$1 dir=$2 desc=${3:-"(one-line description of the project)"}
name=$(basename "$dir")
skill=$(cd "$(dirname "$0")/.." && pwd)

case $type in
  website) area=code    stack="Next.js (App Router, TypeScript, Tailwind) + shadcn/ui, hosted on Vercel, database on Neon" ;;
  phone)   area=code    stack="Expo (Expo Router, TypeScript), backend on Supabase, store builds via EAS" ;;
  iphone)  area=code    stack="SwiftUI (Xcode)" ;;
  sandbox) area=sandbox stack="whatever the experiment needs" ;;
  content) area=content stack="" ;;
  *) usage ;;
esac

esc() { printf '%s' "$1" | sed -e 's/[\\|&]/\\&/g'; }  # make text safe as a sed replacement
fill() {
  sed -e "s|{{NAME}}|$(esc "$name")|g" -e "s|{{DESCRIPTION}}|$(esc "$desc")|g" \
      -e "s|{{TYPE}}|$type|g" -e "s|{{STACK}}|$(esc "$stack")|g" -e "s|{{AREA}}|$area|g" "$1"
}
add() { [ -e "$2" ] && return 0; fill "$1" > "$2"; echo "added $(basename "$2")"; }

mkdir -p "$dir"
if [ "$type" = content ]; then
  mkdir -p "$dir/source" "$dir/working" "$dir/exports"
  add "$skill/assets/CLAUDE.content.md" "$dir/CLAUDE.md"
  add "$skill/assets/brief.md" "$dir/brief.md"
else
  mkdir -p "$dir/docs"
  add "$skill/assets/CLAUDE.code.md" "$dir/CLAUDE.md"
  if [ ! -e "$dir/.env.example" ]; then
    echo "# Variable names this project needs, with no values. Real values go in .env.local (never committed)." > "$dir/.env.example"
    echo "added .env.example"
  fi
  touch "$dir/.gitignore"
  # '!.env.example' must come after any '.env*' rule (Next.js adds one) so the example file stays committed.
  for line in '.env' '.env*.local' '.DS_Store' 'graphify-out/' '.omc/' '!.env.example'; do
    grep -qxF -- "$line" "$dir/.gitignore" || echo "$line" >> "$dir/.gitignore"
  done
  [ -d "$dir/.git" ] || { git -C "$dir" init -q && echo "initialised git"; }
fi
echo "ready: $dir"
