import SwiftUI
import SwiftData

struct AddApprovalItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let project: Project

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var type: ApprovalItem.ApprovalType = .text
    @State private var externalLink = ""

    var canAdd: Bool { !title.isEmpty }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Type") {
                    Picker("Type", selection: $type) {
                        ForEach(ApprovalItem.ApprovalType.allCases, id: \.self) { t in
                            Label(t.displayName, systemImage: t.iconName).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $descriptionText, axis: .vertical)
                        .lineLimit(3...6)

                    if type == .link {
                        TextField("URL", text: $externalLink)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                    }
                }

                Section {
                    Button(action: addItem) {
                        Text("Add Item")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canAdd)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func addItem() {
        DataService.shared.addApprovalItem(
            to: project,
            modelContext: modelContext,
            title: title,
            descriptionText: descriptionText,
            type: type,
            externalLink: externalLink.isEmpty ? nil : externalLink
        )
        dismiss()
    }
}
