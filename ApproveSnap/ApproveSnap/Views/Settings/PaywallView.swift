import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var selectedPlan: PlanType = .yearly
    @State private var isPurchasing = false

    enum PlanType {
        case monthly
        case yearly
        case lifetime
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    planSelection
                    subscribeButton
                    footerSection
                }
                .padding()
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("Upgrade to Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await purchaseManager.loadProducts()
                await purchaseManager.updatePurchasedProducts()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundColor(.yellow)

            Text("Unlock ApproveSnap Pro")
                .font(.title2)
                .fontWeight(.bold)

            Text("Unlimited projects, magic links, and full audit trail.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var featuresSection: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                featureRow(icon: "link.circle.fill", text: "Magic link sharing")
                featureRow(icon: "bell.badge.fill", text: "Deadline tracking with reminders")
                featureRow(icon: "doc.text.magnifyingglass", text: "Full audit trail")
                featureRow(icon: "arrow.triangle.2.circlepath", text: "Version history")
                featureRow(icon: "paperclip", text: "File attachments")
                featureRow(icon: "infinity", text: "Unlimited projects")
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }

    private var planSelection: some View {
        VStack(spacing: 12) {
            planCard(plan: .yearly, title: "Yearly", price: "$99.00/yr", subtitle: "$8.25/mo, save 17%", badge: "Best Value")
            planCard(plan: .monthly, title: "Monthly", price: "$9.99/mo", subtitle: "7-day free trial", badge: nil)
            planCard(plan: .lifetime, title: "Lifetime", price: "$199.99", subtitle: "Pay once, use forever", badge: "No Recurring")
        }
    }

    private func planCard(plan: PlanType, title: String, price: String, subtitle: String, badge: String?) -> some View {
        Button(action: { selectedPlan = plan }) {
            CardView {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            if let badge {
                                Text(badge)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                        Text(price)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedPlan == plan ? .blue : .secondary)
                        .font(.title2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var subscribeButton: some View {
        Button(action: purchase) {
            if isPurchasing {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("Subscribe")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isPurchasing)
    }

    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Button(action: { Task { await purchaseManager.restorePurchases() } }) {
                Text("Restore Purchases")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func purchase() {
        guard let product = productForPlan else { return }
        isPurchasing = true
        Task {
            do {
                let success = try await purchaseManager.purchase(product)
                if success {
                    dismiss()
                }
            } catch {
                print("Purchase failed: \(error)")
            }
            isPurchasing = false
        }
    }

    private var productForPlan: Product? {
        switch selectedPlan {
        case .monthly:
            return purchaseManager.products.first(where: { $0.id == purchaseManager.monthlyProductID })
        case .yearly:
            return purchaseManager.products.first(where: { $0.id == purchaseManager.yearlyProductID })
        case .lifetime:
            return purchaseManager.products.first(where: { $0.id == purchaseManager.lifetimeProductID })
        }
    }
}
