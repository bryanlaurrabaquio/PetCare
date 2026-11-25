import SwiftUI
import SwiftData

/// Decide qué mostrar: login/registro, alta de mascotas o la app principal.
struct RootView: View {
    @State private var session: SessionViewModel

    init(container: ModelContainer) {
        _session = State(initialValue: SessionViewModel(context: container.mainContext))
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            switch session.phase {
            case .launching:
                ProgressView()

            case .signedOut:
                AuthView(session: session)
                    .transition(.opacity)

            case .onboarding:
                if let store = session.store {
                    OnboardingView(
                        store: store,
                        onFinish: { session.completeOnboarding() },
                        onSignOut: { session.signOut() }
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }

            case .signedIn:
                if let store = session.store {
                    MainTabView(store: store, onSignOut: { session.signOut() })
                        .id(store.user.id) // estado nuevo por cada usuario
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.phase)
        .onAppear { session.restoreSession() }
    }
}
