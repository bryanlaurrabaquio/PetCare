import SwiftUI

/// Servicios: buscador + categorías (estética, veterinaria, paseos, guardería).
struct ServicesView: View {
    @Bindable var viewModel: ServicesViewModel
    @State private var selectedProvider: ServiceProvider?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ScreenHeader(title: "Servicios", subtitle: "Encuentra todo lo que tu mascota necesita")

                SearchBar(text: $viewModel.searchText, placeholder: "Buscar veterinarios, estéticas, paseos...")

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "Categorías")
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(viewModel.categories) { category in
                            CategoryTile(
                                category: category,
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                withAnimation(.snappy) { viewModel.toggleCategory(category) }
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: viewModel.resultsTitle)

                    if viewModel.filteredProviders.isEmpty {
                        EmptyStateCard(
                            systemImage: "magnifyingglass",
                            title: "Sin resultados",
                            message: "Prueba con otra palabra o quita el filtro de categoría."
                        )
                    }

                    ForEach(viewModel.filteredProviders) { provider in
                        Button {
                            selectedProvider = provider
                        } label: {
                            ProviderCard(provider: provider)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }

                TrustedServicesBanner()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(AppBackground())
        .sheet(item: $selectedProvider, onDismiss: { viewModel.presentPendingConfirmation() }) { provider in
            BookServiceSheet(
                provider: provider,
                pets: viewModel.pets,
                draft: viewModel.makeBookingDraft()
            ) { draft in
                viewModel.book(provider, with: draft)
            }
        }
        .alert("¡Listo!", isPresented: $viewModel.showsBookingConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.bookingConfirmationMessage)
        }
    }
}

// MARK: - Mosaico de categoría

struct CategoryTile: View {
    let category: ServiceCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: category.systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? AnyShapeStyle(Color.white) : AnyShapeStyle(Theme.primaryGradient))
                    .frame(width: 46, height: 46)
                    .background(
                        Circle().fill(isSelected ? Color.white.opacity(0.18) : Theme.primarySoft)
                    )
                Text(category.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSelected ? Color.white : Theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Theme.primaryGradient)
                        .softShadow(Theme.primary, opacity: 0.35, radius: 10, y: 6)
                } else {
                    Color.clear.cardBackground(cornerRadius: 20)
                }
            }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Tarjeta de proveedor

struct ProviderCard: View {
    let provider: ServiceProvider

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            GradientIconTile(systemImage: provider.category.systemImage, tint: provider.category.tint,
                             size: 64, cornerRadius: 18)

            VStack(alignment: .leading, spacing: 5) {
                Text(provider.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Theme.yellow)
                    Text(String(format: "%.1f", provider.rating))
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.textPrimary)
                    Text("(\(provider.reviewCount) reseñas)")
                        .foregroundStyle(Theme.textSecondary)
                }
                .font(.caption)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Theme.primary.opacity(0.8))
                    Text("A \(String(format: "%.1f", provider.distanceKm)) km · \(provider.address)")
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
                .font(.caption)

                Text("Desde \(AppFormatters.currency(provider.priceFrom))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Theme.primarySoft))
                    .padding(.top, 2)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.textSecondary.opacity(0.7))
                .padding(.top, 4)
        }
        .padding(14)
        .cardBackground(cornerRadius: 22)
    }
}

// MARK: - Banner

/// Banner ilustrado al final de la lista (solo decorativo).
struct TrustedServicesBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Servicios para tu mejor amigo")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Veterinarios, estética, paseos y guardería en un solo lugar.")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Theme.primaryGradient)
                    .frame(width: 78, height: 78)
                    .overlay {
                        Image(systemName: "storefront.fill")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .rotationEffect(.degrees(-6))
                    .softShadow(Theme.primary, opacity: 0.35, radius: 12, y: 8)
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white, Theme.primaryDark)
                    .background(Circle().fill(.white).padding(2))
                    .offset(x: 10, y: 8)
            }
            .padding(.trailing, 8)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Theme.softGradient)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Theme.primary.opacity(0.10))
                        .rotationEffect(.degrees(-24))
                        .offset(x: -112, y: -8)
                        .accessibilityHidden(true)
                }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Theme.primary.opacity(0.12), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Reserva

struct BookServiceSheet: View {
    @Environment(\.dismiss) private var dismiss
    let provider: ServiceProvider
    let pets: [PetRecord]
    let onBook: (BookingDraft) -> Void
    @State private var draft: BookingDraft

    init(provider: ServiceProvider, pets: [PetRecord], draft: BookingDraft, onBook: @escaping (BookingDraft) -> Void) {
        self.provider = provider
        self.pets = pets
        self.onBook = onBook
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        GradientIconTile(systemImage: provider.category.systemImage, tint: provider.category.tint,
                                         size: 52, cornerRadius: 16)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(provider.name)
                                .font(.headline)
                            Label(String(format: "%.1f · %ld reseñas", provider.rating, provider.reviewCount),
                                  systemImage: "star.fill")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                    LabeledContent("Dirección", value: provider.address)
                    LabeledContent("Horario", value: provider.schedule)
                    LabeledContent("Precio", value: "Desde \(AppFormatters.currency(provider.priceFrom))")
                    if !provider.highlights.isEmpty {
                        Text(provider.highlights.joined(separator: " · "))
                            .font(.footnote)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                if pets.isEmpty {
                    Section {
                        Text("Agrega una mascota para poder agendar.")
                            .foregroundStyle(Theme.textSecondary)
                    }
                } else {
                    Section("Agendar") {
                        Picker("Mascota", selection: $draft.petID) {
                            ForEach(pets) { pet in
                                Text(pet.name).tag(Optional(pet.id))
                            }
                        }
                        DatePicker("Fecha y hora", selection: $draft.date, in: Date.now...)
                            .environment(\.locale, AppFormatters.locale)
                        TextField("Notas para el proveedor (opcional)", text: $draft.notes, axis: .vertical)
                            .lineLimit(1...4)
                    }

                    Section {
                        Toggle("Registrar gasto en Finanzas", isOn: $draft.registersExpense)
                    } footer: {
                        Text("Se registrará \(AppFormatters.currency(provider.priceFrom)) como gasto estimado. Puedes editarlo después.")
                    }
                }
            }
            .appFormStyle()
            .navigationTitle(provider.category.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agendar") {
                        onBook(draft)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(draft.petID == nil)
                }
            }
        }
        .tint(Theme.primary)
    }
}

#Preview {
    ServicesView(viewModel: ServicesViewModel(store: PreviewData.store))
}
