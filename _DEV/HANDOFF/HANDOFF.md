# NinePAD — Handoff

## 프로젝트 구조

```
NinePAD/
├── _DEV/
│   ├── HANDOFF/
│   │   ├── HANDOFF.md             ← 이 파일 (인덱스)
│   │   ├── PHASE1.md ~ PHASE6.md  ← 초기 개발 페이즈 기록
│   ├── PROMPTS/                   ← 빌드 에러 등 프롬프트 파일
│   ├── SCREENSHOTS/
│   ├── SEED/
│   │   ├── schema.sql             ← 초기 스키마
│   │   ├── seed_superadmin.sql    ← 슈퍼어드민 시드
│   │   ├── migration_*.sql        ← 마이그레이션 파일들
│   │   └── DEPLOY_CHECKLIST.md
│   └── scripts/
│       ├── build_dmg.sh
│       └── ExportOptions.plist
├── NinePAD.xcodeproj/
├── NinePAD/
│   ├── App/
│   │   ├── NinePADApp.swift       ← @main, 로그인/메인/노트 Window + 메뉴바 + 단축키
│   │   └── ContentView.swift      ← 메인 Window 콘텐츠 (앱바 + 상태 분기)
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── LoginView.swift    ← 탭바 (로그인/회원가입) + Nine Messenger 스타일
│   │   │   ├── SignUpView.swift   ← Org 생성 신청 / 멤버 / 초대 가입
│   │   │   └── AuthViewModel.swift
│   │   ├── Main/
│   │   │   ├── MainView.swift     ← 노트 존 + 하단 설정 툴바
│   │   │   ├── MemoZoneView.swift ← 노트 리스트 (검색 + 핀 정렬)
│   │   │   ├── MemoRowView.swift  ← 노트 행 (컬러도트/핀 + 날짜 + hover 액션)
│   │   │   ├── MemoDetailView.swift ← 노트 상세 창 (읽기/편집 모드)
│   │   │   └── MemoViewModel.swift  ← 노트 상태관리 + Realtime + 핀 정렬
│   │   └── Settings/
│   │       ├── SettingsView.swift    ← 설정 진입점
│   │       ├── ProfileView.swift     ← 프로필 + 로그아웃
│   │       ├── OrgApprovalView.swift ← 슈퍼어드민 Org 승인/거절
│   │       ├── OrgSettingsView.swift ← Org 멤버/초대 관리 (admin)
│   │       ├── TrashView.swift       ← 휴지통 (복원/영구삭제)
│   │       └── GitSettingsView.swift ← Git 레포/토큰 설정
│   ├── Services/
│   │   ├── SupabaseManager.swift  ← Supabase 클라이언트 싱글턴
│   │   ├── AuthService.swift      ← 로그인/가입/로그아웃 + 슈퍼어드민
│   │   ├── MemoService.swift      ← 노트 CRUD + 핀 토글 + 소프트딜리트 + Realtime
│   │   ├── InvitationService.swift ← 초대 CRUD
│   │   ├── OrgService.swift       ← Org/멤버 관리 + 승인/거절
│   │   ├── GitService.swift       ← 노트→마크다운 Git 푸시
│   │   └── KeychainHelper.swift   ← Keychain 저장/로드
│   ├── Models/
│   │   └── AppModels.swift        ← UserRole, OrgStatus, Organization, AppUser, Memo, Snippet, Invitation
│   ├── Config/
│   │   └── Config.swift           ← Supabase URL/Key, devMode
│   ├── Theme/
│   │   └── AppTheme.swift         ← Nine Messenger 라이트 테마 + 사이즈 토큰
│   ├── Assets.xcassets/
│   ├── Info.plist                  ← LSUIElement + URL Scheme (ninepad://)
│   └── NinePAD.entitlements       ← Keychain + 파일시스템 접근
```

## 프로젝트 정보

