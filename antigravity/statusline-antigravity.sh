#!/bin/bash
jq '
  .workspace.current_dir = (.workspace.current_dir // .cwd) |
  .context_window.used_percentage = (.context_window.used_percentage // .context.used_percentage // 0) |
  .context_window.total_input_tokens = (.context_window.total_input_tokens // .context.total_input_tokens // .tokens) |
  .cost.total_cost_usd = (.cost.total_cost_usd // .cost.total_cost // .cost) |
  .cost.total_duration_ms = (.cost.total_duration_ms // .cost.duration_ms // .duration_ms // 0)
' | bash $HOME/.claude/statusline-command.sh
