import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var showingPaywall = false
    @AppStorage("useCloudKit") private var useCloudKit = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Subscription") {
                    if purchaseManager.isPro {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text(purchaseManager.isLifetime ? "Lifetime Access" : "Pro Plan")
                                .fontWeight(.medium)
                            Spacer()
                            Text("Active")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    } else {
                        Button(action: { showingPaywall = true }) {
                            HStack {
                                Image(systemName: "crown")
                                    .foregroundColor(.yellow)
                                Text("Upgrade to Pro")
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Button(action: { Task { await purchaseManager.restorePurchases() } }) {
                        Text("Restore Purchases")
                    }
                }

                Section("Sync") {
                    Toggle("iCloud Sync", isOn: $useCloudKit)
                    Text("Sync your projects across all devices")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Support") {
                    NavigationLink(destination: ContactSupportView()) {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                }

                Section("Legal") {
                    Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/ApproveSnap/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/ApproveSnap/terms.html")!)
                    Link("Support Page", destination: URL(string: "https://asunnyboy861.github.io/ApproveSnap/support.html")!)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        Text("Made with care for freelancers and small agencies")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}
