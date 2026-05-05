import SwiftUI
import SwiftData

struct ProjectListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]
    @State private var searchText = ""
    @State private var filterStatus: Project.ProjectStatus? = nil

    var filteredProjects: [Project] {
        var result = projects
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.clientName.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let filterStatus {
            result = result.filter { $0.status == filterStatus }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredProjects) { project in
                    NavigationLink(destination: ProjectDetailView(project: project)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(project.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Spacer()
                                StatusBadge(status: projectStatusToApprovalStatus(project.status))
                            }

                            Text(project.clientName)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 12) {
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
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteProjects)
            }
            .searchable(text: $searchText, prompt: "Search projects...")
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateProjectView()) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("All") { filterStatus = nil }
                        ForEach(Project.ProjectStatus.allCases, id: \.self) { status in
                            Button(status.displayName) { filterStatus = status }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .overlay {
                if filteredProjects.isEmpty {
                    EmptyStateView(
                        icon: "folder",
                        title: "No Projects",
                        subtitle: "Create a project to start tracking approvals.",
                        actionTitle: "New Project",
                        action: {}
                    )
                }
            }
        }
    }

    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            let project = filteredProjects[index]
            DataService.shared.deleteProject(project, modelContext: modelContext)
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

extension Project.ProjectStatus {
    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .pendingApproval: return "Pending"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .changesRequested: return "Changes Requested"
        }
    }
}
