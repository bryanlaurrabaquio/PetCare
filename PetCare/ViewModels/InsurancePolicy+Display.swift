import Foundation

/// Estado de una póliza según la fecha de hoy.
enum PolicyStatus: Equatable {
    case scheduled, active, expiringSoon, expired, cancelled

    var text: String {
        switch self {
        case .scheduled: "Inicia pronto"
        case .active: "Vigente"
        case .expiringSoon: "Por vencer"
        case .expired: "Vencida"
        case .cancelled: "Cancelada"
        }
    }

    var systemImage: String {
        switch self {
        case .scheduled: "clock.fill"
        case .active: "checkmark.seal.fill"
        case .expiringSoon: "exclamationmark.circle.fill"
        case .expired: "xmark.circle.fill"
        case .cancelled: "minus.circle.fill"
        }
    }
}

/// Textos y cálculos listos para mostrar.
extension InsurancePolicy {
    var status: PolicyStatus {
        if isCancelled { return .cancelled }
        let today = Calendar.current.startOfDay(for: .now)
        if startDate > Date.now { return .scheduled }
        if endDate < today { return .expired }
        return daysRemaining <= 30 ? .expiringSoon : .active
    }

    /// Cubre hoy (vigente o por vencer).
    var isInForce: Bool { status == .active || status == .expiringSoon }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day], from: calendar.startOfDay(for: .now), to: calendar.startOfDay(for: endDate)
        ).day ?? 0
        return max(days, 0)
    }

    /// Avance de la vigencia, de 0 (inicio) a 1 (fin).
    var elapsedFraction: Double {
        let total = endDate.timeIntervalSince(startDate)
        guard total > 0 else { return 1 }
        return min(max(Date.now.timeIntervalSince(startDate) / total, 0), 1)
    }

    var validityText: String {
        "\(AppFormatters.shortDate(startDate)) – \(AppFormatters.shortDate(endDate))"
    }

    var remainingText: String {
        switch status {
        case .scheduled: "Inicia el \(AppFormatters.shortDate(startDate))"
        case .expired: "Venció el \(AppFormatters.shortDate(endDate))"
        case .cancelled: "Póliza cancelada"
        case .active, .expiringSoon:
            daysRemaining == 1 ? "Vence mañana" : "Vence en \(daysRemaining) días"
        }
    }

    var premiumText: String {
        "\(AppFormatters.currency(premium))\(paymentFrequency.shortSuffix)"
    }

    /// Fin del periodo de espera para coberturas por enfermedad.
    var waitingPeriodEnd: Date {
        Calendar.current.date(byAdding: .day, value: plan?.waitingDays ?? 0, to: startDate) ?? startDate
    }

    var waitingPeriodText: String {
        guard let days = plan?.waitingDays, days > 0 else { return "Sin periodo de espera" }
        if waitingPeriodEnd <= Date.now { return "\(days) días · ya cumplido" }
        return "\(days) días · termina el \(AppFormatters.shortDate(waitingPeriodEnd))"
    }

    /// Siguiente cobro (solo pago mensual y póliza vigente).
    var nextPaymentDate: Date? {
        guard paymentFrequency == .monthly, isInForce else { return nil }
        let calendar = Calendar.current
        var month = 1
        while let date = calendar.date(byAdding: .month, value: month, to: startDate), date < endDate {
            if date > Date.now { return date }
            month += 1
        }
        return nil
    }

    var displayTitle: String {
        "\(company?.name ?? "Aseguradora") · \(plan?.name ?? "Plan")"
    }

    /// Texto para compartir la póliza.
    var shareText: String {
        var lines = [
            "Póliza \(policyNumber)",
            displayTitle,
            "Asegurado: \(pet?.name ?? "—")",
            "Vigencia: \(validityText)",
            "Estado: \(status.text)"
        ]
        if let plan {
            lines.append("Suma asegurada: \(AppFormatters.currency(plan.sumInsured))")
            lines.append("Deducible: \(AppFormatters.currency(plan.deductible))")
        }
        return lines.joined(separator: "\n")
    }
}

extension PetRecord {
    /// La póliza que cubre hoy, si hay.
    var activePolicy: InsurancePolicy? {
        policies.filter(\.isInForce).max { $0.startDate < $1.startDate }
    }
}

extension InsurancePlan {
    var coinsuranceText: String { "\(Int((coinsurance * 100).rounded())) %" }
}
