import SwiftData
import Foundation

@Model
final class Comment {
    @Attribute(.unique) var id: UUID = UUID()
    var authorEmail: String = ""
    var content: String = ""
    var createdAt: Date = Date()
    var approvalItem: ApprovalItem?

    init(authorEmail: String, content: String) {
        self.id = UUID()
        self.authorEmail = authorEmail
        self.content = content
        self.createdAt = Date()
    }
}
