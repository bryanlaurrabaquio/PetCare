import SwiftUI

// Estilos visuales de los modelos. Viven en la capa de vista para que
// los modelos no dependan de SwiftUI.

extension PetCardStyle {
    /// Color principal de la credencial (anillos, barras, acentos).
    var color: Color {
        switch self {
        case .orange: Color(hex: 0xEE7A55)
        case .blue: Color(hex: 0x5873F2)
        case .purple: Theme.primary
        case .green: Color(hex: 0x1FA77D)
        }
    }

    /// Degradado de la credencial y del carnet.
    var gradient: LinearGradient {
        LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var gradientColors: [Color] {
        switch self {
        case .orange: [Color(hex: 0xF7A374), Color(hex: 0xE8634A)]
        case .blue: [Color(hex: 0x7BA4FF), Color(hex: 0x4B55E3)]
        case .purple: [Color(hex: 0x9C6BFF), Color(hex: 0x632BD3)]
        case .green: [Color(hex: 0x4AD3A0), Color(hex: 0x11926F)]
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
        case .medication: Theme.orange
        case .grooming: Theme.pink
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
        case .grooming: Theme.pink
        case .medication: Theme.orange
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
