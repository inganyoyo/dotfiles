# 웹브라우저 통신 규칙 — 실행 환경부터 감지

웹브라우저 통신(웹페이지 보기, 테스트, 제어 등)이 요청되면 먼저 현재 세션이 어떤 터미널/앱 환경에서 실행 중인지 감지한 뒤 그 환경의 네이티브 브라우저 도구를 사용한다.

## 감지 방법
- `ORCA_WORKSPACE_ID` 환경변수가 있거나 `TERM_PROGRAM=Orca`이면 → **Orca 환경**
- `CMUX_` 접두사 환경변수(예: `CMUX_WORKSPACE_ID`)가 있으면 → **cmux 환경**
- 둘 다 없으면 agy(Antigravity CLI) 자체 내장 웹 도구(웹 검색/페치, `/browser` 서브에이전트 등)를 사용하고, 필요하면 사용자에게 어떤 터미널 앱인지 확인한다.

## Orca 환경
Orca는 워크트리·터미널을 관리하고 자체 내장 스크립트 가능 브라우저를 제공하는 macOS 앱이다. `orca` CLI(평면 서브커맨드, `orca browser ...` 아님)로 제어한다. `orca open`은 런타임 기동용이라 --url을 받지 않으니, 새 탭은 `tab create`로 연다:

```bash
orca tab create --url https://example.com --json   # 새 탭 열기 (browserPageId 반환)
orca snapshot --page <pageId>
orca goto --url https://example.com/login --page <pageId>
orca click --element e3 --page <pageId>
orca fill --element e5 --value "hello" --page <pageId>
orca eval --expression "document.title" --page <pageId>
```

## cmux 환경
cmux는 Ghostty 엔진 기반 macOS 터미널 앱으로, 내장 스크립트 가능 WebKit(`WKWebView`) 브라우저 판넬을 제공한다.

```bash
cmux browser open https://example.com
cmux browser surface:2 wait --load-state complete
cmux browser surface:2 snapshot --interactive --compact
cmux browser surface:2 get text "body"
cmux browser surface:2 eval "document.title"
```

## 둘 다 아닐 때
agy 자체에 내장된 웹 검색/페치 도구나 `/browser` 서브에이전트를 사용한다. 그마저 부적합하면(인증 필요, JS 렌더링 필요 등) 사용자에게 어떤 환경인지 확인한다.
