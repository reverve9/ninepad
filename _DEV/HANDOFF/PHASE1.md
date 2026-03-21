# Phase 1 — 프로젝트 기초 + Supabase 스키마 + 인증

## Supabase 스키마 (`_DEV/SEED/schema.sql`)

| 테이블 | 설명 |
|---|---|
| `organizations` | 조직 (멀티테넌트 루트) |
| `users` | 사용자 (org_id 소속, role: admin/member) |
| `memos` | 메모 (org 격리) |
| `snippets` | 스니펫 (org 격리) |
| `invitations` | 초대 (토큰 기반, 7일 만료) |

- RLS 전체 적용, org 격리 완전 적용
- SQL 실행 순서: 테이블 → 트리거 → RLS → 정책 → 인덱스

## 인증 흐름

| 시나리오 | 흐름 |
|---|---|
| **관리자 가입** | 인증코드(`bridge_nine`) → Org 생성 + admin 등록 |
| **멤버 직접가입** | (DEBUG 전용) 조직이름 입력 → 초대 없이 member 등록 |
| **초대 가입** | 초대 토큰 → 토큰 검증 → member 등록 |
| **로그인** | 이메일 + 비밀번호 → 세션 획득 → 프로필 로드 |

## 개발 모드 (`devMode`)

- `DEBUG` 빌드: 멤버 직접가입 탭 노출 (초대 없이 org 이름만으로 가입)
- `Release` 빌드: 탭 숨김, 초대 링크로만 멤버 가입 가능

## 주요 파일

| 파일 | 역할 |
|---|---|
| `Config/Config.swift` | Supabase URL/Key, 관리자 코드, devMode |
| `Services/SupabaseManager.swift` | Supabase 클라이언트 싱글턴 |
| `Services/AuthService.swift` | 로그인/가입/로그아웃 전체 로직 |
| `Models/AppModels.swift` | Organization, AppUser, Memo, Snippet, Invitation |
| `Views/Auth/LoginView.swift` | 로그인 화면 |
| `Views/Auth/SignUpView.swift` | 관리자/멤버/초대 가입 화면 |
