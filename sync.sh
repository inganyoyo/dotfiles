#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

cp ~/.claude/settings.json "$DIR/claude/settings.json"
cp ~/.claude/statusline-command.sh "$DIR/claude/statusline-command.sh"

cd "$DIR"
git add .

if git diff --cached --quiet; then
  echo "No changes."
  exit 0
fi

git commit -m "sync: $(date '+%Y-%m-%d %H:%M')"
git push
echo "Done."
