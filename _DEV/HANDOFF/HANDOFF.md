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
│   │   ├── NinePADApp.swift       ← @main, MenuBarExtra 진입점
│   │   └── ContentView.swift      ← 로그인/메인 분기
│   ├── Views/Auth/
│   │   ├── LoginView.swift        ← 이메일+비밀번호 로그인
│   │   ├── SignUpView.swift       ← 관리자/멤버/초대 가입 UI
│   │   └── AuthViewModel.swift    ← 확장용 예약
│   ├── Services/
│   │   ├── SupabaseManager.swift  ← Supabase 싱글턴
│   │   └── AuthService.swift      ← 인증 로직 전체
│   ├── Models/
│   │   └── AppModels.swift        ← 전체 데이터 모델
│   ├── Config/
│   │   └── Config.swift           ← Supabase 연결 + 설정
│   ├── Assets.xcassets/
│   ├── Info.plist                  ← LSUIElement = YES
│   └── NinePAD.entitlements       ← 샌드박스 + 네트워크
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
- SQL 실행 순서: 테이블 → 트리거 → RLS → 정책 → 인덱스

### 인증 흐름

| 시나리오 | 흐름 |
|---|---|
| **관리자 가입** | 이메일 + 비밀번호 + 조직이름 + 인증코드(`bridge_nine`) → Org 생성 + admin 등록 |
| **멤버 직접가입** | (DEBUG 전용) 이메일 + 비밀번호 + 조직이름 → 초대 없이 member 등록 |
| **초대 가입** | 초대 토큰 + 이메일 + 비밀번호 → 토큰 검증 → member 등록 |
| **로그인** | 이메일 + 비밀번호 → 세션 획득 → 프로필 로드 |

### 개발 모드 (`devMode`)

- `DEBUG` 빌드: 멤버 직접가입 탭 노출 (초대 없이 org 이름만으로 가입)
- `Release` 빌드: 탭 숨김, 초대 링크로만 멤버 가입 가능

### 계정 구조

| 계정 | 역할 | 비고 |
|---|---|---|
| `bridge_nine` | 관리자 인증코드 | Org 생성 권한 |
| `reverve9` | 개인 계정 | 개발 중 멤버 직접가입으로 참여 |

---

## _DEV 폴더 규칙

| 폴더 | 용도 |
|---|---|
| `_DEV/HANDOFF/` | 핸드오프 문서 (페이즈별 업데이트) |
| `_DEV/SCREENSHOTS/` | UI 스크린샷 공유 |
| `_DEV/SEED/` | SQL 스키마, 시드 데이터, 마이그레이션 |

---

## Phase 2 예정 (별도 지시 대기)
- 메뉴바 + 글로벌 단축키
- 상단 스니펫 / 하단 메모 레이아웃
- 네이비 다크 테마 시스템
