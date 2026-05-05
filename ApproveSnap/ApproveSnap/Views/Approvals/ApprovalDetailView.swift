import SwiftUI
import SwiftData

struct ApprovalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let approvalItem: ApprovalItem
    @State private var showingActionSheet = false
    @State private var commentText = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                itemHeader
                itemContent
                actionButtons
                commentsSection
                auditLogSection
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
        .navigationTitle(approvalItem.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var itemHeader: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: approvalItem.type.iconName)
                        .font(.title3)
                        .foregroundColor(.blue)
                    Text(approvalItem.type.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    StatusBadge(status: approvalItem.status)
                }

                Text(approvalItem.title)
                    .font(.title3)
                    .fontWeight(.semibold)

                if !approvalItem.descriptionText.isEmpty {
                    Text(approvalItem.descriptionText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Label("v\(approvalItem.version)", systemImage: "number")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Label(approvalItem.createdAt.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var itemContent: some View {
        Group {
            if let link = approvalItem.externalLink, let url = URL(string: link) {
                CardView {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(.blue)
                            Text(link)
                                .font(.caption)
                                .foregroundColor(.blue)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        Group {
            if approvalItem.status == .pending {
                HStack(spacing: 12) {
                    Button(action: { performAction(.approved) }) {
                        Label("Approve", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    .foregroundColor(.green)

                    Button(action: { performAction(.changesRequested) }) {
                        Label("Changes", systemImage: "arrow.triangle.2.circlepath")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .foregroundColor(.blue)
                }

                Button(action: { performAction(.rejected) }) {
                    Label("Reject", systemImage: "xmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .foregroundColor(.red)
            }
        }
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comments")
                .font(.headline)

            HStack {
                TextField("Add a comment...", text: $commentText)
                    .textFieldStyle(.roundedBorder)

                Button(action: addComment) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .disabled(commentText.isEmpty)
            }

            let sortedComments = approvalItem.comments.sorted(by: { $0.createdAt > $1.createdAt })
            if !sortedComments.isEmpty {
                ForEach(sortedComments) { comment in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "bubble.left.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(comment.authorEmail)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(comment.content)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var auditLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Audit Log")
                .font(.headline)

            let logs = approvalItem.auditLogs.sorted(by: { $0.timestamp > $1.timestamp })
            if logs.isEmpty {
                Text("No audit logs yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(logs) { log in
                    HStack(spacing: 8) {
                        Image(systemName: log.action.iconName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(log.action.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                            if let note = log.note {
                                Text(note)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Text(log.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func performAction(_ newStatus: ApprovalItem.ApprovalStatus) {
        do {
            try DataService.shared.updateApprovalStatus(item: approvalItem, newStatus: newStatus, modelContext: modelContext)
            DataService.shared.addAuditLog(to: approvalItem, modelContext: modelContext, action: auditAction(from: newStatus), actorEmail: "user", note: nil)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } catch {
            print("Failed to update status: \(error)")
        }
    }

    private func addComment() {
        guard !commentText.isEmpty else { return }
        DataService.shared.addComment(to: approvalItem, modelContext: modelContext, authorEmail: "user", content: commentText)
        DataService.shared.addAuditLog(to: approvalItem, modelContext: modelContext, action: .commentAdded, actorEmail: "user", note: commentText)
        commentText = ""
    }

    private func auditAction(from status: ApprovalItem.ApprovalStatus) -> AuditLog.AuditAction {
        switch status {
        case .approved: return .approved
        case .rejected: return .rejected
        case .changesRequested: return .changesRequested
        case .pending: return .viewed
        case .expired: return .expired
        }
    }
}
