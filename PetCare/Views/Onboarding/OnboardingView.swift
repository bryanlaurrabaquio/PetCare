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
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Theme.primarySoft))
                        Spacer()
                        Button("Cerrar sesión", action: onSignOut)
                            .font(.footnote)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.title)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Da de alta a tus mascotas para llevar su salud, agenda y gastos en un solo lugar.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.trailing, 60)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(alignment: .topTrailing) {
                        PawCluster(scale: 0.9)
                            .offset(x: 8, y: -4)
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
                .buttonStyle(.primaryFilled)
                .disabled(!viewModel.canContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
        }
        .background(AppBackground())
        .sheet(isPresented: $isAddingPet) {
            PetFormView(viewModel: viewModel.makeFormViewModel())
        }
    }

    private var addPetCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(Circle().fill(Theme.primaryGradient))
                .softShadow(Theme.primary, opacity: 0.3, radius: 8, y: 4)
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
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Theme.surface.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Theme.primary.opacity(0.45), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
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
                .overlay(Circle().strokeBorder(pet.cardStyle.gradient, lineWidth: 2.5))
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
        .cardBackground(cornerRadius: 22)
    }
}
