# NinePAD — Handoff

## 프로젝트 구조

```
NinePAD/
├── _DEV/
│   ├── HANDOFF/
│   │   └── HANDOFF.md             ← 이 파일
│   ├── SCREENSHOTS/               ← 스크린샷 공유
│   └── SEED/
│       └── schema.sql             ← Supabase 스키마 + RLS
├── NinePAD.xcodeproj/
├── NinePAD/
│   ├── App/
│   │   ├── NinePADApp.swift       ← @main, MenuBarExtra + 글로벌 단축키
│   │   └── ContentView.swift      ← 로그인/메인 분기
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── LoginView.swift
│   │   │   ├── SignUpView.swift
│   │   │   └── AuthViewModel.swift
│   │   └── Main/
│   │       ├── MainView.swift         ← 스니펫존 + 메모존 조합
│   │       ├── SnippetZoneView.swift   ← 상단 스니펫 영역
│   │       ├── MemoZoneView.swift      ← 하단 메모 영역 + 검색
│   │       └── MemoRowView.swift       ← 아코디언 메모 행
│   ├── Services/
│   │   ├── SupabaseManager.swift
│   │   └── AuthService.swift
│   ├── Models/
│   │   └── AppModels.swift
│   ├── Config/
│   │   └── Config.swift
│   ├── Theme/
│   │   └── AppTheme.swift         ← 네이비 다크 테마 컬러 상수
│   ├── Assets.xcassets/
│   ├── Info.plist
│   └── NinePAD.entitlements
```

- **타겟**: macOS 14+, SwiftUI, 메뉴바 전용 (Dock 아이콘 없음)
- **의존성**: `supabase-swift` 2.0+ (SPM)
- **Supabase**: `ujfjduravztyssnaewxb` 프로젝트 연결 완료

---

## Phase 1 완료

### Supabase 스키마 (`_DEV/SEED/schema.sql`)

| 테이블 | 설명 |
|---|---|
| `organizations` | 조직 (멀티테넌트 루트) |
| `users` | 사용자 (org_id 소속, role: admin/member) |
| `memos` | 메모 (org 격리) |
| `snippets` | 스니펫 (org 격리) |
| `invitations` | 초대 (토큰 기반, 7일 만료) |

- RLS 전체 적용, org 격리 완전 적용

### 인증 흐름

| 시나리오 | 흐름 |
|---|---|
| **관리자 가입** | 인증코드(`bridge_nine`) → Org 생성 + admin 등록 |
| **멤버 직접가입** | (DEBUG 전용) 조직이름 입력 → 초대 없이 member 등록 |
| **초대 가입** | 초대 토큰 → 토큰 검증 → member 등록 |
| **로그인** | 이메일 + 비밀번호 → 세션 획득 → 프로필 로드 |

### 계정 구조

| 계정 | 역할 |
|---|---|
| `bridge_nine` | 관리자 인증코드 (Org 생성 권한) |
| `reverve9` | 개인 계정 (개발 중 멤버 직접가입) |

---

## Phase 2 완료

### 1. 메뉴바 + 글로벌 단축키
- `MenuBarExtra` + `.window` 스타일 팝오버
- **Cmd+Shift+N**: 어디서든 앱 호출/닫기 토글
- `AppDelegate`에서 Carbon `RegisterEventHotKey` 사용
- 팝오버 사이즈: 340 x 자동 (최대 600)

### 2. 메인 뷰 구조

```
┌─────────────────────────┐
│  SNIPPETS (bg #19202E)  │
│  ┌─ 타이틀 ─── [복사] ─┐ │
│  └──────────────────────┘ │
├─────────────────────────┤
│  🔍 메모 검색...         │
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

### 3. 테마 시스템 (`AppTheme.swift`)

| 토큰 | 값 | 용도 |
|---|---|---|
| `snippetZoneBg` | `#19202E` | 스니펫 영역 배경 |
| `memoZoneBg` | `#1E2535` | 메모 영역 배경 |
| `popoverBg` | `#141A26` | 팝오버 전체 배경 |
| `inputBg` | `#252D3D` | 검색바 등 입력 필드 |
| `accent` | `#4A9EFF` | 강조색 |
| `success` | `#34D399` | 복사 완료 등 |

---

## _DEV 폴더 규칙

| 폴더 | 용도 |
|---|---|
| `_DEV/HANDOFF/` | 핸드오프 문서 (페이즈별 업데이트) |
| `_DEV/SCREENSHOTS/` | UI 스크린샷 공유 |
| `_DEV/SEED/` | SQL 스키마, 시드 데이터, 마이그레이션 |

---

## Phase 3 예정 (별도 지시 대기)
- 메모 CRUD (생성/수정/삭제)
- 아코디언 인터랙션 고도화
- Supabase 실시간 동기화
