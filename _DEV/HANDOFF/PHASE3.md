# Phase 3 — 메모 CRUD + Supabase 실시간 동기화

## 1. MemoService (`Services/MemoService.swift`)

| 메서드 | 동작 |
|---|---|
| `fetchMemos(orgId:)` | org_id 기준 전체 조회, updated_at 내림차순 |
| `createMemo(userId:orgId:title:content:)` | 메모 생성 후 반환 |
| `updateMemo(id:title:content:)` | 제목/내용 수정 후 반환 |
| `deleteMemo(id:)` | 메모 삭제 |
| `subscribe(orgId:onInsert:onUpdate:onDelete:)` | Realtime 구독 (INSERT/UPDATE/DELETE) |
| `unsubscribe()` | Realtime 해제 |

- Supabase Realtime V2 채널 사용
- `org_id=eq.{orgId}` 필터로 해당 org 이벤트만 수신
- ISO8601 (fractional seconds 포함) 커스텀 디코더

## 2. MemoViewModel (`Views/Main/MemoViewModel.swift`)

- `@MainActor`, `ObservableObject`
- `memos: [Memo]` — 전체 메모 상태
- `filteredMemos` — searchText 기준 title/content 필터
- `isLoading`, `errorMessage` — 로딩/에러 상태
- `setup(userId:orgId:)` — 초기 로드 + Realtime 구독 시작
- Realtime 이벤트 → 로컬 배열 즉시 반영 (중복 방지)

## 3. 새 메모 작성

- 하단바 "+ 새 메모" 클릭 → 인라인 입력 폼 표시
- 제목 + 내용 입력
- 저장 / 취소 버튼
- 저장 시 Supabase에 INSERT → Realtime으로 동기화

## 4. 메모 수정 / 삭제

- **수정**: 펼침 상태에서 연필 아이콘 클릭 → 인라인 편집 폼
- **삭제**: hover 또는 펼침 시 휴지통 아이콘 노출 → 즉시 삭제
- 수정/삭제 결과 Realtime으로 다른 클라이언트에도 반영

## 5. 목업 데이터 제거

- `MemoItem` 구조체 및 `mockData` 삭제
- `MemoRowView`가 실제 `Memo` 모델 사용

## 주요 파일

| 파일 | 역할 |
|---|---|
| `Services/MemoService.swift` | Supabase 메모 CRUD + Realtime 구독 |
| `Views/Main/MemoViewModel.swift` | 메모 상태 관리 + 검색 필터 |
| `Views/Main/MemoZoneView.swift` | 메모 존 UI (검색 + 리스트 + 새 메모 폼) |
| `Views/Main/MemoRowView.swift` | 아코디언 행 (펼침/접힘 + 인라인 편집 + 삭제) |
