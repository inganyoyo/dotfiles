# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.

# 실행 환경 인식
너는 지금 **Claude Code**로 동작 중이다.

브라우저 제어, 에이전트 위임/핸드오프처럼 실행 환경에 따라 방법이 달라지는 작업이 필요해지는 그 순간에, 먼저 환경을 감지해서 아래 표에 맞는 방식을 쓴다. 세션 시작 시 매번 감지할 필요는 없다 — 불필요한 셸 호출이다.

## 감지 순서
1. 환경변수 확인: `ORCA_WORKSPACE_ID` 또는 `TERM_PROGRAM=Orca` → **Orca 환경**
2. 환경변수 확인: `CMUX_` 접두사(예: `CMUX_WORKSPACE_ID`) → **cmux 환경**
3. 둘 다 없으면 → **기본 환경** (Claude Code 자체 도구 사용), 애매하면 사용자에게 어떤 터미널 앱인지 확인
- 보조 신호가 필요하면 `ps -o comm= -p $PPID`로 부모 프로세스 정도만 참고한다. tty/pwd는 판별 근거로 쓰지 않는다.

## 유스케이스별 도구 선택

| 작업 | Orca 환경 | cmux 환경 | 기본 환경 |
|------|-----------|-----------|-----------|
| 브라우저 제어 | `orca-cli` 스킬(Skill tool) 우선, 직접 호출 시 아래 참고 | `cmux browser ...` (아래 참고) | `WebFetch` 우선 시도 |
| 에이전트 위임/핸드오프 | `orca-cli` 스킬로 `orca worktree create --agent`/`orca terminal create --command` | 별도 위임 CLI가 없으면 로컬 fallback(아래) | `Agent` tool(subagent_type) 또는 fork |

로컬 fallback: 위임 도구가 없는 환경에서는 git worktree + 셸 subprocess + 명확한 프롬프트로 수동 위임을 구성하거나, 자동 위임이 불가능하면 사용자에게 그대로 보고한다.

## Orca 환경 — 브라우저 제어
Orca는 내장 브라우저와 이를 제어하는 `orca` CLI를 제공하는 macOS 앱이다.
"Orca browser" 등 관련 요청이면 먼저 `orca-cli` 스킬(Skill tool)을 사용한다. 스킬 없이 직접 호출할 경우 (`orca open`은 런타임 기동용이라 --url을 받지 않음 — 새 탭은 `tab create`로 연다):

```bash
orca tab create --url https://example.com --json   # 새 탭 열기 (browserPageId 반환)
orca snapshot --page <pageId>
orca goto --url https://example.com/login --page <pageId>
orca click --element e3 --page <pageId>
orca fill --element e5 --value "hello" --page <pageId>
orca eval --expression "document.title" --page <pageId>
```

## cmux 환경 — 브라우저 제어
cmux는 스크립팅 가능한 내장 브라우저를 제공하는 macOS 터미널 앱이다 (https://cmux.com/ko).

```bash
# URL 열기
cmux browser open https://example.com

# 페이지 로드 대기 후 텍스트/스냅샷 읽기
cmux browser surface:2 wait --load-state complete
cmux browser surface:2 get text "body"
cmux browser surface:2 snapshot --interactive --compact

# 특정 요소 텍스트 추출
cmux browser surface:2 get text "h1"
cmux browser surface:2 get html "main"

# 스크린샷
cmux browser surface:2 screenshot --out /tmp/page.png

# JavaScript 실행
cmux browser surface:2 eval "document.title"
```
