import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]
    @Environment(PurchaseManager.self) private var purchaseManager

    var pendingProjects: [Project] {
        projects.filter { $0.status == .pendingApproval }
    }

    var approvedProjects: [Project] {
        projects.filter { $0.status == .approved }
    }

    var rejectedProjects: [Project] {
        projects.filter { $0.status == .rejected }
    }

    var expiredProjects: [Project] {
        projects.filter { $0.status == .changesRequested || $0.approvals.contains(where: { $0.status == .expired }) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statsSection

                    if pendingProjects.isEmpty && approvedProjects.isEmpty {
                        EmptyStateView(
                            icon: "doc.text.magnifyingglass",
                            title: "No Projects Yet",
                            subtitle: "Create your first project and start getting client approvals.",
                            actionTitle: "New Project",
                            action: {}
                        )
                    } else {
                        if !pendingProjects.isEmpty {
                            projectSection(title: "Pending", projects: pendingProjects, icon: "clock.fill", color: .orange)
                        }

                        if !approvedProjects.isEmpty {
                            projectSection(title: "Approved", projects: approvedProjects, icon: "checkmark.circle.fill", color: .green)
                        }

                        if !rejectedProjects.isEmpty {
                            projectSection(title: "Rejected", projects: rejectedProjects, icon: "xmark.circle.fill", color: .red)
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("ApproveSnap")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateProjectView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private var statsSection: some View {
        CardView {
            HStack(spacing: 0) {
                statItem(value: approvedProjects.count, label: "Approved", color: .green)
                Divider().frame(height: 40)
                statItem(value: pendingProjects.count, label: "Pending", color: .orange)
                Divider().frame(height: 40)
                statItem(value: rejectedProjects.count, label: "Rejected", color: .red)
            }
        }
    }

    private func statItem(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func projectSection(title: String, projects: [Project], icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }

            ForEach(projects) { project in
                NavigationLink(destination: ProjectDetailView(project: project)) {
                    ProjectRowView(project: project)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ProjectRowView: View {
    let project: Project

    var body: some View {
        CardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(project.clientName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        if let deadline = project.deadline {
                            Label(deadline.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Text("\(project.approvals.count) items")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                StatusBadge(status: projectStatusToApprovalStatus(project.status))
            }
        }
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
