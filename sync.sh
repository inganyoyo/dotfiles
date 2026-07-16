#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

# Sync Claude Code settings
cp ~/.claude/settings.json "$DIR/claude/settings.json"
cp ~/.claude/statusline-command.sh "$DIR/claude/statusline-command.sh"
cp ~/.claude/CLAUDE.md "$DIR/claude/CLAUDE.md"
mkdir -p "$DIR/claude/hooks"
cp ~/.claude/hooks/session-start-env.sh "$DIR/claude/hooks/session-start-env.sh"

# Sync Antigravity settings
cp ~/.gemini/antigravity-cli/settings.json "$DIR/antigravity/settings.json"
cp ~/.gemini/antigravity-cli/scratch/statusline-antigravity.sh "$DIR/antigravity/statusline-antigravity.sh"
cp ~/.gemini/GEMINI.md "$DIR/antigravity/GEMINI.md"
mkdir -p "$DIR/antigravity/hooks"
cp ~/.gemini/config/hooks.json "$DIR/antigravity/hooks.json"
cp ~/.gemini/hooks/pre-invocation-env.sh "$DIR/antigravity/hooks/pre-invocation-env.sh"

# Sync Codex status line settings and instructions
mkdir -p "$DIR/codex/hooks"
cp ~/.codex/AGENTS.md "$DIR/codex/AGENTS.md"
cp ~/.codex/hooks/session-start-env.sh "$DIR/codex/hooks/session-start-env.sh"
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

# Sync the SessionStart hook block (installed at EOF; capture from its marker to EOF),
# replacing this machine's $HOME back with the portable __HOME__ placeholder.
awk '
  /^\[\[hooks\.SessionStart\]\]$/ { capturing = 1 }
  capturing { print }
' ~/.codex/config.toml | sed "s|$HOME|__HOME__|g" > "$DIR/codex/config-hooks.toml"

# Sync zsh settings
cp ~/.p10k.zsh "$DIR/zsh/p10k.zsh"
cp ~/.agent-env.zsh "$DIR/zsh/agent-env.zsh"

cd "$DIR"
git add .

if git diff --cached --quiet; then
  echo "No changes."
  exit 0
fi

git commit -m "sync: $(date '+%Y-%m-%d %H:%M')"
git push
echo "Done."
