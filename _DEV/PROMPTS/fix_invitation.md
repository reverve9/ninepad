InvitationService.swift 빌드 에러 수정해줘.

# 현재 에러 상황 (49번째 줄)
"Type 'String' has no member 'is'"

.filter("accepted_at", operator: .is, value: "null")  ← 이것도 안 됨

# 원인
supabase-swift 2.x에서 IS NULL 필터 API가 다름.
.filter / .is 방식 모두 안 되는 상황.

# 해결 방향
supabase-swift 2.x 기준으로 accepted_at IS NULL 체크는
아래 방식으로 수정해줘:

.filter("accepted_at", operator: "is", value: "null")

위도 안 되면 아래 방식 시도:
.isNull("accepted_at")

위도 안 되면 supabase-swift 2.x 실제 PostgrestFilterBuilder
API를 확인해서 올바른 IS NULL 표현으로 수정.

# revokeInvitation 에러도 남아있음 (36~40번째 줄)
"No calls to throwing functions occur within 'try'"
"No 'async' operations occur within 'await' expression"

현재 코드:
_ = try await client.from("invitations")
    .delete()
    .eq("id", value: id.uuidString)
    .execute()

supabase-swift 2.x delete 체인에서 try await + execute()
올바른 패턴으로 수정. 필요하면 supabase-swift 소스 확인해줘.

# 추가
수정 후 빌드 성공까지 확인해줘.
