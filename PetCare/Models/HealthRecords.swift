import Foundation
import SwiftData

/// Vacuna aplicada (una fila del carnet).
@Model
final class Vaccine {
    @Attribute(.unique) var id: UUID
    var name: String
    var appliedOn: Date
    var nextDose: Date?
    var veterinarian: String
    var batch: String
    var pet: PetRecord?

    init(name: String, appliedOn: Date, nextDose: Date?, veterinarian: String, batch: String) {
        self.id = UUID()
        self.name = name
        self.appliedOn = appliedOn
        self.nextDose = nextDose
        self.veterinarian = veterinarian
        self.batch = batch
    }
}

/// Tratamiento o medicamento.
@Model
final class Medication {
    @Attribute(.unique) var id: UUID
    var name: String
    var dosage: String
    var frequency: String
    var startDate: Date
    var endDate: Date?
    var notes: String
    var pet: PetRecord?

    init(name: String, dosage: String, frequency: String, startDate: Date, endDate: Date?, notes: String) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }
}

/// Consulta veterinaria ya realizada.
@Model
final class Consultation {
    @Attribute(.unique) var id: UUID
    var date: Date
    var reason: String
    var clinic: String
    var veterinarian: String
    var diagnosis: String
    var pet: PetRecord?

    init(date: Date, reason: String, clinic: String, veterinarian: String, diagnosis: String) {
        self.id = UUID()
        self.date = date
        self.reason = reason
        self.clinic = clinic
        self.veterinarian = veterinarian
        self.diagnosis = diagnosis
    }
}
