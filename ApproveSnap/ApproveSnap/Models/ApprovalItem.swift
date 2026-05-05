import SwiftData
import Foundation

@Model
final class ApprovalItem {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String = ""
    var descriptionText: String = ""
    var typeRaw: String = ApprovalType.text.rawValue
    var statusRaw: String = ApprovalStatus.pending.rawValue
    var version: Int = 1
    var createdAt: Date = Date()
    var deadline: Date?
    var fileURL: String?
    var externalLink: String?
    @Relationship(deleteRule: .cascade, inverse: \AuditLog.approvalItem) var auditLogs: [AuditLog] = []
    @Relationship(deleteRule: .cascade, inverse: \Comment.approvalItem) var comments: [Comment] = []
    var project: Project?

    var type: ApprovalType {
        get { ApprovalType(rawValue: typeRaw) ?? .text }
        set { typeRaw = newValue.rawValue }
    }

    var status: ApprovalStatus {
        get { ApprovalStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    enum ApprovalType: String, Codable, CaseIterable {
        case document
        case design
        case milestone
        case link
        case text

        var iconName: String {
            switch self {
            case .document: return "doc.fill"
            case .design: return "paintbrush.fill"
            case .milestone: return "flag.fill"
            case .link: return "link"
            case .text: return "text.alignleft"
            }
        }

        var displayName: String {
            switch self {
            case .document: return "Document"
            case .design: return "Design"
            case .milestone: return "Milestone"
            case .link: return "Link"
            case .text: return "Text"
            }
        }
    }

    enum ApprovalStatus: String, Codable, CaseIterable {
        case pending
        case approved
        case rejected
        case changesRequested
        case expired

        var iconName: String {
            switch self {
            case .pending: return "clock.fill"
            case .approved: return "checkmark.circle.fill"
            case .rejected: return "xmark.circle.fill"
            case .changesRequested: return "arrow.triangle.2.circlepath"
            case .expired: return "exclamationmark.triangle.fill"
            }
        }

        var colorName: String {
            switch self {
            case .pending: return "orange"
            case .approved: return "green"
            case .rejected: return "red"
            case .changesRequested: return "blue"
            case .expired: return "gray"
            }
        }

        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .approved: return "Approved"
            case .rejected: return "Rejected"
            case .changesRequested: return "Changes Requested"
            case .expired: return "Expired"
            }
        }
    }

    init(title: String, descriptionText: String = "", type: ApprovalType = .text, deadline: Date? = nil, fileURL: String? = nil, externalLink: String? = nil) {
        self.id = UUID()
        self.title = title
        self.descriptionText = descriptionText
        self.typeRaw = type.rawValue
        self.statusRaw = ApprovalStatus.pending.rawValue
        self.version = 1
        self.createdAt = Date()
        self.deadline = deadline
        self.fileURL = fileURL
        self.externalLink = externalLink
        self.auditLogs = []
        self.comments = []
    }
}
