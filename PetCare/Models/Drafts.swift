import Foundation

// "Drafts": valores que llenan los formularios antes de guardarse.
// Son structs simples, así el formulario se puede cancelar sin tocar la base de datos.

struct PetDraft {
    var name = ""
    var species: Species = .dog
    var breed = ""
    var sex: PetSex = .female
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: .now) ?? .now
    var weightKg: Double = 0
    var microchip = ""
    var photoData: Data?
    var cardStyle: PetCardStyle = .purple

    var isValid: Bool { !name.trimmed.isEmpty }
}

extension PetDraft {
    init(pet: PetRecord) {
        name = pet.name
        species = pet.species
        breed = pet.breed
        sex = pet.sex
        birthDate = pet.birthDate
        weightKg = pet.weightKg
        microchip = pet.microchip
        photoData = pet.photoData
        cardStyle = pet.cardStyle
    }
}

struct EventDraft {
    var petID: UUID?
    var title = ""
    var kind: EventKind = .consultation
    var date: Date = Calendar.current.date(
        bySettingHour: 10, minute: 0, second: 0,
        of: Date.now.addingTimeInterval(86_400)
    ) ?? .now
    var location = ""
    var notes = ""

    var isValid: Bool { petID != nil }
}

extension EventDraft {
    init(event: PetEvent) {
        petID = event.pet?.id
        title = event.title
        kind = event.kind
        date = event.date
        location = event.location
        notes = event.notes
    }
}

struct VaccineDraft {
    var name = ""
    var appliedOn: Date = .now
    var hasNextDose = true
    var nextDose: Date = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
    var veterinarian = ""
    var batch = ""

    var isValid: Bool { !name.trimmed.isEmpty }
}

struct MedicationDraft {
    var name = ""
    var dosage = ""
    var frequency = ""
    var startDate: Date = .now
    var hasEndDate = false
    var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    var notes = ""

    var isValid: Bool { !name.trimmed.isEmpty }
}

struct ConsultationDraft {
    var date: Date = .now
    var reason = ""
    var clinic = ""
    var veterinarian = ""
    var diagnosis = ""

    var isValid: Bool { !reason.trimmed.isEmpty }
}

struct ExpenseDraft {
    var petID: UUID?
    var amountText = ""
    var category: ExpenseCategory = .veterinary
    var date: Date = .now
    var note = ""

    var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: "$", with: "").trimmed)
    }

    var isValid: Bool { petID != nil && (amount ?? 0) > 0 }
}

struct BookingDraft {
    var petID: UUID?
    var date: Date = Calendar.current.date(
        bySettingHour: 10, minute: 0, second: 0,
        of: Date.now.addingTimeInterval(86_400)
    ) ?? .now
    var notes = ""
    var registersExpense = true
}

// MARK: - Aplicar drafts a los modelos

extension PetRecord {
    convenience init(ownerID: UUID, draft: PetDraft) {
        self.init(
            ownerID: ownerID,
            name: draft.name.trimmed,
            species: draft.species,
            breed: draft.breed.trimmed,
            sex: draft.sex,
            birthDate: draft.birthDate,
            weightKg: draft.weightKg,
            microchip: draft.microchip.trimmed,
            photoData: draft.photoData,
            cardStyle: draft.cardStyle
        )
    }

    func apply(_ draft: PetDraft) {
        name = draft.name.trimmed
        speciesRaw = draft.species.rawValue
        breed = draft.breed.trimmed
        sexRaw = draft.sex.rawValue
        birthDate = draft.birthDate
        weightKg = draft.weightKg
        microchip = draft.microchip.trimmed
        photoData = draft.photoData
        cardStyleRaw = draft.cardStyle.rawValue
    }
}
