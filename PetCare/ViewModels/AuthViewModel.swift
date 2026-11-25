import Foundation
import Observation

@MainActor
@Observable
final class AuthViewModel {
    enum Mode {
        case register, signIn
    }

    var mode: Mode = .register
    var name = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    private(set) var errorMessage: String?

    private let session: SessionViewModel

    init(session: SessionViewModel) {
        self.session = session
    }

    // MARK: - Textos

    var isRegistering: Bool { mode == .register }

    var title: String { isRegistering ? "Crea tu cuenta" : "Bienvenido de nuevo" }

    var subtitle: String {
        isRegistering
            ? "Registra a tus mascotas y lleva su salud, agenda y gastos en un solo lugar."
            : "Inicia sesión para ver a tus mascotas."
    }

    var primaryButtonTitle: String { isRegistering ? "Crear cuenta" : "Iniciar sesión" }
    var switchPrompt: String { isRegistering ? "¿Ya tienes cuenta?" : "¿Eres nuevo?" }
    var switchActionTitle: String { isRegistering ? "Inicia sesión" : "Regístrate" }

    var canSubmit: Bool {
        let base = !email.trimmed.isEmpty && !password.isEmpty
        return isRegistering ? base && !name.trimmed.isEmpty && !confirmPassword.isEmpty : base
    }

    // MARK: - Acciones

    func toggleMode() {
        mode = isRegistering ? .signIn : .register
        errorMessage = nil
        password = ""
        confirmPassword = ""
    }

    func submit() {
        errorMessage = nil
        do {
            if isRegistering {
                guard password == confirmPassword else { throw AuthError.passwordMismatch }
                try session.register(name: name, email: email, password: password)
            } else {
                try session.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ocurrió un error. Intenta de nuevo."
        }
    }
}
