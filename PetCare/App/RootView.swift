import SwiftUI
import SwiftData

/// Decide qué mostrar: login/registro, alta de mascotas o la app principal.
struct RootView: View {
    @State private var session: SessionViewModel
    /// El carrusel de bienvenida solo se muestra la primera vez en este dispositivo.
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false

    init(container: ModelContainer) {
        _session = State(initialValue: SessionViewModel(context: container.mainContext))
    }

    var body: some View {
        ZStack {
            AppBackground()

            switch session.phase {
            case .launching:
                ProgressView()
                    .tint(Theme.primary)

            case .signedOut:
                if hasSeenIntro {
                    AuthView(session: session)
                        .transition(.opacity)
                } else {
                    IntroView {
                        withAnimation(.easeInOut(duration: 0.3)) { hasSeenIntro = true }
                    }
                    .transition(.opacity)
                }

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
