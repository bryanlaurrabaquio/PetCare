import Foundation
import Observation

/// Estado de la siguiente dosis de una vacuna.
enum DoseStatus {
    case noBooster, completed, overdue, upcoming(Date)

    var text: String {
        switch self {
        case .noBooster: "Sin refuerzo"
        case .completed: "Renovada"
        case .overdue: "Vencida"
        case .upcoming(let date): "Próxima: \(AppFormatters.shortDate(date))"
        }
    }
}

@MainActor
@Observable
final class HealthViewModel {
    private(set) var selectedPetID: UUID?

    private let store: PetCareStore

    init(store: PetCareStore) {
        self.store = store
    }

    // MARK: - Datos de la vista

    var pets: [PetRecord] { store.pets }

    /// Si no hay selección, se muestra la primera mascota.
    var selectedPet: PetRecord? { store.pet(withID: selectedPetID) ?? store.pets.first }

    var vaccines: [Vaccine] {
        (selectedPet?.vaccines ?? []).sorted { $0.appliedOn > $1.appliedOn }
    }

    var medications: [Medication] {
        (selectedPet?.medications ?? []).sorted { lhs, rhs in
            if lhs.isActive != rhs.isActive { return lhs.isActive }
            return lhs.startDate > rhs.startDate
        }
    }

    var consultations: [Consultation] {
        (selectedPet?.consultations ?? []).sorted { $0.date > $1.date }
    }

    func doseStatus(for vaccine: Vaccine) -> DoseStatus {
        guard let next = vaccine.nextDose else { return .noBooster }
        let isSuperseded = vaccines.contains {
            $0.id != vaccine.id
                && $0.name.lowercased() == vaccine.name.lowercased()
                && $0.appliedOn > vaccine.appliedOn
        }
        if isSuperseded { return .completed }
        if next < Calendar.current.startOfDay(for: .now) { return .overdue }
        return .upcoming(next)
    }

    func medicationPeriodText(_ medication: Medication) -> String {
        let start = "Desde \(AppFormatters.shortDate(medication.startDate))"
        guard let end = medication.endDate else { return start + " · Sin fecha de fin" }
        return start + " · hasta \(AppFormatters.shortDate(end))"
    }

    // MARK: - Acciones

    func selectPet(_ id: UUID?) {
        selectedPetID = id
    }

    func addVaccine(_ draft: VaccineDraft) {
        guard let pet = selectedPet else { return }
        store.addVaccine(draft, to: pet)
    }

    func addMedication(_ draft: MedicationDraft) {
        guard let pet = selectedPet else { return }
        store.addMedication(draft, to: pet)
    }

    func addConsultation(_ draft: ConsultationDraft) {
        guard let pet = selectedPet else { return }
        store.addConsultation(draft, to: pet)
    }

    func delete(_ vaccine: Vaccine) { store.deleteVaccine(vaccine) }
    func delete(_ medication: Medication) { store.deleteMedication(medication) }
    func delete(_ consultation: Consultation) { store.deleteConsultation(consultation) }
}
