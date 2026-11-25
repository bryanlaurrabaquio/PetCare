import Foundation
import SwiftData
import Observation

/// Única puerta a la base de datos para el usuario con sesión iniciada.
/// Todas las lecturas filtran por `user.id`, así nadie ve datos de otra cuenta.
/// Los ViewModels leen de aquí y la UI se actualiza sola gracias a Observation.
@MainActor
@Observable
final class PetCareStore {
    let user: UserAccount
    private(set) var pets: [PetRecord] = []
    var errorMessage: String?

    private let context: ModelContext

    init(context: ModelContext, user: UserAccount) {
        self.context = context
        self.user = user
        reloadPets()
    }

    // MARK: - Lectura

    func reloadPets() {
        let ownerID = user.id
        let descriptor = FetchDescriptor<PetRecord>(
            predicate: #Predicate<PetRecord> { $0.ownerID == ownerID },
            sortBy: [SortDescriptor(\PetRecord.createdAt)]
        )
        do {
            pets = try context.fetch(descriptor)
        } catch {
            pets = []
            errorMessage = "No pudimos cargar tus mascotas."
        }
    }

    func pet(withID id: UUID?) -> PetRecord? {
        guard let id else { return nil }
        return pets.first { $0.id == id }
    }

    // MARK: - Mascotas

    @discardableResult
    func addPet(_ draft: PetDraft) -> PetRecord {
        let pet = PetRecord(ownerID: user.id, draft: draft)
        context.insert(pet)
        save()
        reloadPets()
        return pet
    }

    func updatePet(_ pet: PetRecord, with draft: PetDraft) {
        pet.apply(draft)
        save()
    }

    func deletePet(_ pet: PetRecord) {
        context.delete(pet)
        save()
        reloadPets()
    }

    // MARK: - Eventos

    func addEvent(_ draft: EventDraft) {
        guard let pet = self.pet(withID: draft.petID) else { return }
        let event = PetEvent(
            title: draft.title.trimmed.isEmpty ? draft.kind.displayName : draft.title.trimmed,
            kind: draft.kind,
            date: draft.date,
            location: draft.location.trimmed,
            notes: draft.notes.trimmed
        )
        pet.events.append(event)
        save()
    }

    func updateEvent(_ event: PetEvent, with draft: EventDraft) {
        event.title = draft.title.trimmed.isEmpty ? draft.kind.displayName : draft.title.trimmed
        event.kindRaw = draft.kind.rawValue
        event.date = draft.date
        event.location = draft.location.trimmed
        event.notes = draft.notes.trimmed

        // Si cambió de mascota, se mueve el evento.
        if let newPet = self.pet(withID: draft.petID), newPet.id != event.pet?.id {
            event.pet?.events.removeAll { $0.id == event.id }
            newPet.events.append(event)
        }
        save()
    }

    func deleteEvent(_ event: PetEvent) {
        event.pet?.events.removeAll { $0.id == event.id }
        context.delete(event)
        save()
    }

    // MARK: - Salud

    func addVaccine(_ draft: VaccineDraft, to pet: PetRecord) {
        let vaccine = Vaccine(
            name: draft.name.trimmed,
            appliedOn: draft.appliedOn,
            nextDose: draft.hasNextDose ? draft.nextDose : nil,
            veterinarian: draft.veterinarian.trimmed,
            batch: draft.batch.trimmed
        )
        pet.vaccines.append(vaccine)
        save()
    }

    func deleteVaccine(_ vaccine: Vaccine) {
        vaccine.pet?.vaccines.removeAll { $0.id == vaccine.id }
        context.delete(vaccine)
        save()
    }

    func addMedication(_ draft: MedicationDraft, to pet: PetRecord) {
        let medication = Medication(
            name: draft.name.trimmed,
            dosage: draft.dosage.trimmed,
            frequency: draft.frequency.trimmed,
            startDate: draft.startDate,
            endDate: draft.hasEndDate ? draft.endDate : nil,
            notes: draft.notes.trimmed
        )
        pet.medications.append(medication)
        save()
    }

    func deleteMedication(_ medication: Medication) {
        medication.pet?.medications.removeAll { $0.id == medication.id }
        context.delete(medication)
        save()
    }

    func addConsultation(_ draft: ConsultationDraft, to pet: PetRecord) {
        let consultation = Consultation(
            date: draft.date,
            reason: draft.reason.trimmed,
            clinic: draft.clinic.trimmed,
            veterinarian: draft.veterinarian.trimmed,
            diagnosis: draft.diagnosis.trimmed
        )
        pet.consultations.append(consultation)
        save()
    }

    func deleteConsultation(_ consultation: Consultation) {
        consultation.pet?.consultations.removeAll { $0.id == consultation.id }
        context.delete(consultation)
        save()
    }

    // MARK: - Finanzas

    func addExpense(_ draft: ExpenseDraft) {
        guard let pet = self.pet(withID: draft.petID), let amount = draft.amount, amount > 0 else { return }
        let expense = Expense(amount: amount, category: draft.category, date: draft.date, note: draft.note.trimmed)
        pet.expenses.append(expense)
        save()
    }

    func deleteExpense(_ expense: Expense) {
        expense.pet?.expenses.removeAll { $0.id == expense.id }
        context.delete(expense)
        save()
    }

    // MARK: - Seguros

    /// Pólizas de todas las mascotas del usuario, las más recientes primero.
    var policies: [InsurancePolicy] {
        pets.flatMap(\.policies).sorted { $0.startDate > $1.startDate }
    }

    @discardableResult
    func addPolicy(_ draft: PolicyDraft) -> InsurancePolicy? {
        guard let pet = self.pet(withID: draft.petID),
              let company = InsuranceCatalog.company(withID: draft.companyID),
              let plan = company.plan(withID: draft.planID) else { return nil }

        let premium = plan.premium(for: draft.paymentFrequency)
        let policy = InsurancePolicy(
            policyNumber: Self.makePolicyNumber(prefix: company.policyPrefix, start: draft.startDate),
            companyID: company.id,
            planID: plan.id,
            startDate: draft.startDate,
            endDate: draft.endDate,
            paymentFrequency: draft.paymentFrequency,
            premium: premium
        )
        pet.policies.append(policy)

        if draft.registersExpense {
            let expense = Expense(amount: premium, category: .insurance, date: draft.startDate,
                                  note: "\(company.name) · \(plan.name)")
            pet.expenses.append(expense)
        }
        save()
        return policy
    }

    func cancelPolicy(_ policy: InsurancePolicy) {
        policy.isCancelled = true
        save()
    }

    func deletePolicy(_ policy: InsurancePolicy) {
        policy.pet?.policies.removeAll { $0.id == policy.id }
        context.delete(policy)
        save()
    }

    /// "HS-2026-483920"
    private static func makePolicyNumber(prefix: String, start: Date) -> String {
        let year = Calendar.current.component(.year, from: start)
        return "\(prefix)-\(year)-\(Int.random(in: 100_000...999_999))"
    }

    // MARK: - Privado

    private func save() {
        do {
            try context.save()
        } catch {
            errorMessage = "No se pudo guardar el cambio."
        }
    }
}
