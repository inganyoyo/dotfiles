#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p ~/.claude
cp "$DIR/claude/settings.json" ~/.claude/settings.json
cp "$DIR/claude/statusline-command.sh" ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh

echo "Done."
