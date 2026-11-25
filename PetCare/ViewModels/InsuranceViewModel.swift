import Foundation
import Observation

/// Seguros: catálogo de aseguradoras, contratación y consulta de pólizas.
@MainActor
@Observable
final class InsuranceViewModel {
    let companies = InsuranceCatalog.companies

    private let store: PetCareStore

    init(store: PetCareStore) {
        self.store = store
    }

    // MARK: - Datos de la vista

    var pets: [PetRecord] { store.pets }

    /// Primero las que cubren hoy; después programadas, vencidas y canceladas.
    var policies: [InsurancePolicy] {
        store.policies.sorted { lhs, rhs in
            if lhs.isInForce != rhs.isInForce { return lhs.isInForce }
            return lhs.startDate > rhs.startDate
        }
    }

    var insuredPets: [PetRecord] { pets.filter { $0.activePolicy != nil } }
    var uninsuredPets: [PetRecord] { pets.filter { $0.activePolicy == nil } }

    /// "Luna y Max ya tienen seguro. Michi aún no."
    var summaryText: String {
        guard !pets.isEmpty else { return "Agrega una mascota para cotizar su seguro." }
        let insured = Self.joinedNames(insuredPets)
        let uninsured = Self.joinedNames(uninsuredPets)
        let verb = insuredPets.count == 1 ? "ya tiene seguro" : "ya tienen seguro"
        switch (insuredPets.isEmpty, uninsuredPets.isEmpty) {
        case (true, _):
            return "Protege a \(uninsured) desde \(AppFormatters.wholeCurrency(lowestPremium)) al mes."
        case (false, true):
            return "\(insured) \(verb)."
        case (false, false):
            return "\(insured) \(verb). \(uninsured) aún no."
        }
    }

    var lowestPremium: Double { companies.map(\.lowestMonthlyPremium).min() ?? 0 }

    var activePolicyCount: Int { store.policies.filter(\.isInForce).count }

    func ineligibilityReason(for pet: PetRecord, company: InsuranceCompany) -> String? {
        company.ineligibilityReason(for: pet)
    }

    func eligiblePets(for company: InsuranceCompany) -> [PetRecord] {
        pets.filter { company.ineligibilityReason(for: $0) == nil }
    }

    func makeDraft(company: InsuranceCompany, plan: InsurancePlan) -> PolicyDraft {
        let eligible = eligiblePets(for: company)
        // Sugiere primero una mascota sin seguro.
        let suggested = eligible.first { $0.activePolicy == nil } ?? eligible.first
        return PolicyDraft(petID: suggested?.id, companyID: company.id, planID: plan.id)
    }

    // MARK: - Acciones

    func contract(_ draft: PolicyDraft) -> InsurancePolicy? {
        store.addPolicy(draft)
    }

    func cancel(_ policy: InsurancePolicy) {
        store.cancelPolicy(policy)
    }

    func delete(_ policy: InsurancePolicy) {
        store.deletePolicy(policy)
    }

    // MARK: - Privado

    /// "Luna", "Luna y Max", "Luna, Max y Michi"
    private static func joinedNames(_ pets: [PetRecord]) -> String {
        let names = pets.map(\.name)
        guard names.count > 1, let last = names.last else { return names.first ?? "" }
        return names.dropLast().joined(separator: ", ") + " y " + last
    }
}
