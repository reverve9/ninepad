# Phase 2 — 메인 UI 골격

## 1. 메뉴바 + 글로벌 단축키

- `MenuBarExtra` + `.window` 스타일 팝오버
- **Cmd+Shift+N**: 어디서든 앱 호출/닫기 토글
- `AppDelegate`에서 Carbon `RegisterEventHotKey` 사용
- 팝오버 사이즈: 340 x 자동 (최대 600)

## 2. 메인 뷰 구조

```
┌─────────────────────────┐
│  SNIPPETS (bg #19202E)  │
│  ┌─ 타이틀 ─── [복사] ─┐ │
│  └──────────────────────┘ │
├─────────────────────────┤
│  검색...                 │
│  MEMOS (bg #1E2535)     │
│  ▸ 메모 타이틀 1        │
│  ▾ 메모 타이틀 2        │
│    (펼쳐진 내용)         │
│  ▸ 메모 타이틀 3        │
├─────────────────────────┤
│  + 새 메모     4개 메모  │
└─────────────────────────┘
```

- **스니펫 존**: 타이틀 + 복사 버튼, 복사 시 "복사됨" 0.8초 후 복귀
- **메모 존**: 검색바 + 아코디언 리스트, 타이틀 클릭으로 펼침/접힘
- **하단바**: + 새 메모 버튼, 메모 개수 표시
- 현재 목업 데이터 사용 (Phase 3에서 Supabase 연동)

## 3. 테마 시스템 (`AppTheme.swift`)

| 토큰 | 값 | 용도 |
|---|---|---|
| `snippetZoneBg` | `#19202E` | 스니펫 영역 배경 |
| `memoZoneBg` | `#1E2535` | 메모 영역 배경 |
| `popoverBg` | `#141A26` | 팝오버 전체 배경 |
| `inputBg` | `#252D3D` | 검색바 등 입력 필드 |
| `accent` | `#4A9EFF` | 강조색 |
| `success` | `#34D399` | 복사 완료 등 |

## 주요 파일

| 파일 | 역할 |
|---|---|
| `App/NinePADApp.swift` | MenuBarExtra 진입점 + AppDelegate 글로벌 단축키 |
| `App/ContentView.swift` | 로그인/메인 분기 + 테마 배경 |
| `Theme/AppTheme.swift` | 네이비 다크 테마 컬러 상수 + Color hex 확장 |
| `Views/Main/MainView.swift` | 스니펫존 + 메모존 조합 |
| `Views/Main/SnippetZoneView.swift` | 스니펫 리스트 + 클립보드 복사 |
| `Views/Main/MemoZoneView.swift` | 검색바 + 메모 리스트 + 하단바 |
| `Views/Main/MemoRowView.swift` | 아코디언 펼침/접힘 행 |
