import Foundation
import CryptoKit

struct MagicLinkPayload: Codable {
    let projectId: String
    let clientEmail: String
    let expiresAt: Date
}

final class MagicLinkService {
    static let shared = MagicLinkService()

    private let baseURL = "https://approvesnap.app/approve"
    private let secretKey: SymmetricKey

    private init() {
        let keyData = UserDefaults.standard.data(forKey: "approvesnap_secret_key") ?? {
            let newKey = SymmetricKey(size: .bits256)
            let data = newKey.withUnsafeBytes { Data($0) }
            UserDefaults.standard.set(data, forKey: "approvesnap_secret_key")
            return data
        }()
        self.secretKey = SymmetricKey(data: keyData)
    }

    func generateMagicLink(for project: Project, expirationHours: Int = 72) -> String {
        let payload = MagicLinkPayload(
            projectId: project.id.uuidString,
            clientEmail: project.clientEmail,
            expiresAt: Date().addingTimeInterval(TimeInterval(expirationHours * 3600))
        )

        guard let encoded = try? JSONEncoder().encode(payload) else { return "" }

        guard let sealedBox = try? AES.GCM.seal(encoded, using: secretKey),
              let token = sealedBox.combined?.base64EncodedString() else { return "" }

        let safeToken = token
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        return "\(baseURL)?token=\(safeToken)"
    }

    func validateMagicLink(token: String) -> MagicLinkPayload? {
        let paddedToken = token
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let padding = 4 - (paddedToken.count % 4)
        let fullToken = padding < 4 ? paddedToken + String(repeating: "=", count: padding) : paddedToken

        guard let data = Data(base64Encoded: fullToken),
              let sealedBox = try? AES.GCM.SealedBox(combined: data),
              let decrypted = try? AES.GCM.open(sealedBox, using: secretKey),
              let payload = try? JSONDecoder().decode(MagicLinkPayload.self, from: decrypted) else {
            return nil
        }

        guard payload.expiresAt > Date() else { return nil }

        return payload
    }
}
