import Foundation
import SwiftData

enum Species: String, CaseIterable, Identifiable {
    case dog, cat, other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dog: "Perro"
        case .cat: "Gato"
        case .other: "Otro"
        }
    }
}

enum PetSex: String, CaseIterable, Identifiable {
    case female, male

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .female: "Hembra"
        case .male: "Macho"
        }
    }
}

/// Color de la credencial. Se traduce a `Color` en la capa de vista.
enum PetCardStyle: String, CaseIterable, Identifiable {
    case orange, blue, purple, green

    var id: String { rawValue }
}

/// Mascota guardada en SwiftData. `ownerID` la liga a su dueño:
/// todas las consultas filtran por ese campo, así cada usuario solo ve lo suyo.
@Model
final class PetRecord {
    @Attribute(.unique) var id: UUID
    var ownerID: UUID
    var name: String
    var speciesRaw: String
    var breed: String
    var sexRaw: String
    var birthDate: Date
    var weightKg: Double
    var microchip: String
    @Attribute(.externalStorage) var photoData: Data?
    var cardStyleRaw: String
    var createdAt: Date

    // Al borrar la mascota se borra todo su historial.
    @Relationship(deleteRule: .cascade, inverse: \PetEvent.pet)
    var events: [PetEvent] = []

    @Relationship(deleteRule: .cascade, inverse: \Vaccine.pet)
    var vaccines: [Vaccine] = []

    @Relationship(deleteRule: .cascade, inverse: \Medication.pet)
    var medications: [Medication] = []

    @Relationship(deleteRule: .cascade, inverse: \Consultation.pet)
    var consultations: [Consultation] = []

    @Relationship(deleteRule: .cascade, inverse: \Expense.pet)
    var expenses: [Expense] = []

    @Relationship(deleteRule: .cascade, inverse: \InsurancePolicy.pet)
    var policies: [InsurancePolicy] = []

    init(ownerID: UUID, name: String, species: Species, breed: String, sex: PetSex,
         birthDate: Date, weightKg: Double, microchip: String, photoData: Data?,
         cardStyle: PetCardStyle) {
        self.id = UUID()
        self.ownerID = ownerID
        self.name = name
        self.speciesRaw = species.rawValue
        self.breed = breed
        self.sexRaw = sex.rawValue
        self.birthDate = birthDate
        self.weightKg = weightKg
        self.microchip = microchip
        self.photoData = photoData
        self.cardStyleRaw = cardStyle.rawValue
        self.createdAt = .now
    }

    var species: Species { Species(rawValue: speciesRaw) ?? .other }
    var sex: PetSex { PetSex(rawValue: sexRaw) ?? .female }
    var cardStyle: PetCardStyle { PetCardStyle(rawValue: cardStyleRaw) ?? .orange }
}
