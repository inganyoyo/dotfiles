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

# Install Codex status line settings without replacing the rest of config.toml
mkdir -p ~/.codex
CODEX_CONFIG=~/.codex/config.toml
CODEX_CONFIG_TMP="$(mktemp)"
if [ -f "$CODEX_CONFIG" ]; then
  grep -v -E '^(status_line|status_line_use_colors) =' "$CODEX_CONFIG" > "$CODEX_CONFIG_TMP"
fi
printf '\n' >> "$CODEX_CONFIG_TMP"
cat "$DIR/codex/config.toml" >> "$CODEX_CONFIG_TMP"
cp "$CODEX_CONFIG_TMP" "$CODEX_CONFIG"
rm "$CODEX_CONFIG_TMP"

# Install zsh settings
cp "$DIR/zsh/p10k.zsh" ~/.p10k.zsh

echo "Done."
