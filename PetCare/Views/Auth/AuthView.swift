import SwiftUI

/// Registro e inicio de sesión con correo y contraseña.
struct AuthView: View {
    @State private var viewModel: AuthViewModel

    init(session: SessionViewModel) {
        _viewModel = State(initialValue: AuthViewModel(session: session))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                brand

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                        Text(viewModel.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(spacing: 12) {
                        if viewModel.isRegistering {
                            AppTextField(title: "Nombre", text: $viewModel.name, systemImage: "person")
                                .textContentType(.name)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        AppTextField(title: "Correo electrónico", text: $viewModel.email, systemImage: "envelope")
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        AppTextField(title: "Contraseña (mín. 6 caracteres)", text: $viewModel.password,
                                     systemImage: "lock", isSecure: true)

                        if viewModel.isRegistering {
                            AppTextField(title: "Confirmar contraseña", text: $viewModel.confirmPassword,
                                         systemImage: "lock.rotation", isSecure: true)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }

                    if let error = viewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Theme.red)
                    }

                    Button(viewModel.primaryButtonTitle) {
                        viewModel.submit()
                    }
                    .buttonStyle(.primaryFilled)
                    .disabled(!viewModel.canSubmit)
                }
                .padding(22)
                .cardBackground(cornerRadius: 28)

                HStack(spacing: 4) {
                    Text(viewModel.switchPrompt)
                        .foregroundStyle(Theme.textSecondary)
                    Button(viewModel.switchActionTitle) {
                        withAnimation(.snappy) { viewModel.toggleMode() }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.primary)
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)

                Label("Tus datos se guardan en este dispositivo y solo tú puedes verlos.", systemImage: "lock.shield")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
            .padding(.top, 12)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(AppBackground(showsPaws: true))
    }

    private var brand: some View {
        VStack(spacing: 10) {
            ZStack {
                PawCluster(scale: 0.8)
                    .offset(x: 78, y: -6)
                Circle()
                    .fill(Theme.surface)
                    .frame(width: 96, height: 96)
                    .overlay(Circle().strokeBorder(Theme.stroke, lineWidth: 1))
                    .softShadow(Theme.primary, opacity: 0.18, radius: 20, y: 10)
                PawHeartLogo(size: 56)
            }
            Text("PetCare")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.primaryGradient)
            Text("Salud, servicios y finanzas para tu mejor amigo.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AuthView(session: SessionViewModel(context: PreviewData.container.mainContext))
}
