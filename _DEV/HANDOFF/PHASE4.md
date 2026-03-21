# Phase 4 — 스니펫 CRUD + 클립보드 + 메모→스니펫 전환

## 1. SnippetService (`Services/SnippetService.swift`)

| 메서드 | 동작 |
|---|---|
| `fetchSnippets(orgId:)` | org_id 기준 조회, created_at 내림차순 |
| `createSnippet(userId:orgId:title:content:)` | 스니펫 생성 |
| `updateSnippet(id:title:content:)` | 제목/내용 수정 |
| `deleteSnippet(id:)` | 스니펫 삭제 |
| `subscribe(orgId:...)` | Realtime 구독 (INSERT/UPDATE/DELETE) |
| `unsubscribe()` | Realtime 해제 |

- MemoService와 동일한 패턴
- `JSONDecoder.supabaseDecoder` 공유 (MemoService에서 `internal`로 변경)

## 2. SnippetViewModel (`Views/Main/SnippetViewModel.swift`)

- `@MainActor`, `ObservableObject`
- `snippets: [Snippet]` 상태 관리
- `setup(userId:orgId:)` → 초기 로드 + Realtime 시작
- `createFromMemo(title:content:)` → 메모→스니펫 전환용
- Realtime 이벤트 → 로컬 배열 즉시 반영

## 3. SnippetZoneView 실데이터 연동

- 목업 데이터 (`SnippetItem`) 완전 제거
- `SnippetViewModel` 연동
- hover 시 편집(pencil)/삭제(trash) 버튼 노출
- 인라인 편집 폼 (제목+내용 → 저장/취소)
- 복사 버튼 유지 (클립보드 복사 + "복사됨" 0.8초 피드백)

## 4. 메모→스니펫 전환

- `MemoRowView`에 pin 아이콘 버튼 추가 (hover/펼침 시 노출)
- 클릭 시 해당 메모의 title+content로 Snippet 생성
- 원본 메모는 유지 (삭제 안 함)
- 스니펫 존 상단에 바로 반영

## 5. MainView 연동

- `SnippetViewModel`을 `MainView`에서 `@StateObject`로 생성
- `SnippetZoneView`와 `MemoZoneView` 양쪽에 주입
- `onAppear`에서 `setup(userId:orgId:)` 호출

## 주요 파일

| 파일 | 변경 |
|---|---|
| `Services/SnippetService.swift` | 신규 — 스니펫 CRUD + Realtime |
| `Services/MemoService.swift` | 수정 — JSONDecoder 접근제어 internal로 변경 |
| `Views/Main/SnippetViewModel.swift` | 신규 — 스니펫 상태 관리 |
| `Views/Main/SnippetZoneView.swift` | 수정 — 목업 제거, 실데이터 + 편집/삭제 |
| `Views/Main/MemoRowView.swift` | 수정 — pin 버튼(스니펫 전환) 추가 |
| `Views/Main/MemoZoneView.swift` | 수정 — snippetViewModel 주입 |
| `Views/Main/MainView.swift` | 수정 — SnippetViewModel 생성 + 양쪽 주입 |
