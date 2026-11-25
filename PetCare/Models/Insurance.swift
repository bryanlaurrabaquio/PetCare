import Foundation
import SwiftData

// MARK: - Catálogo (datos de ejemplo)

/// Tipo de cobertura que puede incluir un plan.
enum CoverageKind: String, CaseIterable, Identifiable {
    case consultations, emergencies, surgery, hospitalization, labs, medications,
         vaccines, telemedicine, civilLiability, theft, funeral

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .consultations: "Consultas veterinarias"
        case .emergencies: "Urgencias 24/7"
        case .surgery: "Cirugías"
        case .hospitalization: "Hospitalización"
        case .labs: "Estudios y laboratorio"
        case .medications: "Medicamentos"
        case .vaccines: "Vacunas y desparasitación"
        case .telemedicine: "Telemedicina"
        case .civilLiability: "Responsabilidad civil"
        case .theft: "Robo o extravío"
        case .funeral: "Gastos funerarios"
        }
    }
}

/// Una cobertura dentro de un plan: tope (si aplica) y una nota corta.
struct CoverageItem: Hashable {
    let kind: CoverageKind
    let limit: Double?
    let note: String

    init(_ kind: CoverageKind, limit: Double? = nil, note: String = "") {
        self.kind = kind
        self.limit = limit
        self.note = note
    }
}

enum PaymentFrequency: String, CaseIterable, Identifiable {
    case monthly, annual

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .monthly: "Mensual"
        case .annual: "Anual"
        }
    }

    var shortSuffix: String {
        switch self {
        case .monthly: "/mes"
        case .annual: "/año"
        }
    }
}

struct InsurancePlan: Identifiable, Hashable {
    let id: String
    let name: String
    let monthlyPremium: Double
    /// Suma asegurada anual (tope total de gastos médicos).
    let sumInsured: Double
    let deductible: Double
    /// Porcentaje que paga el cliente después del deducible (0.10 = 10 %).
    let coinsurance: Double
    /// Días desde el inicio antes de poder usar coberturas por enfermedad.
    let waitingDays: Int
    let coverages: [CoverageItem]
    var isPopular = false

    /// Pago anual con 10 % de descuento.
    var annualPremium: Double { (monthlyPremium * 12 * 0.9).rounded() }

    func premium(for frequency: PaymentFrequency) -> Double {
        frequency == .monthly ? monthlyPremium : annualPremium
    }

    func coverage(for kind: CoverageKind) -> CoverageItem? {
        coverages.first { $0.kind == kind }
    }
}

struct InsuranceCompany: Identifiable, Hashable {
    let id: String
    let name: String
    /// Prefijo de los números de póliza ("HS-2026-123456").
    let policyPrefix: String
    let tagline: String
    let symbol: String
    let style: PetCardStyle
    let rating: Double
    let reviewCount: Int
    let acceptedSpecies: [Species]
    /// Edad máxima (años) para contratar por primera vez.
    let maxEntryAge: Int
    let highlights: [String]
    let plans: [InsurancePlan]

    var lowestMonthlyPremium: Double { plans.map(\.monthlyPremium).min() ?? 0 }

    func plan(withID id: String) -> InsurancePlan? { plans.first { $0.id == id } }

    /// `nil` si la mascota puede contratar; si no, el motivo.
    func ineligibilityReason(for pet: PetRecord) -> String? {
        if !acceptedSpecies.contains(pet.species) {
            return "\(name) no asegura a la especie \(pet.species.displayName.lowercased())."
        }
        let years = Calendar.current.dateComponents([.year], from: pet.birthDate, to: .now).year ?? 0
        if years > maxEntryAge {
            return "Solo acepta mascotas de hasta \(maxEntryAge) años al contratar."
        }
        return nil
    }
}

