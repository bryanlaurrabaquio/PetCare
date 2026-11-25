import Foundation
import SwiftData

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case veterinary, food, grooming, medication, accessories, insurance, services, other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .veterinary: "Veterinario"
        case .food: "Alimento"
        case .grooming: "Estética"
        case .medication: "Medicamentos"
        case .accessories: "Accesorios"
        case .insurance: "Seguro"
        case .services: "Servicios"
        case .other: "Otros"
        }
    }
}

@Model
final class Expense {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var categoryRaw: String
    var date: Date
    var note: String
    var pet: PetRecord?

    init(amount: Double, category: ExpenseCategory, date: Date, note: String) {
        self.id = UUID()
        self.amount = amount
        self.categoryRaw = category.rawValue
        self.date = date
        self.note = note
    }

    var category: ExpenseCategory { ExpenseCategory(rawValue: categoryRaw) ?? .other }
}
