import Foundation

final class ApprovalStateMachine {
    static let shared = ApprovalStateMachine()

    private let validTransitions: [ApprovalItem.ApprovalStatus: Set<ApprovalItem.ApprovalStatus>] = [
        .pending: [.approved, .rejected, .changesRequested, .expired],
        .changesRequested: [.pending, .approved, .rejected],
        .approved: [],
        .rejected: [.pending],
        .expired: [.pending]
    ]

    private init() {}

    func transition(from current: ApprovalItem.ApprovalStatus, to next: ApprovalItem.ApprovalStatus) throws -> ApprovalItem.ApprovalStatus {
        guard let allowed = validTransitions[current],
              allowed.contains(next) else {
            throw ApprovalError.invalidTransition(from: current, to: next)
        }
        return next
    }

    func canTransition(from current: ApprovalItem.ApprovalStatus, to next: ApprovalItem.ApprovalStatus) -> Bool {
        validTransitions[current]?.contains(next) ?? false
    }
}

enum ApprovalError: LocalizedError {
    case invalidTransition(from: ApprovalItem.ApprovalStatus, to: ApprovalItem.ApprovalStatus)

    var errorDescription: String? {
        switch self {
        case .invalidTransition(let from, let to):
            return "Cannot transition from \(from.rawValue) to \(to.rawValue)"
        }
    }
}
