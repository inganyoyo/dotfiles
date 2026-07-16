#!/usr/bin/env bash
# SessionStart hook (matcher: startup|resume|clear|compact) — inject the
# detected execution environment as extra developer context, so Codex
# doesn't have to re-derive it from env vars every time a browser-control or
# agent-handoff task comes up. AGENT_RUNTIME is normally already set by
# ~/.agent-env.zsh; the checks below are a fallback for shells that didn't
# source it.

runtime="$AGENT_RUNTIME"
if [ -z "$runtime" ]; then
  if [ -n "$ORCA_WORKSPACE_ID" ] || [ "$TERM_PROGRAM" = "Orca" ]; then
    runtime="orca"
  elif [ -n "$CMUX_WORKSPACE_ID" ]; then
    runtime="cmux"
  else
    runtime="plain"
  fi
fi

echo "실행 환경: ${runtime} (AGENT_RUNTIME=${runtime}). AGENTS.md의 \"실행 환경 인식\" 표를 참고해 브라우저 제어/에이전트 위임 작업 시 이 환경에 맞는 도구를 바로 사용하세요."
