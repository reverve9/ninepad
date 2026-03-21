import Foundation

// MARK: - User Role

enum UserRole: String, Codable {
    case admin
    case member
}

// MARK: - Organization

struct Organization: Codable, Identifiable {
    let id: UUID
    let name: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
    }
}

// MARK: - AppUser

struct AppUser: Codable, Identifiable {
    let id: UUID
    let orgId: UUID
    let email: String
    let role: UserRole
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, email, role
        case orgId = "org_id"
        case createdAt = "created_at"
    }
}

// MARK: - Memo

struct Memo: Codable, Identifiable {
    let id: UUID
    var userId: UUID
    var orgId: UUID
    var title: String
    var content: String
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, content
        case userId = "user_id"
        case orgId = "org_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
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
