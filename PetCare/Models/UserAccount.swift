import Foundation
import SwiftData

/// Cuenta local. La contraseña nunca se guarda: solo su hash con sal.
@Model
final class UserAccount {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var email: String
    var name: String
    var passwordHash: String
    var salt: String
    var createdAt: Date

    init(name: String, email: String, passwordHash: String, salt: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.salt = salt
        self.createdAt = .now
    }
}
