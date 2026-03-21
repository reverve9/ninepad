빌드 에러 수정해줘. 두 파일 문제야.

# 1. SettingsView.swift — 24번째 줄
"Extra argument 'maxHeight' in call"

.frame(width: 340, maxHeight: 500) 에러
아래처럼 수정:
.frame(maxWidth: 340, maxHeight: 500)

# 2. InvitationService.swift — 에러 3개

revokeInvitation 수정:
try await client
    .from("invitations")
    .delete()
    .eq("id", value: id.uuidString)
    .execute()

validateInvitation .is() null 체크 수정:
.filter("accepted_at", operator: .is, value: AnyJSON.null)

MemoService, SnippetService, OrgService도 동일 패턴 에러 있으면 일괄 수정.
빌드 성공까지 확인해줘.
