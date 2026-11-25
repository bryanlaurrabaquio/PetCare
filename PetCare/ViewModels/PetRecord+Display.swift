import Foundation

/// Textos listos para mostrar. Mantiene el formateo fuera de las vistas.
extension PetRecord {
    var ageText: String {
        let components = Calendar.current.dateComponents([.year, .month], from: birthDate, to: .now)
        let years = components.year ?? 0
        if years >= 1 {
            return years == 1 ? "1 año" : "\(years) años"
        }
        let months = max(components.month ?? 0, 1)
        return months == 1 ? "1 mes" : "\(months) meses"
    }

    var weightText: String {
        weightKg > 0 ? String(format: "%.1f kg", weightKg) : "—"
    }

    var birthDateText: String { AppFormatters.shortDate(birthDate) }
    var microchipText: String { microchip.trimmed.isEmpty ? "—" : microchip }
    var breedText: String { breed.trimmed.isEmpty ? species.displayName : breed }
    var summaryText: String { "\(breedText) · \(ageText)" }

    /// La aplicación más reciente de cada vacuna (agrupada por nombre).
    var currentVaccines: [Vaccine] {
        Dictionary(grouping: vaccines) { $0.name.lowercased() }
            .values
            .compactMap { records in records.max { $0.appliedOn < $1.appliedOn } }
    }

    var vaccineStatus: VaccineStatus {
        let current = currentVaccines
        guard !current.isEmpty else { return .noRecords }
        let today = Calendar.current.startOfDay(for: .now)
        let hasOverdue = current.contains { vaccine in
            guard let next = vaccine.nextDose else { return false }
            return next < today
        }
        return hasOverdue ? .overdue : .upToDate
    }

    var activeMedicationsCount: Int {
        medications.filter(\.isActive).count
    }
}

enum VaccineStatus {
    case upToDate, overdue, noRecords

    var text: String {
        switch self {
        case .upToDate: "Vacunas al día"
        case .overdue: "Vacuna vencida"
        case .noRecords: "Sin vacunas registradas"
        }
    }

    var systemImage: String {
        switch self {
        case .upToDate: "checkmark"
        case .overdue: "exclamationmark"
        case .noRecords: "minus"
        }
    }
}

extension Medication {
    var isActive: Bool {
        guard let endDate else { return true }
        return endDate >= Calendar.current.startOfDay(for: .now)
    }
}
