#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

# Install Claude Code settings
mkdir -p ~/.claude
cp "$DIR/claude/settings.json" ~/.claude/settings.json
cp "$DIR/claude/statusline-command.sh" ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
cp "$DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md

# Install Antigravity settings
mkdir -p ~/.gemini/antigravity-cli/scratch
cp "$DIR/antigravity/settings.json" ~/.gemini/antigravity-cli/settings.json
cp "$DIR/antigravity/statusline-antigravity.sh" ~/.gemini/antigravity-cli/scratch/statusline-antigravity.sh
chmod +x ~/.gemini/antigravity-cli/scratch/statusline-antigravity.sh
cp "$DIR/antigravity/GEMINI.md" ~/.gemini/GEMINI.md

# Install Codex instructions
mkdir -p ~/.codex
cp "$DIR/codex/AGENTS.md" ~/.codex/AGENTS.md

# Install Codex status line settings without replacing the rest of config.toml
CODEX_CONFIG=~/.codex/config.toml
CODEX_CONFIG_TMP="$(mktemp)"
if [ -f "$CODEX_CONFIG" ]; then
  awk -v status_file="$DIR/codex/config.toml" '
    function print_status() {
      while ((getline status_line < status_file) > 0) {
        print status_line
      }
      close(status_file)
    }
    /^\[tui\]$/ {
      if (!inserted) {
        print
        print_status()
        inserted = 1
      }
      next
    }
    /^status_line =/ {
      if ($0 !~ /\]$/) {
        while ((getline line) > 0) {
          if (line ~ /^\]$/) {
            break
          }
        }
      }
      next
    }
    /^status_line_use_colors =/ {
      next
    }
    { print }
    END {
      if (!inserted) {
        print ""
        print "[tui]"
        print_status()
      }
    }
  ' "$CODEX_CONFIG" > "$CODEX_CONFIG_TMP"
else
  printf '[tui]\n' > "$CODEX_CONFIG_TMP"
  cat "$DIR/codex/config.toml" >> "$CODEX_CONFIG_TMP"
fi
cp "$CODEX_CONFIG_TMP" "$CODEX_CONFIG"
rm "$CODEX_CONFIG_TMP"

# Install zsh settings
cp "$DIR/zsh/p10k.zsh" ~/.p10k.zsh

echo "Done."
