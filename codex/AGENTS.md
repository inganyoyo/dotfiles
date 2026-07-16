# 실행 환경 인식

너는 지금 **Codex CLI**로 동작 중이다.

브라우저 제어, 에이전트 위임/핸드오프처럼 실행 환경에 따라 방법이 달라지는 작업이 필요해지는 그 순간에, 먼저 환경을 감지해서 아래 표에 맞는 방식을 쓴다. 세션 시작 시 매번 감지할 필요는 없다 — 불필요한 셸 호출이다.

## 감지 순서
1. 환경변수 확인: `ORCA_WORKSPACE_ID` 또는 `TERM_PROGRAM=Orca` → **Orca 환경**
2. 환경변수 확인: `CMUX_` 접두사(예: `CMUX_WORKSPACE_ID`) → **cmux 환경**
3. 둘 다 없으면 → **기본 환경** (Codex 내장 도구 사용)
- 보조 신호가 필요하면 `ps -o comm= -p $PPID`로 부모 프로세스 정도만 참고한다. 프로세스명 단독 판별은 셸 래핑에 따라 흔들리므로 env var를 1순위로 둔다.

## 유스케이스별 도구 선택

| 작업 | Orca 환경 | cmux 환경 | 기본 환경 |
|------|-----------|-----------|-----------|
| 브라우저 제어 | `orca` CLI(아래 참고) | `cmux browser ...`(아래 참고) | Codex 내장 Browser Plugin |
| 에이전트 위임/핸드오프 | `orca-cli`/Orca orchestration 있으면 worktree·terminal 생성으로 위임 | 별도 위임 CLI가 없으면 로컬 fallback | 사용 가능한 위임 도구를 `tool_search`로 탐색 후 사용, 없으면 로컬 fallback |

로컬 fallback: 자동 위임 도구가 없는 환경에서는 git worktree + 셸 subprocess + 명확한 프롬프트/명령으로 수동 위임을 구성하고, 그마저 불가능하면 사용자에게 보고한다. Codex에 항상 내장된 표준 위임 기능이 있다고 가정하지 않는다 — 환경/플러그인에 따라 다르다.

## Orca 환경 — 브라우저 제어
Orca는 워크트리·터미널을 관리하고 자체 내장 스크립트 가능 브라우저를 제공하는 macOS 앱이다. `orca` CLI(평면 서브커맨드, `orca browser ...` 아님)로 제어한다. `orca open`은 런타임 기동용이라 --url을 받지 않으니, 새 탭은 `tab create`로 연다:

```bash
orca tab create --url https://example.com --json   # 새 탭 열기 (browserPageId 반환)
orca snapshot --page <pageId>
orca goto --url https://example.com/login --page <pageId>
orca click --element e3 --page <pageId>
orca fill --element e5 --value "hello" --page <pageId>
orca eval --expression "document.title" --page <pageId>
```

## cmux 환경 — 브라우저 제어
cmux는 Ghostty 엔진 기반 macOS 터미널 앱으로, 내장 스크립트 가능 WebKit(`WKWebView`) 브라우저 판넬을 제공한다.

```bash
cmux browser open https://example.com
cmux browser surface:2 wait --load-state complete
cmux browser surface:2 snapshot --interactive --compact
cmux browser surface:2 get text "body"
cmux browser surface:2 eval "document.title"
```

## 둘 다 아닐 때 — 브라우저 제어
Codex에 기본 내장된 Browser Plugin을 사용한다 (config.toml에도 이미 Chrome/브라우저 플러그인이 다른 대안보다 우선하도록 설정돼 있음).
