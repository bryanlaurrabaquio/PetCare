import Foundation
import SwiftData

enum AuthError: LocalizedError {
    case missingName, invalidEmail, weakPassword, passwordMismatch
    case emailInUse, invalidCredentials, storage

    var errorDescription: String? {
        switch self {
        case .missingName: "Escribe tu nombre."
        case .invalidEmail: "Escribe un correo válido."
        case .weakPassword: "La contraseña debe tener al menos 6 caracteres."
        case .passwordMismatch: "Las contraseñas no coinciden."
        case .emailInUse: "Ya existe una cuenta con ese correo. Inicia sesión."
        case .invalidCredentials: "Correo o contraseña incorrectos."
        case .storage: "No pudimos guardar tu cuenta. Intenta de nuevo."
        }
    }
}

/// Contrato de autenticación. Para usar Firebase, crea `FirebaseAuthService`
/// que cumpla este protocolo y cámbialo en `SessionViewModel`.
@MainActor
protocol AuthService {
    func register(name: String, email: String, password: String) throws -> UserAccount
    func signIn(email: String, password: String) throws -> UserAccount
    func restoreSession() -> UserAccount?
    func signOut()
}

/// Cuentas guardadas en el dispositivo con SwiftData.
final class LocalAuthService: AuthService {
    private let context: ModelContext
    private let sessionKey = "petcare.session.userID"

    init(context: ModelContext) {
        self.context = context
    }

    func register(name: String, email: String, password: String) throws -> UserAccount {
        let name = name.trimmed
        let email = Self.normalize(email)

        guard !name.isEmpty else { throw AuthError.missingName }
        guard Self.isValidEmail(email) else { throw AuthError.invalidEmail }
        guard password.count >= 6 else { throw AuthError.weakPassword }
        guard try findUser(email: email) == nil else { throw AuthError.emailInUse }

        let salt = PasswordHasher.makeSalt()
        let user = UserAccount(
            name: name,
            email: email,
            passwordHash: PasswordHasher.hash(password, salt: salt),
            salt: salt
        )
        context.insert(user)
        do {
            try context.save()
        } catch {
            throw AuthError.storage
        }
        persistSession(for: user)
        return user
    }

    func signIn(email: String, password: String) throws -> UserAccount {
        let email = Self.normalize(email)
        guard let user = try findUser(email: email),
              PasswordHasher.hash(password, salt: user.salt) == user.passwordHash else {
            throw AuthError.invalidCredentials
        }
        persistSession(for: user)
        return user
    }

    func restoreSession() -> UserAccount? {
        guard let idString = UserDefaults.standard.string(forKey: sessionKey),
              let id = UUID(uuidString: idString) else { return nil }

        var descriptor = FetchDescriptor<UserAccount>(predicate: #Predicate<UserAccount> { $0.id == id })
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    // MARK: - Privado

    private func findUser(email: String) throws -> UserAccount? {
        var descriptor = FetchDescriptor<UserAccount>(predicate: #Predicate<UserAccount> { $0.email == email })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func persistSession(for user: UserAccount) {
        UserDefaults.standard.set(user.id.uuidString, forKey: sessionKey)
    }

    private static func normalize(_ email: String) -> String {
        email.trimmed.lowercased()
    }

    private static func isValidEmail(_ email: String) -> Bool {
        let parts = email.split(separator: "@")
        guard parts.count == 2, !parts[0].isEmpty else { return false }
        let domain = parts[1]
        return domain.contains(".") && !domain.hasPrefix(".") && !domain.hasSuffix(".")
    }
}
