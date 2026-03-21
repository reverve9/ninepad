# Phase 6 — Git 푸시 + .dmg 배포

## 1. GitService (`Services/GitService.swift`)

| 메서드 | 동작 |
|---|---|
| `pushMemo(_:)` | 메모 단건 → 마크다운 → clone → commit → push |
| `pushAllMemos(_:)` | 전체 메모 일괄 푸시 |
| `testConnection()` | git ls-remote로 연결 테스트 |
| `memoToMarkdown(_:)` | frontmatter(title/date/updated) + content |
| `markdownFileName(_:)` | 공백 → 언더스코어, .md 확장자 |

- GitHub PAT를 URL에 삽입하여 인증 (`https://token@github.com/...`)
- 임시 디렉토리에 shallow clone → 파일 쓰기 → push → 정리
- `Process`로 git CLI 실행

## 2. KeychainHelper (`Services/KeychainHelper.swift`)

- `save(key:value:)` / `load(key:)` / `delete(key:)`
- Generic Password, bundleID 기반 서비스명
- Git repo URL, PAT를 Keychain에 안전 저장

## 3. GitSettingsView (`Views/Settings/GitSettingsView.swift`)

- 레포 URL 입력 → Keychain 저장
- PAT 입력 (SecureField) → Keychain 저장
- 연결 테스트 버튼 → 성공/실패 표시
- SettingsView에 Git 섹션으로 추가

## 4. 메모 → Git 푸시 UI

- **MemoRowView**: hover/펼침 시 `arrow.up.to.line` 아이콘 (pin 옆)
- **MemoZoneView 하단바**: 전체 푸시 버튼 (admin만, 체크마크 피드백)
- 푸시 중 로딩, 성공 시 0.8초 피드백

## 5. 마크다운 변환

```markdown
---
title: {title}
date: {created_at ISO8601}
updated: {updated_at ISO8601}
---

{content}
```
파일명: `{title}.md` (공백 → `_`)

## 6. .dmg 배포

### 빌드 스크립트 (`_DEV/scripts/build_dmg.sh`)
1. Archive (Release)
2. Export (Developer ID)
3. Codesign 검증
4. 공증 (`xcrun notarytool`)
5. Staple
6. DMG 생성 (`create-dmg` 또는 `hdiutil`)

### 환경변수 (하드코딩 금지)
- `APPLE_ID`, `TEAM_ID`, `APP_PASSWORD`, `SIGNING_ID`

### Entitlements 업데이트
- Keychain 접근 추가
- 파일 시스템 접근 (임시 디렉토리)

### 배포 체크리스트 (`_DEV/SEED/DEPLOY_CHECKLIST.md`)

## 주요 파일

| 파일 | 변경 |
|---|---|
| `Services/GitService.swift` | 신규 |
| `Services/KeychainHelper.swift` | 신규 |
| `Views/Settings/GitSettingsView.swift` | 신규 |
| `_DEV/scripts/build_dmg.sh` | 신규 |
| `_DEV/scripts/ExportOptions.plist` | 신규 |
| `_DEV/SEED/DEPLOY_CHECKLIST.md` | 신규 |
| `Views/Settings/SettingsView.swift` | 수정 — Git 섹션 추가 |
| `Views/Main/MemoRowView.swift` | 수정 — Git 푸시 버튼 |
| `Views/Main/MemoZoneView.swift` | 수정 — 전체 푸시 + pushMemo 함수 |
| `NinePAD.entitlements` | 수정 — Keychain + 파일 접근 |
