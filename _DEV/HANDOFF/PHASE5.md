# Phase 5 — Org 관리 + 초대 링크

## 1. InvitationService (`Services/InvitationService.swift`)

| 메서드 | 동작 |
|---|---|
| `createInvitation(orgId:email:)` | 초대 생성 (DB에서 토큰 자동 생성, 7일 만료) |
| `fetchInvitations(orgId:)` | org 초대 목록 조회 |
| `revokeInvitation(id:)` | 초대 취소 (삭제) |
| `validateInvitation(token:)` | 토큰 유효성 검증 (만료/수락 체크) |
| `acceptInvitation(token:)` | 초대 수락 (accepted_at 업데이트) |

## 2. OrgService (`Services/OrgService.swift`)

| 메서드 | 동작 |
|---|---|
| `fetchMembers(orgId:)` | org 멤버 목록 조회 |
| `removeMember(userId:)` | 멤버 제거 (admin 전용) |
| `updateMemberRole(userId:role:)` | 역할 변경 (admin ↔ member) |
| `fetchOrganization(orgId:)` | org 정보 조회 |

## 3. 설정 뷰

### SettingsView (`Views/Settings/SettingsView.swift`)
- 설정 진입점 — ProfileView + OrgSettingsView(admin) 또는 memberOrgInfo(member)
- 340x500, 팝오버 배경 테마

### ProfileView (`Views/Settings/ProfileView.swift`)
- 이메일 + 역할 배지 표시
- 로그아웃 버튼

### OrgSettingsView (`Views/Settings/OrgSettingsView.swift`)
- **멤버 섹션**: 이메일 + 역할 배지 + 역할 변경/제거 (본인 제외)
- **초대 섹션**: 이메일 입력 → 초대 생성 → 링크 복사 (`ninepad://invite?token=xxx`)
- 대기 중 초대 목록: 이메일 + 만료일 + 링크 복사/취소

## 4. 초대 링크 처리 (URL Scheme)

- `Info.plist`에 `ninepad://` URL Scheme 등록
- `NinePADApp.onOpenURL` → 토큰 파싱 → `authService.pendingInviteToken` 설정
- `LoginView` → pendingInviteToken 감지 시 자동으로 SignUpView 시트 열기
- `SignUpView` → pendingInviteToken 감지 시 초대 탭 선택 + 토큰 자동 입력

## 5. 하단바 설정 버튼

- MemoZoneView 하단바 우측에 gear 아이콘 추가
- 클릭 시 SettingsView 시트 표시
- 메모 개수는 중앙 유지

## 6. 권한 처리

- admin 전용 UI (OrgSettingsView)는 `authService.currentUser.role` 체크
- RLS가 서버에서 이미 격리하므로 UI는 UX 목적
- member는 "Org 관리는 관리자만 가능합니다" 안내 표시

## 주요 파일

| 파일 | 변경 |
|---|---|
| `Services/InvitationService.swift` | 신규 |
| `Services/OrgService.swift` | 신규 |
| `Views/Settings/SettingsView.swift` | 신규 |
| `Views/Settings/OrgSettingsView.swift` | 신규 |
| `Views/Settings/ProfileView.swift` | 신규 |
| `Services/AuthService.swift` | 수정 — pendingInviteToken 추가 |
| `App/NinePADApp.swift` | 수정 — onOpenURL 처리 |
| `Info.plist` | 수정 — CFBundleURLSchemes 추가 |
| `Views/Auth/LoginView.swift` | 수정 — pendingInviteToken 감지 |
| `Views/Auth/SignUpView.swift` | 수정 — 자동 초대 탭 전환 |
| `Views/Main/MemoZoneView.swift` | 수정 — 하단바 gear 아이콘 |
