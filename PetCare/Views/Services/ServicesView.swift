import SwiftUI

/// Servicios: buscador + categorías (estética, veterinaria, paseos, guardería).
struct ServicesView: View {
    @Bindable var viewModel: ServicesViewModel
    @State private var selectedProvider: ServiceProvider?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ScreenHeader(title: "Servicios", subtitle: "Todo lo que necesita tu mascota")

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
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background)
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
            VStack(spacing: 8) {
                Image(systemName: category.systemImage)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .white : category.tint)
                    .frame(width: 64, height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(isSelected ? category.tint : category.tint.opacity(0.14))
                    )
                Text(category.title)
                    .font(.caption.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
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
            IconTile(systemImage: provider.category.systemImage, tint: provider.category.tint, size: 52, cornerRadius: 14)

            VStack(alignment: .leading, spacing: 4) {
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
                    Text("(\(provider.reviewCount)) · \(String(format: "%.1f", provider.distanceKm)) km")
                        .foregroundStyle(Theme.textSecondary)
                }
                .font(.caption)

                Text(provider.address)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)

                Text("Desde \(AppFormatters.currency(provider.priceFrom))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                    .padding(.top, 2)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
                .padding(.top, 4)
        }
        .padding(14)
        .cardBackground(cornerRadius: 18)
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
                        IconTile(systemImage: provider.category.systemImage, tint: provider.category.tint,
                                 size: 52, cornerRadius: 14)
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
