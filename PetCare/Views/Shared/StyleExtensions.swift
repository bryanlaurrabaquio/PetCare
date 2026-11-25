import SwiftUI

// Estilos visuales de los modelos. Viven en la capa de vista para que
// los modelos no dependan de SwiftUI.

extension PetCardStyle {
    var color: Color {
        switch self {
        case .orange: Theme.primary
        case .blue: Theme.blue
        case .purple: Theme.purple
        case .green: Theme.green
        }
    }
}

extension Species {
    var systemImage: String {
        switch self {
        case .dog: "dog.fill"
        case .cat: "cat.fill"
        case .other: "pawprint.fill"
        }
    }
}

extension EventKind {
    var systemImage: String {
        switch self {
        case .consultation: "stethoscope"
        case .vaccine: "syringe"
        case .medication: "pills"
        case .grooming: "scissors"
        case .walk: "shoeprints.fill"
        case .daycare: "bed.double"
        case .other: "calendar"
        }
    }

    var tint: Color {
        switch self {
        case .consultation: Theme.primary
        case .vaccine: Theme.green
        case .medication: Theme.pink
        case .grooming: Theme.purple
        case .walk: Theme.teal
        case .daycare: Theme.blue
        case .other: Theme.gray
        }
    }
}

extension ServiceCategory {
    var systemImage: String { eventKind.systemImage }
    var tint: Color { eventKind.tint }
}

extension ExpenseCategory {
    var systemImage: String {
        switch self {
        case .veterinary: "stethoscope"
        case .food: "fork.knife"
        case .grooming: "scissors"
        case .medication: "pills"
        case .accessories: "tag"
        case .insurance: "checkmark.shield"
        case .services: "figure.walk"
        case .other: "ellipsis.circle"
        }
    }

    var tint: Color {
        switch self {
        case .veterinary: Theme.primary
        case .food: Theme.green
        case .grooming: Theme.purple
        case .medication: Theme.pink
        case .accessories: Theme.blue
        case .insurance: Theme.teal
        case .services: Theme.yellow
        case .other: Theme.gray
        }
    }
}

extension DoseStatus {
    var tint: Color {
        switch self {
        case .noBooster, .completed: Theme.gray
        case .overdue: Theme.red
        case .upcoming: Theme.green
        }
    }
}

extension VaccineStatus {
    var tint: Color {
        switch self {
        case .upToDate: Theme.green
        case .overdue: Theme.red
        case .noRecords: Theme.gray
        }
    }
}
