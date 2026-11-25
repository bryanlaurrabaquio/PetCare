import SwiftUI

/// Registro e inicio de sesión con correo y contraseña.
struct AuthView: View {
    @State private var viewModel: AuthViewModel

    init(session: SessionViewModel) {
        _viewModel = State(initialValue: AuthViewModel(session: session))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                brand

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.title)
                        .font(.system(size: 30, weight: .bold))
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

                VStack(spacing: 16) {
                    Button(viewModel.primaryButtonTitle) {
                        viewModel.submit()
                    }
                    .buttonStyle(FilledButtonStyle(background: Theme.primary))
                    .disabled(!viewModel.canSubmit)

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
                }

                Label("Tus datos se guardan en este dispositivo y solo tú puedes verlos.", systemImage: "lock.shield")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
            .padding(.top, 24)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background)
    }

    private var brand: some View {
        HStack(spacing: 12) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.primary))
            Text("PetCare")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

#Preview {
    AuthView(session: SessionViewModel(context: PreviewData.container.mainContext))
}
