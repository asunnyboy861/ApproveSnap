import SwiftUI
import SwiftData
import UserNotifications

@main
struct ApproveSnapApp: App {
    @State private var purchaseManager = PurchaseManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Project.self, ApprovalItem.self, AuditLog.self, Comment.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(purchaseManager)
                .onAppear {
                    insertSampleDataIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func insertSampleDataIfNeeded() {
        let context = sharedModelContainer.mainContext
        let projectCount = (try? context.fetch(FetchDescriptor<Project>()).count) ?? 0
        guard projectCount == 0 else { return }

        let project1 = Project(name: "Website Redesign", clientName: "Acme Corp", clientEmail: "john@acme.com", deadline: Calendar.current.date(byAdding: .day, value: 3, to: Date()))
        let project2 = Project(name: "Mobile App MVP", clientName: "TechStart Inc", clientEmail: "sarah@techstart.io", deadline: Calendar.current.date(byAdding: .day, value: 7, to: Date()))
        let project3 = Project(name: "Brand Guidelines", clientName: "DesignCo", clientEmail: "mark@designco.com", deadline: Calendar.current.date(byAdding: .day, value: -1, to: Date()))
        project1.status = .pendingApproval
        project2.status = .pendingApproval
        project3.status = .pendingApproval
        context.insert(project1)
        context.insert(project2)
        context.insert(project3)

        let item1 = ApprovalItem(title: "Homepage Mockup", type: .document, deadline: Calendar.current.date(byAdding: .day, value: 2, to: Date()))
        item1.status = .approved
        item1.project = project1
        let item2 = ApprovalItem(title: "Navigation Design", type: .design, deadline: Calendar.current.date(byAdding: .day, value: 3, to: Date()))
        item2.project = project1
        let item3 = ApprovalItem(title: "Color Palette", type: .design, deadline: Calendar.current.date(byAdding: .day, value: 1, to: Date()))
        item3.status = .rejected
        item3.project = project1
        let item4 = ApprovalItem(title: "Login Screen", type: .design, deadline: Calendar.current.date(byAdding: .day, value: 5, to: Date()))
        item4.project = project2
        let item5 = ApprovalItem(title: "Onboarding Flow", type: .document, deadline: Calendar.current.date(byAdding: .day, value: 7, to: Date()))
        item5.status = .approved
        item5.project = project2
        let item6 = ApprovalItem(title: "Logo Options", type: .design, deadline: Calendar.current.date(byAdding: .day, value: -1, to: Date()))
        item6.status = .expired
        item6.project = project3
        context.insert(item1)
        context.insert(item2)
        context.insert(item3)
        context.insert(item4)
        context.insert(item5)
        context.insert(item6)

        let log1 = AuditLog(action: .approved, actorEmail: "john@acme.com")
        log1.approvalItem = item1
        let log2 = AuditLog(action: .viewed, actorEmail: "you@company.com")
        log2.approvalItem = item2
        let log3 = AuditLog(action: .rejected, actorEmail: "sarah@techstart.io")
        log3.approvalItem = item3
        context.insert(log1)
        context.insert(log2)
        context.insert(log3)

        let comment1 = Comment(authorEmail: "john@acme.com", content: "Looks great! Approved.")
        comment1.approvalItem = item1
        let comment2 = Comment(authorEmail: "sarah@techstart.io", content: "Need revision on the header layout.")
        comment2.approvalItem = item3
        context.insert(comment1)
        context.insert(comment2)

        try? context.save()
    }
}
