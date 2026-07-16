# 실행 환경 인식

너는 지금 **Antigravity CLI(agy)**로 동작 중이다.

브라우저 제어, 에이전트 위임/핸드오프처럼 실행 환경에 따라 방법이 달라지는 작업이 필요해지는 그 순간에, 먼저 환경을 감지해서 아래 표에 맞는 방식을 쓴다. 세션 시작 시 매번 감지할 필요는 없다 — 불필요한 셸 호출이다.

## 감지 순서
1. 환경변수 확인: `ORCA_WORKSPACE_ID` 또는 `TERM_PROGRAM=Orca` → **Orca 환경**
2. 환경변수 확인: `CMUX_` 접두사(예: `CMUX_WORKSPACE_ID`) → **cmux 환경**
3. 둘 다 없으면 → **기본 환경** (agy 내장 도구 사용), 애매하면 사용자에게 어떤 터미널 앱인지 확인
- 보조 신호가 필요하면 `ps -o comm= -p $PPID`로 부모 프로세스 정도만 참고한다. tty/pwd는 판별 근거로 쓰지 않는다.

## 유스케이스별 도구 선택

| 작업 | Orca 환경 | cmux 환경 | 기본 환경 |
|------|-----------|-----------|-----------|
| 브라우저 제어 | `orca` CLI(아래 참고) | `cmux browser ...`(아래 참고) | agy 자체 내장 웹 검색/페치, `/browser` 서브에이전트 |
| 에이전트 위임/핸드오프 | `orca` CLI로 worktree·terminal 생성(`orca worktree create --agent`/`orca terminal create --command`) | 별도 위임 CLI가 없으면 로컬 fallback | `invoke_subagent`/`define_subagent`로 동적 서브에이전트 위임, 또는 `run_command`+`manage_task`로 프로세스 위임 |

로컬 fallback: 위임 도구가 마땅치 않은 환경에서는 git worktree + 셸 subprocess + 명확한 프롬프트로 수동 위임을 구성하거나, 자동 위임이 불가능하면 사용자에게 그대로 보고한다.

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
agy 자체에 내장된 웹 검색/페치 도구나 `/browser` 서브에이전트를 사용한다. 그마저 부적합하면(인증 필요, JS 렌더링 필요 등) 사용자에게 어떤 환경인지 확인한다.
