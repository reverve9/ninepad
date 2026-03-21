# NinePAD — Phase 1 Handoff

## 프로젝트 구조

```
NinePAD/
├── _DEV/                          ← 개발 공유 리소스
│   ├── HANDOFF/
│   │   └── HANDOFF.md             ← 이 파일
│   ├── SCREENSHOTS/               ← 스크린샷 공유 폴더
│   └── SEED/
│       └── schema.sql             ← Supabase 전체 스키마 + RLS
├── NinePAD.xcodeproj/
├── NinePAD/
│   ├── App/
│   │   ├── NinePADApp.swift       ← @main, MenuBarExtra 진입점
│   │   └── ContentView.swift      ← 로그인/메인 분기
│   ├── Views/Auth/
│   │   ├── LoginView.swift        ← 이메일+비밀번호 로그인
│   │   ├── SignUpView.swift       ← 관리자/초대 가입 UI
│   │   └── AuthViewModel.swift    ← 확장용 예약 파일
│   ├── Services/
│   │   ├── SupabaseManager.swift  ← Supabase 싱글턴 클라이언트
│   │   └── AuthService.swift      ← 로그인/가입/로그아웃 로직
│   ├── Models/
│   │   └── AppModels.swift        ← Organization, AppUser, Memo, Snippet, Invitation
│   ├── Config/
│   │   └── Config.swift           ← Supabase URL/Key, 관리자 코드
│   ├── Assets.xcassets/
│   ├── Info.plist                  ← LSUIElement = YES
│   └── NinePAD.entitlements       ← 샌드박스 + 네트워크
```

- **타겟**: macOS 14+
- **LSUIElement**: YES (Dock 아이콘 없음, 메뉴바만)
- **의존성**: `supabase-swift` 2.0+ (SPM)

---

## Phase 1 완료 항목

### 1. Supabase 스키마

`_DEV/SEED/schema.sql` 파일을 Supabase SQL Editor에서 실행합니다.

| 테이블 | 설명 |
|---|---|
| `organizations` | 조직 (멀티테넌트 루트) |
| `users` | 사용자 (org_id로 조직 소속) |
| `memos` | 메모 (org 격리) |
| `snippets` | 스니펫 (org 격리) |
| `invitations` | 초대 (토큰 기반, 7일 만료) |

**RLS 정책 요약:**
- 모든 테이블에 RLS 활성화
- SELECT: 같은 org 멤버만 조회 가능
- INSERT/UPDATE/DELETE: 본인 데이터만 조작 가능
- 초대 생성: admin 역할만 가능
- org 격리 완전 적용 (서브쿼리로 org_id 검증)

### 2. 인증 흐름

| 시나리오 | 흐름 |
|---|---|
| **관리자 가입** | 이메일+비밀번호+조직이름+관리자코드 → Org 생성 → users에 admin 등록 |
| **멤버 가입** | 초대 토큰+이메일+비밀번호 → 토큰 검증 → users에 member 등록 → 초대 수락 처리 |
| **로그인** | 이메일+비밀번호 → 세션 획득 → users 프로필 로드 |

---

## 시작 전 설정

1. **Supabase 프로젝트 생성** 후 `NinePAD/Config/Config.swift`에 값 입력:
   ```swift
   static let supabaseURL = "https://YOUR_PROJECT.supabase.co"
   static let supabaseAnonKey = "YOUR_ANON_KEY"
   ```

2. **SQL 실행**: `_DEV/SEED/schema.sql` → Supabase Dashboard → SQL Editor에서 실행

3. **Xcode에서 열기**: `NinePAD.xcodeproj` → SPM 패키지 resolve → 빌드

---

## _DEV 폴더 규칙

| 폴더 | 용도 |
|---|---|
| `_DEV/HANDOFF/` | 핸드오프 문서 (페이즈별 업데이트) |
| `_DEV/SCREENSHOTS/` | UI 스크린샷 공유 |
| `_DEV/SEED/` | SQL 스키마, 시드 데이터, 마이그레이션 쿼리 |

---

## Phase 2 예정 (별도 지시 대기)
- 메뉴바 + 글로벌 단축키
- 상단 스니펫 / 하단 메모 레이아웃
- 네이비 다크 테마 시스템
