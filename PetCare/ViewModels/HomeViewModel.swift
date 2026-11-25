import Foundation
import Observation

/// Un elemento de la agenda en Inicio: un evento creado por el usuario
/// o un refuerzo de vacuna que viene del carnet.
struct UpcomingItem: Identifiable {
    let id: String
    let petID: UUID
    let petName: String
    let title: String
    let kind: EventKind
    let date: Date
    let location: String
    let notes: String
    let showsTime: Bool
    /// Solo existe si es un evento editable (no un refuerzo de vacuna).
    let event: PetEvent?

    var headline: String { "\(title) · \(petName)" }

    func subtitle(showingPet: Bool) -> String {
        var parts: [String] = []
        if showingPet { parts.append(petName) }
        if showsTime { parts.append(AppFormatters.time(date)) }
        if !location.isEmpty { parts.append(location) }
        return parts.joined(separator: " · ")
    }
}

struct UpcomingSection: Identifiable {
    let id: Date
    let title: String
    let items: [UpcomingItem]
}

@MainActor
@Observable
final class HomeViewModel {
    /// `nil` = todas las mascotas.
    private(set) var selectedPetID: UUID?

    private let store: PetCareStore

    init(store: PetCareStore) {
        self.store = store
    }

    // MARK: - Datos de la vista

    var pets: [PetRecord] { store.pets }
    var userName: String { store.user.name }
    var userEmail: String { store.user.email }

    var greeting: String {
        let firstName = userName.split(separator: " ").first.map(String.init) ?? userName
        return "Hola, \(firstName)"
    }

    var showsPetNames: Bool { selectedPet == nil }
    var selectedPet: PetRecord? { store.pet(withID: selectedPetID) }

    var upcomingItems: [UpcomingItem] {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        let scopedPets = selectedPet.map { [$0] } ?? store.pets
        var items: [UpcomingItem] = []

        for pet in scopedPets {
            for event in pet.events where event.date >= startOfToday {
                items.append(UpcomingItem(
                    id: "event-\(event.id.uuidString)", petID: pet.id, petName: pet.name,
                    title: event.title, kind: event.kind, date: event.date,
                    location: event.location, notes: event.notes, showsTime: true, event: event
                ))
            }
            for vaccine in pet.currentVaccines {
                guard let next = vaccine.nextDose, next >= startOfToday else { continue }
                items.append(UpcomingItem(
                    id: "vaccine-\(vaccine.id.uuidString)", petID: pet.id, petName: pet.name,
                    title: "Refuerzo: \(vaccine.name)", kind: .vaccine, date: next,
                    location: vaccine.veterinarian,
                    notes: "Recordatorio generado desde el carnet de salud.",
                    showsTime: false, event: nil
                ))
            }
        }
        return items.sorted { $0.date < $1.date }
    }

    var featuredItem: UpcomingItem? { upcomingItems.first }

    /// Eventos restantes agrupados por día.
    var sections: [UpcomingSection] {
        let calendar = Calendar.current
        let rest = Array(upcomingItems.dropFirst())
        let grouped = Dictionary(grouping: rest) { calendar.startOfDay(for: $0.date) }
        return grouped.keys.sorted().map { day in
            UpcomingSection(id: day, title: AppFormatters.dayHeader(day), items: grouped[day] ?? [])
        }
    }

    var emptyTitle: String {
        if let selectedPet { return "\(selectedPet.name) no tiene eventos próximos" }
        return "No hay eventos próximos"
    }

    func pet(for item: UpcomingItem) -> PetRecord? {
        store.pet(withID: item.petID)
    }

    // MARK: - Acciones

    func selectPet(_ id: UUID?) {
        selectedPetID = id
    }

    func makeNewEventDraft() -> EventDraft {
        EventDraft(petID: selectedPetID ?? store.pets.first?.id)
    }

    func saveEvent(_ draft: EventDraft, editing event: PetEvent?) {
        if let event {
            store.updateEvent(event, with: draft)
        } else {
            store.addEvent(draft)
        }
    }

    func deleteEvent(_ event: PetEvent) {
        store.deleteEvent(event)
    }
}