- **타겟**: macOS 14+, SwiftUI, 메뉴바 상주 (LSUIElement)
- **의존성**: `supabase-swift` 2.0+ (SPM)
- **Supabase**: `ujfjduravztyssnaewxb` 프로젝트
- **테마**: Nine Messenger 라이트 모드 (#FFFFFF 배경, #1C2B4A 네이비)
- **URL Scheme**: `ninepad://invite?token=xxx`

## 앱 구조

### Window 구성
| Window | 크기 | 용도 |
|---|---|---|
| 로그인 | 400×540 | 로그인/회원가입 (탭바 전환) |
| 메인 | 380×520 | 노트 리스트 + 설정 |
| 노트 상세 | 360×420 | 노트 읽기/편집 (독립 창, 복수 가능) |
| 메뉴바 | .menu | 열기/로그아웃/종료 |

### 인증 흐름
| 시나리오 | 흐름 |
|---|---|
| **Org 생성 신청** | 이메일+비밀번호+조직명 → pending Org 생성 → 슈퍼어드민 승인 대기 |
| **멤버 직접가입** | (DEBUG) 이메일+비밀번호+조직명 → 바로 member 등록 |
| **초대 가입** | 초대 토큰+이메일+비밀번호 → member 등록 |
| **슈퍼어드민** | Org 없이 로그인 → "내 Org 만들기" → approved 즉시 활성화 |

### 노트 기능
- **핀 고정**: 핀된 노트 리스트 상단 정렬, pin.fill 아이콘
- **컬러 도트**: 6색 선택 (네이비/빨강/주황/초록/파랑/보라)
- **소프트 딜리트**: 휴지통으로 이동 → 설정에서 복원/영구삭제
- **Realtime**: Supabase Realtime V2로 실시간 동기화
- **Git 푸시**: 노트→마크다운 변환 후 GitHub 레포에 푸시

### 권한 체계
| 역할 | 권한 |
|---|---|
| `superadmin` | 전체 Org 승인/거절, 모든 유저 조회 |
| `admin` | 자기 Org 멤버/초대 관리, 전체 노트 Git 푸시 |
| `member` | 자기 노트 CRUD |

### RLS (Row Level Security)
- `SECURITY DEFINER` 함수로 무한 재귀 방지
- `auth_user_org_id()`, `auth_user_role()` 함수 사용
- 본인 레코드 항상 조회 가능 (`users_select_self`)

## 미사용 파일 (제거 대상)
- `Views/Main/SnippetZoneView.swift` — 스니펫 존 제거됨
- `Views/Main/SnippetViewModel.swift` — 스니펫 뷰모델 제거됨
- `Services/SnippetService.swift` — 스니펫 서비스 제거됨
- `Views/Auth/AuthViewModel.swift` — 미사용 예약 파일

## DB 마이그레이션 순서
1. `schema.sql` — 초기 테이블 + RLS
2. `migration_superadmin.sql` — superadmin 역할 + org status
3. `migration_fix_rls_v3.sql` — SECURITY DEFINER 함수로 RLS 수정
4. `seed_superadmin.sql` — 슈퍼어드민 계정 등록
5. `migration_color_dot.sql` — color_dot 컬럼
6. `migration_soft_delete.sql` — deleted_at 컬럼
7. `migration_pin.sql` — is_pinned 컬럼
8. `migration_realtime.sql` — Realtime Publication 활성화

## _DEV 폴더 규칙

| 폴더 | 용도 |
|---|---|
| `_DEV/HANDOFF/` | 핸드오프 문서 |
| `_DEV/PROMPTS/` | 빌드 에러/기능 요청 프롬프트 |
| `_DEV/SCREENSHOTS/` | UI 스크린샷 공유 |
| `_DEV/SEED/` | SQL 스키마, 마이그레이션, 시드, 배포 체크리스트 |
| `_DEV/scripts/` | 빌드/배포 스크립트 |
