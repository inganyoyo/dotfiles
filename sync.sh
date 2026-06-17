#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

# Sync Claude Code settings
cp ~/.claude/settings.json "$DIR/claude/settings.json"
cp ~/.claude/statusline-command.sh "$DIR/claude/statusline-command.sh"

# Sync Antigravity settings
cp ~/.gemini/antigravity-cli/settings.json "$DIR/antigravity/settings.json"
cp ~/.gemini/antigravity-cli/scratch/statusline-antigravity.sh "$DIR/antigravity/statusline-antigravity.sh"

# Sync Codex status line settings only
mkdir -p "$DIR/codex"
grep -E '^(status_line|status_line_use_colors) =' ~/.codex/config.toml > "$DIR/codex/config.toml"

# Sync zsh settings
cp ~/.p10k.zsh "$DIR/zsh/p10k.zsh"

cd "$DIR"
git add .

if git diff --cached --quiet; then
  echo "No changes."
  exit 0
fi

git commit -m "sync: $(date '+%Y-%m-%d %H:%M')"
git push
echo "Done."
