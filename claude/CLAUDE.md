# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.

# webBrowser
사용자가 웹페이지를 읽거나 브라우저 동작이 필요한 작업을 요청하면, 먼저 실행 환경을 감지해서 그에 맞는 브라우저 제어 방식을 사용한다.
WebFetch로 접근이 안 되거나 인증이 필요한 페이지, JS 렌더링이 필요한 페이지는 아래 방법을 우선 사용한다.

## 환경 감지
- 환경변수 `ORCA_WORKSPACE_ID` 또는 `TERM_PROGRAM=Orca`가 있으면 → **Orca 환경**
- 환경변수 `CMUX_WORKSPACE_ID`가 있으면 → **cmux 환경**
- 둘 다 없으면 WebFetch를 우선 시도하고, 필요하면 사용자에게 어떤 터미널 앱인지 확인한다.

## Orca 환경
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

## cmux 환경
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
