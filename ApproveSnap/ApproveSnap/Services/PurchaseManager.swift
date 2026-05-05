import StoreKit
import Foundation
import Observation

@MainActor
@Observable
final class PurchaseManager {
    static let shared = PurchaseManager()

    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false

    private var transactionListener: Task<Void, Never>?

    let monthlyProductID = "com.zzoutuo.ApproveSnap.monthly"
    let yearlyProductID = "com.zzoutuo.ApproveSnap.yearly"
    let lifetimeProductID = "com.zzoutuo.ApproveSnap.lifetime"

    var isPro: Bool {
        purchasedProductIDs.contains(monthlyProductID) ||
        purchasedProductIDs.contains(yearlyProductID) ||
        purchasedProductIDs.contains(lifetimeProductID)
    }

    var isLifetime: Bool {
        purchasedProductIDs.contains(lifetimeProductID)
    }

    private init() {
        transactionListener = listenForTransactions()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let storeProducts = try await Product.products(for: [monthlyProductID, yearlyProductID, lifetimeProductID])
            products = storeProducts
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            purchasedProductIDs.insert(product.id)
            await transaction.finish()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                if case .verified(let transaction) = result {
                    await MainActor.run {
                        self.purchasedProductIDs.insert(transaction.productID)
                    }
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
