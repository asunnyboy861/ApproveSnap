import SwiftData
import Foundation

@Model
final class AuditLog {
    @Attribute(.unique) var id: UUID = UUID()
    var actionRaw: String = AuditAction.viewed.rawValue
    var actorEmail: String = ""
    var actorIP: String = ""
    var timestamp: Date = Date()
    var userAgent: String = ""
    var note: String?
    var approvalItem: ApprovalItem?

    var action: AuditAction {
        get { AuditAction(rawValue: actionRaw) ?? .viewed }
        set { actionRaw = newValue.rawValue }
    }

    enum AuditAction: String, Codable, CaseIterable {
        case viewed
        case approved
        case rejected
        case changesRequested
        case commentAdded
        case reminderSent
        case expired

        var iconName: String {
            switch self {
            case .viewed: return "eye.fill"
            case .approved: return "checkmark.circle.fill"
            case .rejected: return "xmark.circle.fill"
            case .changesRequested: return "arrow.triangle.2.circlepath"
            case .commentAdded: return "bubble.left.fill"
            case .reminderSent: return "bell.fill"
            case .expired: return "exclamationmark.triangle.fill"
            }
        }

        var displayName: String {
            switch self {
            case .viewed: return "Viewed"
            case .approved: return "Approved"
            case .rejected: return "Rejected"
            case .changesRequested: return "Changes Requested"
            case .commentAdded: return "Comment Added"
            case .reminderSent: return "Reminder Sent"
            case .expired: return "Expired"
            }
        }
    }

    init(action: AuditAction, actorEmail: String, actorIP: String = "", userAgent: String = "", note: String? = nil) {
        self.id = UUID()
        self.actionRaw = action.rawValue
        self.actorEmail = actorEmail
        self.actorIP = actorIP
        self.timestamp = Date()
        self.userAgent = userAgent
        self.note = note
    }
}
