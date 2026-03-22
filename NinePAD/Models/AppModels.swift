import Foundation

// MARK: - User Role

enum UserRole: String, Codable {
    case superadmin
    case admin
    case member
}

// MARK: - Org Status

enum OrgStatus: String, Codable {
    case pending
    case approved
    case rejected
}

// MARK: - Organization

struct Organization: Codable, Identifiable {
    let id: UUID
    let name: String
    var status: OrgStatus
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, status
        case createdAt = "created_at"
    }
}

// MARK: - AppUser

struct AppUser: Codable, Identifiable {
    let id: UUID
    let orgId: UUID?
    let email: String
    let role: UserRole
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, email, role
        case orgId = "org_id"
        case createdAt = "created_at"
    }

    var isSuperAdmin: Bool { role == .superadmin }
    var isAdmin: Bool { role == .admin || role == .superadmin }
}

// MARK: - Memo

struct Memo: Codable, Identifiable, Hashable {
    static func == (lhs: Memo, rhs: Memo) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    let id: UUID
    var userId: UUID
    var orgId: UUID
    var title: String
    var content: String
    var colorDot: String?
    let createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, title, content
        case colorDot = "color_dot"
        case userId = "user_id"
        case orgId = "org_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }

    var isDeleted: Bool { deletedAt != nil }
}

// MARK: - Snippet

struct Snippet: Codable, Identifiable {
    let id: UUID
    var userId: UUID
    var orgId: UUID
    var title: String
    var content: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, content
        case userId = "user_id"
        case orgId = "org_id"
        case createdAt = "created_at"
    }
}

// MARK: - Invitation

struct Invitation: Codable, Identifiable {
    let id: UUID
    let orgId: UUID
    let email: String
    let token: String
    let expiresAt: Date
    var acceptedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, email, token
        case orgId = "org_id"
        case expiresAt = "expires_at"
        case acceptedAt = "accepted_at"
    }
}
