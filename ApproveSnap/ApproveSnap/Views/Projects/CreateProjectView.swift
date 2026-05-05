import SwiftUI
import SwiftData

struct CreateProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseManager.self) private var purchaseManager

    @State private var projectName = ""
    @State private var clientName = ""
    @State private var clientEmail = ""
    @State private var deadline = Date().addingTimeInterval(72 * 3600)
    @State private var hasDeadline = true
    @State private var approvalItems: [ApprovalItemDraft] = [ApprovalItemDraft()]

    struct ApprovalItemDraft {
        var title: String = ""
        var descriptionText: String = ""
        var type: ApprovalItem.ApprovalType = .text
        var externalLink: String = ""
    }

    var canCreate: Bool {
        !projectName.isEmpty && !clientName.isEmpty && !clientEmail.isEmpty && approvalItems.contains(where: { !$0.title.isEmpty })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $projectName)
                    TextField("Client Name", text: $clientName)
                    TextField("Client Email", text: $clientEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section {
                    Toggle("Set Deadline", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    }
                } header: {
                    Text("Deadline")
                }

                Section {
                    ForEach(approvalItems.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Picker("Type", selection: $approvalItems[index].type) {
                                    ForEach(ApprovalItem.ApprovalType.allCases, id: \.self) { type in
                                        Text(type.displayName).tag(type)
                                    }
                                }
                                .pickerStyle(.menu)

                                Spacer()

                                if approvalItems.count > 1 {
                                    Button(action: { approvalItems.remove(at: index) }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }

                            TextField("Item Title", text: $approvalItems[index].title)
                            TextField("Description (optional)", text: $approvalItems[index].descriptionText)

                            if approvalItems[index].type == .link {
                                TextField("External Link URL", text: $approvalItems[index].externalLink)
                                    .keyboardType(.URL)
                                    .textInputAutocapitalization(.never)
                            }
                        }
                    }

                    Button(action: { approvalItems.append(ApprovalItemDraft()) }) {
                        Label("Add Item", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Approval Items")
                }

                Section {
                    Button(action: createProject) {
                        Text("Create Project")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canCreate)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func createProject() {
        let projectDeadline = hasDeadline ? deadline : nil
        let project = DataService.shared.createProject(
            modelContext: modelContext,
            name: projectName,
            clientName: clientName,
            clientEmail: clientEmail,
            deadline: projectDeadline
        )

        for draft in approvalItems where !draft.title.isEmpty {
            DataService.shared.addApprovalItem(
                to: project,
                modelContext: modelContext,
                title: draft.title,
                descriptionText: draft.descriptionText,
                type: draft.type,
                externalLink: draft.externalLink.isEmpty ? nil : draft.externalLink
            )
        }

        dismiss()
    }
}
