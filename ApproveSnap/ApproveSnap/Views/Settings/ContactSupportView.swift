import SwiftUI

struct ContactSupportView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var topic = "General"
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    let topics = ["General", "Bug Report", "Feature Request", "Subscription", "Account", "Other"]

    var canSubmit: Bool { !email.isEmpty && !message.isEmpty }

    var body: some View {
        Form {
            Section("Topic") {
                Picker("Topic", selection: $topic) {
                    ForEach(topics, id: \.self) { t in
                        Text(t).tag(t)
                    }
                }
            }

            Section("Contact Info") {
                TextField("Name (optional)", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            Section("Message") {
                TextEditor(text: $message)
                    .frame(minHeight: 120)
            }

            Section {
                Button(action: submitFeedback) {
                    if isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSubmit || isSubmitting)
            }
        }
        .navigationTitle("Contact Support")
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage.contains("success") ? "Sent!" : "Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func submitFeedback() {
        isSubmitting = true
        guard let backendURL = URL(string: "https://feedback-board.iocompile67692.workers.dev") else {
            alertMessage = "Invalid backend URL"
            showAlert = true
            isSubmitting = false
            return
        }

        var request = URLRequest(url: backendURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "topic": topic,
            "name": name,
            "email": email,
            "message": message,
            "app": "ApproveSnap"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    alertMessage = "Failed to send: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    alertMessage = "Your message has been sent successfully!"
                    message = ""
                } else {
                    alertMessage = "Failed to send message. Please try again."
                }
                showAlert = true
            }
        }.resume()
    }
}
