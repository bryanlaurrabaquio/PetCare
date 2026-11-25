import SwiftUI

struct MyPetsView: View {
    @Bindable var viewModel: MyPetsViewModel
    let onOpenHealth: (PetRecord) -> Void
    let onOpenExpenses: (PetRecord) -> Void

    /// Formulario abierto (alta o edición). Se guarda el ViewModel completo para que
    /// la hoja no vuelva a leer la mascota si se elimina mientras se cierra.
    @State private var petForm: PetFormViewModel?

    /// Altura de una credencial colapsada y cuánto se encima la siguiente.
    private let collapsedHeight: CGFloat = 92
    private let overlap: CGFloat = 26

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(title: "Mis mascotas", subtitle: viewModel.subtitle) {
                    CircleIconButton(systemImage: "plus", label: "Agregar mascota") {
                        petForm = viewModel.makeFormViewModel(for: nil)
                    }
                }

                if viewModel.pets.isEmpty {
                    EmptyStateCard(
                        systemImage: "pawprint",
                        title: "Aún no tienes mascotas",
                        message: "Agrega a tu mascota para generar su credencial con QR.",
                        actionTitle: "Agregar mascota",
                        action: { petForm = viewModel.makeFormViewModel(for: nil) }
                    )
                } else {
                    cardStack
                    if let pet = viewModel.selectedPet {
                        actionButtons(for: pet)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Theme.background)
        .sheet(item: $petForm) { form in
            PetFormView(viewModel: form)
        }
    }

    // MARK: - Credenciales apiladas (estilo Wallet)

    private var cardStack: some View {
        VStack(spacing: -overlap) {
            ForEach(Array(viewModel.stackedPets.enumerated()), id: \.element.id) { index, pet in
                let isSelected = viewModel.isSelected(pet)

                PetIDCard(
                    pet: pet,
                    isExpanded: isSelected,
                    qrImage: isSelected ? viewModel.qrCode(for: pet) : nil,
                    collapsedHeight: collapsedHeight
                )
                .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: -2)
                .zIndex(Double(index))
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        viewModel.select(pet)
                    }
                }
                .contextMenu {
                    Button {
                        petForm = viewModel.makeFormViewModel(for: pet)
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                }
                .accessibilityAddTraits(isSelected ? .isSelected : .isButton)
            }
        }
    }

    // MARK: - Acciones

    private func actionButtons(for pet: PetRecord) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Button {
                    onOpenHealth(pet)
                } label: {
                    ActionChip(title: "Cartilla", systemImage: "syringe", tint: Theme.green)
                }

                Button {
                    onOpenExpenses(pet)
                } label: {
                    ActionChip(title: "Gastos", systemImage: "creditcard", tint: Theme.blue)
                }

                ShareLink(item: viewModel.shareText(for: pet)) {
                    ActionChip(title: "Compartir", systemImage: "square.and.arrow.up", tint: Theme.textPrimary)
                }
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                petForm = viewModel.makeFormViewModel(for: pet)
            } label: {
                Label("Editar datos de \(pet.name)", systemImage: "pencil")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.primary)
            }
        }
    }
}

struct ActionChip: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
            Text(title)
                .foregroundStyle(Theme.textPrimary)
        }
        .font(.subheadline.weight(.semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .cardBackground(cornerRadius: 14)
    }
}

#Preview {
    MyPetsView(viewModel: MyPetsViewModel(store: PreviewData.store), onOpenHealth: { _ in }, onOpenExpenses: { _ in })
}
