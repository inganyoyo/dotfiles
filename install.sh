#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

# Install Claude Code settings
mkdir -p ~/.claude/hooks
cp "$DIR/claude/settings.json" ~/.claude/settings.json
cp "$DIR/claude/statusline-command.sh" ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
cp "$DIR/claude/CLAUDE.md" ~/.claude/CLAUDE.md
cp "$DIR/claude/hooks/session-start-env.sh" ~/.claude/hooks/session-start-env.sh
chmod +x ~/.claude/hooks/session-start-env.sh

# Install Antigravity settings
mkdir -p ~/.gemini/antigravity-cli/scratch ~/.gemini/config ~/.gemini/hooks
cp "$DIR/antigravity/settings.json" ~/.gemini/antigravity-cli/settings.json
cp "$DIR/antigravity/statusline-antigravity.sh" ~/.gemini/antigravity-cli/scratch/statusline-antigravity.sh
chmod +x ~/.gemini/antigravity-cli/scratch/statusline-antigravity.sh
cp "$DIR/antigravity/GEMINI.md" ~/.gemini/GEMINI.md
cp "$DIR/antigravity/hooks.json" ~/.gemini/config/hooks.json
cp "$DIR/antigravity/hooks/pre-invocation-env.sh" ~/.gemini/hooks/pre-invocation-env.sh
chmod +x ~/.gemini/hooks/pre-invocation-env.sh

# Install Codex instructions
mkdir -p ~/.codex/hooks
cp "$DIR/codex/AGENTS.md" ~/.codex/AGENTS.md
cp "$DIR/codex/hooks/session-start-env.sh" ~/.codex/hooks/session-start-env.sh
chmod +x ~/.codex/hooks/session-start-env.sh

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

# Install the SessionStart env-injection hook config (idempotent append)
# __HOME__ is a portable placeholder substituted with this machine's actual
# $HOME, since TOML has no native env-var expansion.
if ! grep -qF '[[hooks.SessionStart]]' "$CODEX_CONFIG"; then
  printf '\n' >> "$CODEX_CONFIG"
  sed "s|__HOME__|$HOME|g" "$DIR/codex/config-hooks.toml" >> "$CODEX_CONFIG"
fi

# Install zsh settings
cp "$DIR/zsh/p10k.zsh" ~/.p10k.zsh

# Install agent runtime env detection and wire it into .zshrc (idempotent)
cp "$DIR/zsh/agent-env.zsh" ~/.agent-env.zsh
if ! grep -qF 'source ~/.agent-env.zsh' ~/.zshrc 2>/dev/null; then
  printf '\n[[ ! -f ~/.agent-env.zsh ]] || source ~/.agent-env.zsh\n' >> ~/.zshrc
fi

echo "Done."
