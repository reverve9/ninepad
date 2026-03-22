# NinePAD — Handoff

## 프로젝트 구조

```
NinePAD/
├── _DEV/
│   ├── HANDOFF/
│   │   ├── HANDOFF.md             ← 이 파일 (인덱스)
│   │   ├── PHASE1.md ~ PHASE6.md
│   ├── PROMPTS/                   ← 빌드 에러 등 프롬프트 파일
│   ├── SCREENSHOTS/
│   ├── SEED/
│   │   ├── schema.sql
│   │   └── DEPLOY_CHECKLIST.md
│   └── scripts/
│       ├── build_dmg.sh
│       └── ExportOptions.plist
├── NinePAD.xcodeproj/
├── NinePAD/
│   ├── App/
│   │   ├── NinePADApp.swift       ← @main, 로그인 Window + MenuBarExtra + 단축키
│   │   └── ContentView.swift      ← 팝오버 메인 (계정바 + MainView)
│   ├── Views/
│   │   ├── Auth/
│   │   │   ├── LoginView.swift
│   │   │   ├── SignUpView.swift
│   │   │   └── AuthViewModel.swift
│   │   ├── Main/
│   │   │   ├── MainView.swift
│   │   │   ├── SnippetZoneView.swift
│   │   │   ├── MemoZoneView.swift
│   │   │   ├── MemoRowView.swift
│   │   │   ├── MemoViewModel.swift
│   │   │   └── SnippetViewModel.swift
│   │   └── Settings/
│   │       ├── SettingsView.swift
│   │       ├── OrgSettingsView.swift
│   │       ├── ProfileView.swift
│   │       └── GitSettingsView.swift
│   ├── Services/
│   │   ├── SupabaseManager.swift
│   │   ├── AuthService.swift
│   │   ├── MemoService.swift
│   │   ├── SnippetService.swift
│   │   ├── InvitationService.swift
│   │   ├── OrgService.swift
│   │   ├── GitService.swift
│   │   └── KeychainHelper.swift
│   ├── Models/
│   │   └── AppModels.swift
│   ├── Config/
│   │   └── Config.swift
│   ├── Theme/
│   │   └── AppTheme.swift
│   ├── Assets.xcassets/
│   ├── Info.plist
│   └── NinePAD.entitlements
```

## 프로젝트 정보

- **타겟**: macOS 14+, SwiftUI, 메뉴바 전용 (Dock 아이콘 없음)
- **의존성**: `supabase-swift` 2.0+ (SPM)
- **Supabase**: `ujfjduravztyssnaewxb` 프로젝트 연결 완료
- **관리자 인증코드**: `bridge_nine`
- **개인 계정**: `reverve9`
- **URL Scheme**: `ninepad://`

## 페이즈 현황

| Phase | 상태 | 문서 | 요약 |
|---|---|---|---|
| 1 | 완료 | [PHASE1.md](PHASE1.md) | 프로젝트 기초 + Supabase 스키마 + 인증 |
| 2 | 완료 | [PHASE2.md](PHASE2.md) | 메뉴바 + 메인 UI 골격 + 다크 테마 |
| 3 | 완료 | [PHASE3.md](PHASE3.md) | 메모 CRUD + Supabase 실시간 동기화 |
| 4 | 완료 | [PHASE4.md](PHASE4.md) | 스니펫 CRUD + 클립보드 + 메모→스니펫 |
| 5 | 완료 | [PHASE5.md](PHASE5.md) | Org 관리 + 초대 링크 |
| 6 | 완료 | [PHASE6.md](PHASE6.md) | Git 푸시 + .dmg 배포 |

## _DEV 폴더 규칙

| 폴더 | 용도 |
|---|---|
| `_DEV/HANDOFF/` | 핸드오프 문서 (페이즈별 분리) |
| `_DEV/PROMPTS/` | 빌드 에러 수정 등 프롬프트 파일 |
| `_DEV/SCREENSHOTS/` | UI 스크린샷 공유 |
| `_DEV/SEED/` | SQL 스키마, 시드 데이터, 배포 체크리스트 |
| `_DEV/scripts/` | 빌드/배포 스크립트 |
