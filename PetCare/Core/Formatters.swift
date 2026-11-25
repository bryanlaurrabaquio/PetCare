import Foundation

/// Formateo de fechas y montos en español de México.
enum AppFormatters {
    static let locale = Locale(identifier: "es_MX")

    /// "Jue 28 nov · 10:30"
    static func appointmentDate(_ date: Date) -> String {
        format(date, "EEE d MMM · HH:mm").capitalizingFirstLetter()
    }

    /// "12 mar 2022"
    static func shortDate(_ date: Date) -> String {
        format(date, "d MMM yyyy")
    }

    /// "25 nov"
    static func dayMonth(_ date: Date) -> String {
        format(date, "d MMM")
    }

    /// "10:30"
    static func time(_ date: Date) -> String {
        format(date, "HH:mm")
    }

    /// "Noviembre 2026"
    static func monthYear(_ date: Date) -> String {
        format(date, "LLLL yyyy").capitalizingFirstLetter()
    }

    /// "noviembre"
    static func monthName(_ date: Date) -> String {
        format(date, "LLLL")
    }

    /// "Hoy", "Mañana" o "Jueves 28 de noviembre"
    static func dayHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Hoy" }
        if calendar.isDateInTomorrow(date) { return "Mañana" }
        return format(date, "EEEE d 'de' MMMM").capitalizingFirstLetter()
    }

    /// "Hoy", "Mañana", "En 3 días", "Ayer", "Hace 5 días"
    static func relativeDay(_ date: Date) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: .now),
            to: calendar.startOfDay(for: date)
        ).day ?? 0

        switch days {
        case 0: return "Hoy"
        case 1: return "Mañana"
        case -1: return "Ayer"
        case let d where d > 1: return "En \(d) días"
        default: return "Hace \(-days) días"
        }
    }

    /// "$1,290.00"
    static func currency(_ amount: Double) -> String {
        amount.formatted(.currency(code: "MXN").locale(locale))
    }

    /// "$150,000" (sin centavos, para topes y sumas aseguradas)
    static func wholeCurrency(_ amount: Double) -> String {
        amount.formatted(.currency(code: "MXN").precision(.fractionLength(0)).locale(locale))
    }

    private static func format(_ date: Date, _ pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = pattern
        // Algunas versiones de iOS agregan punto a las abreviaturas ("nov.").
        return formatter.string(from: date).replacingOccurrences(of: ".", with: "")
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + dropFirst()
    }

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Minúsculas y sin acentos, para búsquedas.
    var searchNormalized: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: AppFormatters.locale)
    }
}
