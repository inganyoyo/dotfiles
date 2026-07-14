#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

# Sync Claude Code settings
cp ~/.claude/settings.json "$DIR/claude/settings.json"
cp ~/.claude/statusline-command.sh "$DIR/claude/statusline-command.sh"
cp ~/.claude/CLAUDE.md "$DIR/claude/CLAUDE.md"

# Sync Antigravity settings
cp ~/.gemini/antigravity-cli/settings.json "$DIR/antigravity/settings.json"
cp ~/.gemini/antigravity-cli/scratch/statusline-antigravity.sh "$DIR/antigravity/statusline-antigravity.sh"
cp ~/.gemini/GEMINI.md "$DIR/antigravity/GEMINI.md"

# Sync Codex status line settings and instructions
mkdir -p "$DIR/codex"
cp ~/.codex/AGENTS.md "$DIR/codex/AGENTS.md"
awk '
  /^\[tui\]$/ {
    in_tui = 1
    printed_header = 0
    next
  }
  /^\[/ {
    in_tui = 0
  }
  in_tui && /^status_line =/ {
    print
    if ($0 !~ /\]$/) {
      while ((getline line) > 0) {
        print line
        if (line ~ /^\]$/) {
          break
        }
      }
    }
    next
  }
  in_tui && /^status_line_use_colors =/ {
    print
  }
' ~/.codex/config.toml > "$DIR/codex/config.toml"

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
