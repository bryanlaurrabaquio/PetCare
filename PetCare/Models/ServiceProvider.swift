import Foundation

enum ServiceCategory: String, CaseIterable, Identifiable {
    case grooming, veterinary, walks, daycare

    var id: String { rawValue }

    var title: String {
        switch self {
        case .grooming: "Estética"
        case .veterinary: "Veterinaria"
        case .walks: "Paseos"
        case .daycare: "Guardería"
        }
    }

    /// Tipo de evento que se crea al agendar.
    var eventKind: EventKind {
        switch self {
        case .grooming: .grooming
        case .veterinary: .consultation
        case .walks: .walk
        case .daycare: .daycare
        }
    }

    /// Categoría de gasto que se registra en Finanzas.
    var expenseCategory: ExpenseCategory {
        switch self {
        case .grooming: .grooming
        case .veterinary: .veterinary
        case .walks, .daycare: .services
        }
    }

    var bookingTitle: String {
        switch self {
        case .grooming: "Baño y estética"
        case .veterinary: "Consulta veterinaria"
        case .walks: "Paseo"
        case .daycare: "Estancia en guardería"
        }
    }
}

struct ServiceProvider: Identifiable, Hashable {
    let id: String
    let name: String
    let category: ServiceCategory
    let rating: Double
    let reviewCount: Int
    let distanceKm: Double
    let address: String
    let priceFrom: Double
    let schedule: String
    let highlights: [String]

    var searchText: String {
        ([name, address, category.title] + highlights).joined(separator: " ").searchNormalized
    }
}

/// Catálogo de ejemplo (negocios ficticios). Más adelante puede venir de una API.
enum ServiceCatalog {
    static let providers: [ServiceProvider] = [
        // Estética
        ServiceProvider(id: "spa-condesa", name: "Pet Spa Condesa", category: .grooming, rating: 4.9, reviewCount: 312,
                        distanceKm: 1.2, address: "Amsterdam 120, Condesa", priceFrom: 350,
                        schedule: "Lun a sáb · 9:00 a 19:00", highlights: ["Baño", "Corte de raza", "Spa"]),
        ServiceProvider(id: "guau-grooming", name: "Guau Grooming Del Valle", category: .grooming, rating: 4.7, reviewCount: 188,
                        distanceKm: 3.4, address: "Av. Coyoacán 1450, Del Valle", priceFrom: 280,
                        schedule: "Mar a dom · 10:00 a 18:00", highlights: ["Baño", "Corte de uñas", "Recogemos a tu mascota"]),
        ServiceProvider(id: "michi-co", name: "Michi & Co. Estética Felina", category: .grooming, rating: 4.8, reviewCount: 96,
                        distanceKm: 2.6, address: "Medellín 88, Roma Norte", priceFrom: 320,
                        schedule: "Lun a vie · 10:00 a 18:00", highlights: ["Solo gatos", "Baño sin estrés"]),

        // Veterinaria
        ServiceProvider(id: "vetcare-polanco", name: "VetCare Polanco", category: .veterinary, rating: 4.9, reviewCount: 540,
                        distanceKm: 0.8, address: "Homero 230, Polanco", priceFrom: 650,
                        schedule: "Abierto 24 horas", highlights: ["Urgencias", "Vacunas", "Laboratorio"]),
        ServiceProvider(id: "hv-roma", name: "Hospital Veterinario Roma", category: .veterinary, rating: 4.6, reviewCount: 402,
                        distanceKm: 2.9, address: "Orizaba 145, Roma Norte", priceFrom: 550,
                        schedule: "Lun a dom · 8:00 a 22:00", highlights: ["Cirugía", "Rayos X", "Especialistas"]),
        ServiceProvider(id: "patitas-narvarte", name: "Clínica Patitas Narvarte", category: .veterinary, rating: 4.7, reviewCount: 221,
                        distanceKm: 4.1, address: "Eugenia 512, Narvarte", priceFrom: 450,
                        schedule: "Lun a sáb · 9:00 a 20:00", highlights: ["Gatos", "Vacunas", "Desparasitación"]),

        // Paseos
        ServiceProvider(id: "huellitas", name: "Paseos Huellitas", category: .walks, rating: 4.8, reviewCount: 154,
                        distanceKm: 1.5, address: "Parque México, Condesa", priceFrom: 150,
                        schedule: "Todos los días · 7:00 a 20:00", highlights: ["Paseo individual", "GPS en vivo"]),
        ServiceProvider(id: "caminacan", name: "CaminaCan Coyoacán", category: .walks, rating: 4.6, reviewCount: 87,
                        distanceKm: 6.2, address: "Viveros de Coyoacán", priceFrom: 120,
                        schedule: "Lun a sáb · 7:00 a 13:00", highlights: ["Paseo en grupo", "Socialización"]),
        ServiceProvider(id: "walkies", name: "Walkies Santa Fe", category: .walks, rating: 4.5, reviewCount: 63,
                        distanceKm: 9.8, address: "Parque La Mexicana, Santa Fe", priceFrom: 180,
                        schedule: "Todos los días · 6:30 a 21:00", highlights: ["Razas grandes", "Entrenamiento básico"]),

        // Guardería
        ServiceProvider(id: "hotel-lomas", name: "Hotel Canino Lomas", category: .daycare, rating: 4.8, reviewCount: 276,
                        distanceKm: 5.3, address: "Paseo de la Reforma 2210, Lomas", priceFrom: 450,
                        schedule: "Recepción 8:00 a 20:00", highlights: ["Hospedaje", "Cámaras 24/7", "Alberca"]),
        ServiceProvider(id: "casa-peluda", name: "Casa Peluda Guardería", category: .daycare, rating: 4.7, reviewCount: 143,
                        distanceKm: 2.1, address: "Tehuantepec 60, Roma Sur", priceFrom: 320,
                        schedule: "Lun a vie · 7:00 a 19:00", highlights: ["Guardería de día", "Juegos supervisados"]),
        ServiceProvider(id: "kitty-stay", name: "Kitty Stay Escandón", category: .daycare, rating: 4.9, reviewCount: 58,
                        distanceKm: 3.7, address: "Progreso 21, Escandón", priceFrom: 280,
                        schedule: "Todos los días · 9:00 a 19:00", highlights: ["Solo gatos", "Habitaciones privadas"])
    ]
}
