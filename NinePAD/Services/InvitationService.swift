import Foundation
import Supabase

final class InvitationService {
    private let client = SupabaseManager.shared.client

    // MARK: - Create

    func createInvitation(orgId: UUID, email: String) async throws -> Invitation {
        let invitation: Invitation = try await client.from("invitations")
            .insert([
                "org_id": orgId.uuidString,
                "email": email
            ])
            .select()
            .single()
            .execute()
            .value
        return invitation
    }

    // MARK: - Fetch

    func fetchInvitations(orgId: UUID) async throws -> [Invitation] {
        let invitations: [Invitation] = try await client.from("invitations")
            .select()
            .eq("org_id", value: orgId.uuidString)
            .order("expires_at", ascending: false)
            .execute()
            .value
        return invitations
    }

    // MARK: - Revoke

    func revokeInvitation(id: UUID) async throws {
        _ = try await client.from("invitations")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Validate

    func validateInvitation(token: String) async throws -> Invitation {
        let invitation: Invitation = try await client.from("invitations")
            .select()
            .eq("token", value: token)
            .filter("accepted_at", operator: .is, value: "null")
            .gt("expires_at", value: ISO8601DateFormatter().string(from: Date()))
            .single()
            .execute()
            .value
        return invitation
    }

    // MARK: - Accept

    func acceptInvitation(token: String) async throws {
        _ = try await client.from("invitations")
            .update(["accepted_at": ISO8601DateFormatter().string(from: Date())])
            .eq("token", value: token)
            .execute()
    }
}
