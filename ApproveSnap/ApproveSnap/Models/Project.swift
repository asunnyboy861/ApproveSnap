import SwiftData
import Foundation

@Model
final class Project {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var clientName: String = ""
    var clientEmail: String = ""
    var statusRaw: String = ProjectStatus.draft.rawValue
    var createdAt: Date = Date()
    var deadline: Date?
    var magicLinkToken: String?
    @Relationship(deleteRule: .cascade, inverse: \ApprovalItem.project) var approvals: [ApprovalItem] = []

    var status: ProjectStatus {
        get { ProjectStatus(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }

    enum ProjectStatus: String, Codable, CaseIterable {
        case draft
        case pendingApproval
        case approved
        case rejected
        case changesRequested
    }

    init(name: String, clientName: String, clientEmail: String, deadline: Date? = nil) {
        self.id = UUID()
        self.name = name
        self.clientName = clientName
        self.clientEmail = clientEmail
        self.statusRaw = ProjectStatus.draft.rawValue
        self.createdAt = Date()
        self.deadline = deadline
        self.approvals = []
    }
}