/// Aseguradoras ficticias para la demo. Más adelante pueden venir de una API.
enum InsuranceCatalog {
    static let companies: [InsuranceCompany] = [
        InsuranceCompany(
            id: "huellitas", name: "Huellitas Seguros", policyPrefix: "HS",
            tagline: "El seguro favorito de los perrhijos",
            symbol: "pawprint.circle.fill", style: .purple, rating: 4.8, reviewCount: 2_140,
            acceptedSpecies: [.dog, .cat], maxEntryAge: 9,
            highlights: ["Reembolso en 72 h", "Red de 1,200 clínicas", "Sin papeleo"],
            plans: [
                InsurancePlan(id: "huellitas-basico", name: "Básico", monthlyPremium: 189, sumInsured: 30_000,
                              deductible: 1_500, coinsurance: 0.20, waitingDays: 30, coverages: [
                                CoverageItem(.emergencies, limit: 10_000),
                                CoverageItem(.surgery, limit: 15_000),
                                CoverageItem(.civilLiability, limit: 50_000),
                                CoverageItem(.telemedicine, note: "Ilimitada")
                              ]),
                InsurancePlan(id: "huellitas-plus", name: "Plus", monthlyPremium: 349, sumInsured: 60_000,
                              deductible: 1_000, coinsurance: 0.10, waitingDays: 30, coverages: [
                                CoverageItem(.consultations, note: "Hasta 6 al año"),
                                CoverageItem(.emergencies, limit: 20_000),
                                CoverageItem(.surgery, limit: 30_000),
                                CoverageItem(.hospitalization, limit: 15_000),
                                CoverageItem(.labs, limit: 5_000),
                                CoverageItem(.civilLiability, limit: 100_000),
                                CoverageItem(.telemedicine, note: "Ilimitada")
                              ], isPopular: true),
                InsurancePlan(id: "huellitas-premium", name: "Premium", monthlyPremium: 599, sumInsured: 120_000,
                              deductible: 500, coinsurance: 0.05, waitingDays: 15, coverages: [
                                CoverageItem(.consultations, note: "Ilimitadas en red"),
                                CoverageItem(.emergencies, limit: 40_000),
                                CoverageItem(.surgery, limit: 60_000),
                                CoverageItem(.hospitalization, limit: 30_000),
                                CoverageItem(.labs, limit: 10_000),
                                CoverageItem(.medications, limit: 6_000),
                                CoverageItem(.vaccines, note: "Esquema anual completo"),
                                CoverageItem(.civilLiability, limit: 200_000),
                                CoverageItem(.funeral, limit: 5_000),
                                CoverageItem(.telemedicine, note: "Ilimitada")
                              ])
            ]
        ),
        InsuranceCompany(
            id: "patita", name: "PatitaSegura", policyPrefix: "PS",
            tagline: "Gastos médicos sin complicaciones",
            symbol: "cross.case.fill", style: .blue, rating: 4.6, reviewCount: 980,
            acceptedSpecies: [.dog, .cat], maxEntryAge: 8,
            highlights: ["Pago directo en clínica", "App de reembolsos"],
            plans: [
                InsurancePlan(id: "patita-esencial", name: "Esencial", monthlyPremium: 159, sumInsured: 25_000,
                              deductible: 2_000, coinsurance: 0.20, waitingDays: 30, coverages: [
                                CoverageItem(.emergencies, limit: 12_000),
                                CoverageItem(.surgery, limit: 12_000),
                                CoverageItem(.hospitalization, limit: 6_000)
                              ]),
                InsurancePlan(id: "patita-completo", name: "Completo", monthlyPremium: 429, sumInsured: 80_000,
                              deductible: 1_000, coinsurance: 0.10, waitingDays: 20, coverages: [
                                CoverageItem(.consultations, note: "Hasta 8 al año"),
                                CoverageItem(.emergencies, limit: 25_000),
                                CoverageItem(.surgery, limit: 40_000),
                                CoverageItem(.hospitalization, limit: 20_000),
                                CoverageItem(.labs, limit: 8_000),
                                CoverageItem(.medications, limit: 4_000),
                                CoverageItem(.civilLiability, limit: 80_000)
                              ], isPopular: true)
            ]
        ),
        InsuranceCompany(
            id: "vetprotect", name: "VetProtect Mascotas", policyPrefix: "VP",
            tagline: "Especialistas en mascotas mayores",
            symbol: "heart.circle.fill", style: .green, rating: 4.7, reviewCount: 615,
            acceptedSpecies: [.dog, .cat, .other], maxEntryAge: 12,
            highlights: ["Acepta hasta 12 años", "Incluye exóticos", "Chequeo anual gratis"],
            plans: [
                InsurancePlan(id: "vetprotect-salud", name: "Salud", monthlyPremium: 249, sumInsured: 40_000,
                              deductible: 1_200, coinsurance: 0.15, waitingDays: 30, coverages: [
                                CoverageItem(.consultations, note: "Hasta 4 al año"),
                                CoverageItem(.emergencies, limit: 15_000),
                                CoverageItem(.labs, limit: 6_000),
                                CoverageItem(.vaccines, note: "1 aplicación anual"),
                                CoverageItem(.telemedicine, note: "Ilimitada")
                              ]),
                InsurancePlan(id: "vetprotect-total", name: "Salud Total", monthlyPremium: 529, sumInsured: 100_000,
                              deductible: 800, coinsurance: 0.10, waitingDays: 20, coverages: [
                                CoverageItem(.consultations, note: "Ilimitadas en red"),
                                CoverageItem(.emergencies, limit: 35_000),
                                CoverageItem(.surgery, limit: 50_000),
                                CoverageItem(.hospitalization, limit: 25_000),
                                CoverageItem(.labs, limit: 10_000),
                                CoverageItem(.medications, limit: 5_000),
                                CoverageItem(.vaccines, note: "Esquema anual completo"),
                                CoverageItem(.telemedicine, note: "Ilimitada")
                              ], isPopular: true)
            ]
        ),
        InsuranceCompany(
            id: "colita", name: "Colita Feliz Seguros", policyPrefix: "CF",
            tagline: "Responsabilidad civil y asistencia",
            symbol: "shield.lefthalf.filled", style: .orange, rating: 4.5, reviewCount: 432,
            acceptedSpecies: [.dog], maxEntryAge: 10,
            highlights: ["Ideal para paseos", "Cubre daños a terceros"],
            plans: [
                InsurancePlan(id: "colita-rc", name: "RC Básica", monthlyPremium: 99, sumInsured: 15_000,
                              deductible: 1_000, coinsurance: 0.20, waitingDays: 0, coverages: [
                                CoverageItem(.civilLiability, limit: 150_000),
                                CoverageItem(.emergencies, limit: 8_000),
                                CoverageItem(.theft, limit: 3_000, note: "Apoyo para búsqueda")
                              ]),
                InsurancePlan(id: "colita-integral", name: "Integral", monthlyPremium: 399, sumInsured: 70_000,
                              deductible: 1_000, coinsurance: 0.10, waitingDays: 30, coverages: [
                                CoverageItem(.consultations, note: "Hasta 6 al año"),
                                CoverageItem(.emergencies, limit: 20_000),
                                CoverageItem(.surgery, limit: 30_000),
                                CoverageItem(.hospitalization, limit: 12_000),
                                CoverageItem(.civilLiability, limit: 250_000),
                                CoverageItem(.theft, limit: 5_000, note: "Apoyo para búsqueda"),
                                CoverageItem(.funeral, limit: 4_000)
                              ], isPopular: true)
            ]
        )
    ]

