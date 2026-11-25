import Foundation
import SwiftData

enum EventKind: String, CaseIterable, Identifiable {
    case consultation, vaccine, medication, grooming, walk, daycare, other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .consultation: "Consulta"
        case .vaccine: "Vacuna"
        case .medication: "Medicamento"
        case .grooming: "Estética"
        case .walk: "Paseo"
        case .daycare: "Guardería"
        case .other: "Otro"
        }
    }
}

/// Evento en la agenda de una mascota (cita, paseo, baño…).
@Model
final class PetEvent {
    @Attribute(.unique) var id: UUID
    var title: String
    var kindRaw: String
    var date: Date
    var location: String
    var notes: String
    var pet: PetRecord?

    init(title: String, kind: EventKind, date: Date, location: String, notes: String) {
        self.id = UUID()
        self.title = title
        self.kindRaw = kind.rawValue
        self.date = date
        self.location = location
        self.notes = notes
    }

    var kind: EventKind { EventKind(rawValue: kindRaw) ?? .other }
}
