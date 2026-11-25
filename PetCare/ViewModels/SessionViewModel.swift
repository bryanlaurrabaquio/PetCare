import Foundation
import SwiftData
import Observation

/// Controla el flujo de la app: sin sesión → alta de mascotas → app principal.
@MainActor
@Observable
final class SessionViewModel {
    enum Phase: Equatable {
        case launching, signedOut, onboarding, signedIn
    }

    private(set) var phase: Phase = .launching
    private(set) var store: PetCareStore?

    private let context: ModelContext
    private let auth: AuthService

    init(context: ModelContext) {
        self.context = context
        self.auth = LocalAuthService(context: context)
    }

    func restoreSession() {
        guard phase == .launching else { return }
        if let user = auth.restoreSession() {
            start(with: user)
        } else {
            phase = .signedOut
        }
    }

    func register(name: String, email: String, password: String) throws {
        let user = try auth.register(name: name, email: email, password: password)
        start(with: user)
    }

    func signIn(email: String, password: String) throws {
        let user = try auth.signIn(email: email, password: password)
        start(with: user)
    }

    func signOut() {
        auth.signOut()
        store = nil
        phase = .signedOut
    }

    func completeOnboarding() {
        guard let store, !store.pets.isEmpty else { return }
        phase = .signedIn
    }

    private func start(with user: UserAccount) {
        let store = PetCareStore(context: context, user: user)
        self.store = store
        // Primera vez (sin mascotas) → alta de mascotas.
        phase = store.pets.isEmpty ? .onboarding : .signedIn
    }
}