    static func company(withID id: String) -> InsuranceCompany? {
        companies.first { $0.id == id }
    }
}

// MARK: - Póliza contratada (SwiftData)

/// Póliza de seguro de una mascota. Cuelga de `PetRecord`, así que se borra con ella.
@Model
final class InsurancePolicy {
    @Attribute(.unique) var id: UUID
    var policyNumber: String
    var companyID: String
    var planID: String
    var startDate: Date
    var endDate: Date
    var paymentFrequencyRaw: String
    /// Monto de cada pago (mensual o anual según la frecuencia).
    var premium: Double
    var isCancelled: Bool
    var createdAt: Date
    var pet: PetRecord?

    init(policyNumber: String, companyID: String, planID: String, startDate: Date, endDate: Date,
         paymentFrequency: PaymentFrequency, premium: Double) {
        self.id = UUID()
        self.policyNumber = policyNumber
        self.companyID = companyID
        self.planID = planID
        self.startDate = startDate
        self.endDate = endDate
        self.paymentFrequencyRaw = paymentFrequency.rawValue
        self.premium = premium
        self.isCancelled = false
        self.createdAt = .now
    }

    var paymentFrequency: PaymentFrequency { PaymentFrequency(rawValue: paymentFrequencyRaw) ?? .monthly }
    var company: InsuranceCompany? { InsuranceCatalog.company(withID: companyID) }
    var plan: InsurancePlan? { company?.plan(withID: planID) }
}
