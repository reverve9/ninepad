# NinePAD 배포 체크리스트

## 사전 요구사항

- [ ] Apple Developer 계정 (유료)
- [ ] Developer ID Application 인증서 생성
- [ ] App-specific password 생성 (appleid.apple.com → 보안)
- [ ] `create-dmg` 설치 (선택): `brew install create-dmg`

## 환경변수 설정

```bash
export APPLE_ID="your@email.com"
export TEAM_ID="YOUR_TEAM_ID"
export APP_PASSWORD="xxxx-xxxx-xxxx-xxxx"
export SIGNING_ID="Developer ID Application: Your Name (TEAM_ID)"
```

## Xcode 설정 확인

- [ ] Signing & Capabilities → Team 선택
- [ ] Signing → Developer ID Application 인증서
- [ ] Hardened Runtime 활성화
- [ ] Entitlements 확인:
  - `com.apple.security.app-sandbox` = YES
  - `com.apple.security.network.client` = YES
  - `keychain-access-groups`
  - `com.apple.security.files.user-selected.read-write`

## 빌드 & 배포

```bash
cd /Volumes/NINE_DEV/PROJECT/NinePAD
./_DEV/scripts/build_dmg.sh
```

순서: Archive → Export → Codesign 검증 → 공증(Notarize) → Staple → DMG 생성

## 배포 후 확인

- [ ] DMG 마운트 후 앱 실행
- [ ] Gatekeeper 경고 없이 실행되는지 확인
- [ ] 메뉴바에 아이콘 표시
- [ ] Cmd+Shift+N 단축키 동작
- [ ] Supabase 연결 정상
- [ ] 로그인/가입 동작
