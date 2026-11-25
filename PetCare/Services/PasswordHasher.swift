import Foundation
import CryptoKit

/// Hash de contraseñas con sal aleatoria + SHA-256 iterado.
/// Suficiente para una app local de hackathon; en producción usa
/// Firebase Auth, Sign in with Apple o tu propio backend.
enum PasswordHasher {
    static func makeSalt() -> String {
        let key = SymmetricKey(size: .bits128)
        return key.withUnsafeBytes { Data($0) }.base64EncodedString()
    }

    static func hash(_ password: String, salt: String, iterations: Int = 10_000) -> String {
        var digest = Data((salt + password).utf8)
        for _ in 0..<iterations {
            digest = Data(SHA256.hash(data: digest))
        }
        return digest.base64EncodedString()
    }
}
