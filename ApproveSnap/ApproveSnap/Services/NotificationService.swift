import UserNotifications
import Foundation

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleApprovalReminder(for project: Project, deadline: Date, reminderIntervals: [TimeInterval] = [86400, 43200, 7200]) {
        for (index, interval) in reminderIntervals.enumerated() {
            let triggerDate = deadline.addingTimeInterval(-interval)
            guard triggerDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Approval Reminder"
            content.body = "\(project.clientName) hasn't approved \"\(project.name)\" yet. Deadline: \(deadline.formatted(date: .abbreviated, time: .shortened))"
            content.sound = .default
            content.categoryIdentifier = "APPROVAL_REMINDER"
            content.userInfo = ["projectId": project.id.uuidString]

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(identifier: "reminder-\(project.id.uuidString)-\(index)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    func sendApprovalReceivedNotification(for project: Project, action: AuditLog.AuditAction) {
        let content = UNMutableNotificationContent()

        switch action {
        case .approved:
            content.title = "Approved!"
            content.body = "\(project.clientName) approved \"\(project.name)\""
        case .rejected:
            content.title = "Rejected"
            content.body = "\(project.clientName) rejected \"\(project.name)\""
        case .changesRequested:
            content.title = "Changes Requested"
            content.body = "\(project.clientName) requested changes on \"\(project.name)\""
        default:
            return
        }

        content.sound = .default
        content.categoryIdentifier = "APPROVAL_UPDATE"
        content.userInfo = ["projectId": project.id.uuidString]

        let request = UNNotificationRequest(identifier: "update-\(project.id.uuidString)-\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminders(for projectId: UUID) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.identifier.hasPrefix("reminder-\(projectId.uuidString)") }
                .map(\.identifier)
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
