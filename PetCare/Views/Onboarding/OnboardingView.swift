import SwiftUI

/// Primera vez: dar de alta al menos una mascota antes de entrar a la app.
struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel
    @State private var isAddingPet = false
    let onFinish: () -> Void
    let onSignOut: () -> Void

    init(store: PetCareStore, onFinish: @escaping () -> Void, onSignOut: @escaping () -> Void) {
        _viewModel = State(initialValue: OnboardingViewModel(store: store))
        self.onFinish = onFinish
        self.onSignOut = onSignOut
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("PASO 2 DE 2")
                            .font(.caption2.weight(.bold))
                            .tracking(1)
                            .foregroundStyle(Theme.primary)
                        Spacer()
                        Button("Cerrar sesión", action: onSignOut)
                            .font(.footnote)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.title)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Da de alta a tus mascotas para llevar su salud, agenda y gastos en un solo lugar.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    ForEach(viewModel.pets) { pet in
                        OnboardingPetRow(pet: pet)
                    }

                    Button {
                        isAddingPet = true
                    } label: {
                        addPetCard
                    }
                    .buttonStyle(PressableButtonStyle())

                    if viewModel.pets.isEmpty {
                        Button {
                            withAnimation { viewModel.loadDemoData() }
                        } label: {
                            Label("Usar datos de demostración", systemImage: "sparkles")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.primary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(24)
            }
            .scrollIndicators(.hidden)

            Button("Continuar", action: onFinish)
                .buttonStyle(FilledButtonStyle(background: Theme.primary))
                .disabled(!viewModel.canContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
        }
        .background(Theme.background)
        .sheet(isPresented: $isAddingPet) {
            PetFormView(viewModel: viewModel.makeFormViewModel())
        }
    }

    private var addPetCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Theme.primary))
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.addButtonTitle)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text("Nombre, especie, foto y más")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Theme.primary.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
        )
    }
}

private struct OnboardingPetRow: View {
    let pet: PetRecord

    var body: some View {
        HStack(spacing: 14) {
            PetPhotoView(pet: pet)
                .frame(width: 52, height: 52)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(pet.name)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text(pet.summaryText)
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(Theme.green)
        }
        .padding(14)
        .cardBackground()
    }
}
