#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

# Install Claude Code settings
mkdir -p ~/.claude
cp "$DIR/claude/settings.json" ~/.claude/settings.json
cp "$DIR/claude/statusline-command.sh" ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh

# Install Antigravity settings
mkdir -p ~/.gemini/antigravity-cli/scratch
cp "$DIR/antigravity/settings.json" ~/.gemini/antigravity-cli/settings.json
cp "$DIR/antigravity/statusline-antigravity.sh" ~/.gemini/antigravity-cli/scratch/statusline-antigravity.sh
chmod +x ~/.gemini/antigravity-cli/scratch/statusline-antigravity.sh

# Install zsh settings
cp "$DIR/zsh/p10k.zsh" ~/.p10k.zsh

echo "Done."
