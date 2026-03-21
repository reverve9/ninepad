import Foundation
import Supabase

final class OrgService {
    private let client = SupabaseManager.shared.client

    // MARK: - Fetch Members

    func fetchMembers(orgId: UUID) async throws -> [AppUser] {
        let members: [AppUser] = try await client.from("users")
            .select()
            .eq("org_id", value: orgId.uuidString)
            .order("created_at", ascending: true)
            .execute()
            .value
        return members
    }

    // MARK: - Remove Member

    func removeMember(userId: UUID) async throws {
        _ = try await client.from("users")
            .delete()
            .eq("id", value: userId.uuidString)
            .execute()
    }

    // MARK: - Update Role

    func updateMemberRole(userId: UUID, role: UserRole) async throws -> AppUser {
        let user: AppUser = try await client.from("users")
            .update(["role": role.rawValue])
            .eq("id", value: userId.uuidString)
            .select()
            .single()
            .execute()
            .value
        return user
    }

    // MARK: - Fetch Org

    func fetchOrganization(orgId: UUID) async throws -> Organization {
        let org: Organization = try await client.from("organizations")
            .select()
            .eq("id", value: orgId.uuidString)
            .single()
            .execute()
            .value
        return org
    }
}
