import SwiftUI
import SwiftData

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
        Task {
            _ = try? await NotificationService.shared.requestAuthorization()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(purchaseManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
