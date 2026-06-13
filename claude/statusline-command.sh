#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
RATE_5H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
PR_NUM=$(echo "$input" | jq -r '.pr.number // empty')
PR_STATE=$(echo "$input" | jq -r '.pr.review_state // empty')
THINKING=$(echo "$input" | jq -r '.thinking.enabled // false')
VIM_MODE=$(echo "$input" | jq -r '.vim.mode // empty')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
WORKTREE=$(echo "$input" | jq -r '.worktree.name // empty')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; MAGENTA='\033[35m'; RESET='\033[0m'

if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

# Git info
GIT_INFO=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

    GIT_STATUS=""
    [ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"
    [ "$UNTRACKED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${CYAN}?${UNTRACKED}${RESET}"

    GIT_INFO=" | 🌿 $BRANCH $GIT_STATUS"
fi

# PR info
PR_INFO=""
if [ -n "$PR_NUM" ]; then
    case "$PR_STATE" in
        approved)          PR_ICON="${GREEN}✔${RESET}" ;;
        changes_requested) PR_ICON="${RED}✘${RESET}" ;;
        draft)             PR_ICON="${YELLOW}◎${RESET}" ;;
        *)                 PR_ICON="${YELLOW}⏳${RESET}" ;;
    esac
    PR_INFO=" | PR#${PR_NUM} ${PR_ICON}"
fi

# Worktree
WORKTREE_INFO=""
[ -n "$WORKTREE" ] && WORKTREE_INFO=" | 🪵 $WORKTREE"

# Cost
COST_INFO=""
[ -n "$COST" ] && COST_INFO=" | 💰 \$$(printf '%.4f' "$COST")"

# Token count
TOKEN_INFO=""
if [ -n "$TOKENS" ]; then
    if [ "$TOKENS" -ge 1000 ]; then
        TOKEN_INFO=" | $(echo "scale=1; $TOKENS/1000" | bc)k tok"
    else
        TOKEN_INFO=" | ${TOKENS} tok"
    fi
fi

# Rate limit (5h)
RATE_INFO=""
if [ -n "$RATE_5H" ]; then
    RATE_PCT=$(echo "$RATE_5H" | cut -d. -f1)
    if [ "$RATE_PCT" -ge 80 ]; then RATE_COLOR="$RED"
    elif [ "$RATE_PCT" -ge 50 ]; then RATE_COLOR="$YELLOW"
    else RATE_COLOR="$GREEN"; fi
    RATE_INFO=" | ${RATE_COLOR}5h:${RATE_PCT}%${RESET}"
fi

# Extras: thinking, vim mode, effort
EXTRAS=""
[ "$THINKING" = "true" ] && EXTRAS="${EXTRAS} | 🧠"
[ -n "$VIM_MODE" ] && EXTRAS="${EXTRAS} | ${MAGENTA}${VIM_MODE}${RESET}"
[ -n "$EFFORT" ] && EXTRAS="${EXTRAS} | ⚡${EFFORT}"

# Line 1: location
echo -e "📁 ${DIR##*/}${GIT_INFO}${PR_INFO}${WORKTREE_INFO}"
# Line 2: model + stats
echo -e "${CYAN}[$MODEL]${RESET}${COST_INFO}${TOKEN_INFO}${RATE_INFO} | ${BAR_COLOR}${BAR}${RESET} ${PCT}% | ⏱️ ${MINS}m ${SECS}s${EXTRAS}"
