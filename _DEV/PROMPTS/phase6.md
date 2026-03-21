NinePAD Phase 6 시작해줘.
HANDOFF.md, PHASE5.md 기준으로 프로젝트 파악하고 진행해.

# Phase 6 목표 — Git 푸시 + .dmg 배포

## 1. GitService 생성
- `Services/GitService.swift`
- 개인 GitHub 레포 URL 설정 (Config.swift에 gitRepoURL 추가)
- 메모 전체 또는 선택한 메모를 마크다운으로 변환
- 로컬 임시 디렉토리에 .md 파일 생성
- git add → commit → push 실행 (Process/Shell 활용)
- GitHub Personal Access Token 설정 (Config.swift에 gitToken 추가)
- 푸시 성공/실패 결과 반환

## 2. Git 설정 UI
- `Views/Settings/GitSettingsView.swift` 신규
- SettingsView에 Git 섹션 추가
- 레포 URL 입력 필드
- Personal Access Token 입력 필드 (SecureField)
- 연결 테스트 버튼
- 설정값은 Keychain에 저장 (UserDefaults 사용 금지)

## 3. 메모 → Git 푸시 UI
- MemoRowView 펼침 상태에서 "푸시" 버튼 추가
  → SF Symbol: arrow.up.to.line 아이콘
- 클릭 시 해당 메모 단건 푸시
- MemoZoneView 하단바에 "전체 푸시" 버튼 추가 (관리자만)
- 푸시 중 로딩 인디케이터
- 성공 시 "푸시 완료" 피드백 0.8초

## 4. 마크다운 변환 규칙
- 파일명: {title}.md (공백 → 언더스코어)
- 내용: 메모 content 그대로
- 상단 frontmatter 추가:
  ---
  title: {title}
  date: {created_at}
  updated: {updated_at}
  ---

## 5. .dmg 배포 준비
- Xcode Release 빌드 설정 확인
  - Code Signing: Apple Developer 계정 연결
  - Hardened Runtime 활성화
  - Entitlements 확인 (네트워크, Keychain)
- create-dmg 스크립트 작성 (_DEV/scripts/build_dmg.sh)
  - 앱 빌드 → 공증(notarize) → dmg 생성 순서
  - xcrun notarytool 사용
  - Apple ID, Team ID, App-specific password는
    환경변수로 처리 (스크립트에 하드코딩 금지)
- _DEV/SEED/에 배포 체크리스트 README 작성

## 범위 제한
- 자동 업데이트(Sparkle) X (추후)
- App Store 제출 X
- CI/CD X (추후)

## 파일 추가/수정 예상
- Services/GitService.swift (신규)
- Views/Settings/GitSettingsView.swift (신규)
- Views/Settings/SettingsView.swift (수정 — Git 섹션 추가)
- Views/Main/MemoRowView.swift (수정 — 푸시 버튼)
- Views/Main/MemoZoneView.swift (수정 — 전체 푸시 버튼)
- Config/Config.swift (수정 — gitRepoURL, gitToken 추가)
- _DEV/scripts/build_dmg.sh (신규)

Phase 6 완료 후 HANDOFF.md + PHASE6.md 작성해줘.
