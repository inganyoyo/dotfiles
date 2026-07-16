# AI 코딩 에이전트(Claude Code/Codex/Antigravity)가 실행 환경을 추론하지 않고
# 바로 참조할 수 있도록, 셸 시작 시 한 번만 표준 환경변수를 심어둔다.
#
# AGENT_RUNTIME: 현재 셸이 어떤 터미널/워크트리 관리 앱 안에서 도는지
#   - orca  : Orca(워크트리·터미널 관리 앱)
#   - cmux  : cmux(스크립팅 가능한 브라우저 내장 터미널 앱)
#   - plain : 그 외 일반 터미널
if [[ -n "$ORCA_WORKSPACE_ID" || "$TERM_PROGRAM" == "Orca" ]]; then
  export AGENT_RUNTIME="orca"
elif [[ -n "$CMUX_WORKSPACE_ID" ]]; then
  export AGENT_RUNTIME="cmux"
else
  export AGENT_RUNTIME="plain"
fi
