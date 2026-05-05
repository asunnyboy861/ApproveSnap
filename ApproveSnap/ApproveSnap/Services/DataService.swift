import SwiftData
import Foundation

@MainActor
final class DataService {
    static let shared = DataService()

    private init() {}

    func createProject(modelContext: ModelContext, name: String, clientName: String, clientEmail: String, deadline: Date?) -> Project {
        let project = Project(name: name, clientName: clientName, clientEmail: clientEmail, deadline: deadline)
        modelContext.insert(project)
        try? modelContext.save()
        return project
    }

    func addApprovalItem(to project: Project, modelContext: ModelContext, title: String, descriptionText: String, type: ApprovalItem.ApprovalType, deadline: Date? = nil, fileURL: String? = nil, externalLink: String? = nil) -> ApprovalItem {
        let item = ApprovalItem(title: title, descriptionText: descriptionText, type: type, deadline: deadline, fileURL: fileURL, externalLink: externalLink)
        item.project = project
        project.approvals.append(item)
        modelContext.insert(item)
        try? modelContext.save()
        return item
    }

    func updateApprovalStatus(item: ApprovalItem, newStatus: ApprovalItem.ApprovalStatus, modelContext: ModelContext) throws {
        let _ = try ApprovalStateMachine.shared.transition(from: item.status, to: newStatus)
        item.status = newStatus
        try modelContext.save()
    }

    func addAuditLog(to item: ApprovalItem, modelContext: ModelContext, action: AuditLog.AuditAction, actorEmail: String, note: String? = nil) {
        let log = AuditLog(action: action, actorEmail: actorEmail, note: note)
        log.approvalItem = item
        item.auditLogs.append(log)
        modelContext.insert(log)
        try? modelContext.save()
    }

    func addComment(to item: ApprovalItem, modelContext: ModelContext, authorEmail: String, content: String) {
        let comment = Comment(authorEmail: authorEmail, content: content)
        comment.approvalItem = item
        item.comments.append(comment)
        modelContext.insert(comment)
        try? modelContext.save()
    }

    func deleteProject(_ project: Project, modelContext: ModelContext) {
        modelContext.delete(project)
        try? modelContext.save()
    }

    func deleteApprovalItem(_ item: ApprovalItem, modelContext: ModelContext) {
        modelContext.delete(item)
        try? modelContext.save()
    }

    func sendForApproval(_ project: Project, modelContext: ModelContext) {
        let link = MagicLinkService.shared.generateMagicLink(for: project)
        project.magicLinkToken = link
        project.status = .pendingApproval

        for item in project.approvals {
            if item.status == .pending {
                addAuditLog(to: item, modelContext: modelContext, action: .viewed, actorEmail: project.clientEmail, note: "Approval request sent")
            }
        }

        if let deadline = project.deadline {
            NotificationService.shared.scheduleApprovalReminder(for: project, deadline: deadline)
        }

        try? modelContext.save()
    }

    func projectsThisMonth(modelContext: ModelContext) -> Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let descriptor = FetchDescriptor<Project>(predicate: #Predicate { $0.createdAt >= startOfMonth })
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }
}
