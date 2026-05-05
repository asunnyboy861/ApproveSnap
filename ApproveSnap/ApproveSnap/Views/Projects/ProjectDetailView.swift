import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let project: Project
    @State private var showingAddItem = false
    @State private var showingShareSheet = false
    @State private var showingReminderAlert = false

    var pendingCount: Int { project.approvals.filter { $0.status == .pending }.count }
    var approvedCount: Int { project.approvals.filter { $0.status == .approved }.count }
    var rejectedCount: Int { project.approvals.filter { $0.status == .rejected }.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                projectHeader
                statusStats
                approvalItemsSection
                auditTrailSection
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if project.status == .pendingApproval {
                    Button(action: { showingReminderAlert = true }) {
                        Image(systemName: "bell.badge")
                    }
                }

                if project.magicLinkToken != nil {
                    ShareLink(item: URL(string: project.magicLinkToken ?? "")!) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }

                Menu {
                    if project.status == .draft {
                        Button(action: sendForApproval) {
                            Label("Send for Approval", systemImage: "paperplane.fill")
                        }
                    }

                    if project.status == .rejected || project.status == .changesRequested {
                        Button(action: resubmit) {
                            Label("Resubmit", systemImage: "arrow.clockwise")
                        }
                    }

                    Button(action: sendReminder) {
                        Label("Send Reminder", systemImage: "bell")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddApprovalItemView(project: project)
        }
        .alert("Reminder Sent", isPresented: $showingReminderAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("A reminder has been sent to \(project.clientName).")
        }
    }

    private var projectHeader: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(project.clientName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    StatusBadge(status: projectStatusToApprovalStatus(project.status))
                }

                if let deadline = project.deadline {
                    Label("Due \(deadline.formatted(date: .abbreviated, time: .shortened))", systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(deadline < Date() ? .red : .secondary)
                }

                Text(project.clientEmail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statusStats: some View {
        HStack(spacing: 0) {
            statItem(value: approvedCount, label: "Approved", color: .green)
            Divider().frame(height: 40)
            statItem(value: rejectedCount, label: "Rejected", color: .red)
            Divider().frame(height: 40)
            statItem(value: pendingCount, label: "Pending", color: .orange)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }

    private func statItem(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var approvalItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Approval Items")
                    .font(.headline)
                Spacer()
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }

            if project.approvals.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    title: "No Items",
                    subtitle: "Add approval items to this project."
                )
            } else {
                ForEach(project.approvals) { item in
                    NavigationLink(destination: ApprovalDetailView(approvalItem: item)) {
                        ApprovalItemRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var auditTrailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Audit Trail")
                .font(.headline)

            let allLogs = project.approvals.flatMap { $0.auditLogs }.sorted(by: { $0.timestamp > $1.timestamp })
            if allLogs.isEmpty {
                Text("No audit logs yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(allLogs.prefix(10)) { log in
                    HStack(spacing: 8) {
                        Image(systemName: log.action.iconName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.action.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(log.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func sendForApproval() {
        DataService.shared.sendForApproval(project, modelContext: modelContext)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func resubmit() {
        project.status = .pendingApproval
        for item in project.approvals where item.status == .rejected || item.status == .changesRequested {
            item.status = .pending
            item.version += 1
        }
        try? modelContext.save()
    }

    private func sendReminder() {
        if let deadline = project.deadline {
            NotificationService.shared.scheduleApprovalReminder(for: project, deadline: deadline, reminderIntervals: [0])
        }
        showingReminderAlert = true
    }

    private func projectStatusToApprovalStatus(_ status: Project.ProjectStatus) -> ApprovalItem.ApprovalStatus {
        switch status {
        case .draft: return .pending
        case .pendingApproval: return .pending
        case .approved: return .approved
        case .rejected: return .rejected
        case .changesRequested: return .changesRequested
        }
    }
}

struct ApprovalItemRow: View {
    let item: ApprovalItem

    var body: some View {
        CardView {
            HStack {
                Image(systemName: item.type.iconName)
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text("v\(item.version)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                StatusBadge(status: item.status)
            }
        }
    }
}
