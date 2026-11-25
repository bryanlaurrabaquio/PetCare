import Foundation
import Observation

@MainActor
@Observable
final class ServicesViewModel {
    var searchText = ""
    private(set) var selectedCategory: ServiceCategory?
    var showsBookingConfirmation = false
    private(set) var bookingConfirmationMessage = ""

    let categories = ServiceCategory.allCases

    private let store: PetCareStore
    private let catalog: [ServiceProvider]
    private var pendingConfirmation: String?

    init(store: PetCareStore) {
        self.store = store
        self.catalog = ServiceCatalog.providers
    }

    // MARK: - Datos de la vista

    var pets: [PetRecord] { store.pets }

    var filteredProviders: [ServiceProvider] {
        let query = searchText.trimmed.searchNormalized
        return catalog
            .filter { selectedCategory == nil || $0.category == selectedCategory }
            .filter { query.isEmpty || $0.searchText.contains(query) }
            .sorted { $0.distanceKm < $1.distanceKm }
    }

    var resultsTitle: String {
        selectedCategory.map { "\($0.title) cerca de ti" } ?? "Cerca de ti"
    }

    func makeBookingDraft() -> BookingDraft {
        BookingDraft(petID: store.pets.first?.id)
    }

    // MARK: - Acciones

    func toggleCategory(_ category: ServiceCategory) {
        selectedCategory = selectedCategory == category ? nil : category
    }

    /// Crea el evento en la agenda y, si se pidió, el gasto estimado.
    func book(_ provider: ServiceProvider, with draft: BookingDraft) {
        guard let pet = store.pet(withID: draft.petID) else { return }

        store.addEvent(EventDraft(
            petID: pet.id,
            title: provider.category.bookingTitle,
            kind: provider.category.eventKind,
            date: draft.date,
            location: provider.name,
            notes: draft.notes
        ))

        if draft.registersExpense {
            store.addExpense(ExpenseDraft(
                petID: pet.id,
                amountText: String(provider.priceFrom),
                category: provider.category.expenseCategory,
                date: draft.date,
                note: provider.name
            ))
        }

        pendingConfirmation = "\(provider.category.bookingTitle) para \(pet.name) el \(AppFormatters.appointmentDate(draft.date)). Ya aparece en Inicio."
    }

    /// Se llama cuando se cierra la hoja de reserva, para mostrar la confirmación.
    func presentPendingConfirmation() {
        guard let pendingConfirmation else { return }
        bookingConfirmationMessage = pendingConfirmation
        self.pendingConfirmation = nil
        showsBookingConfirmation = true
    }
}
