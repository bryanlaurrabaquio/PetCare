import SwiftUI

/// Paleta y tokens del diseño. Cambia aquí y se actualiza toda la app.
enum Theme {
    // Base
    static let background    = Color(hex: 0xF4F2EE)
    static let surface       = Color.white
    static let textPrimary   = Color(hex: 0x1A1A1A)
    static let textSecondary = Color(hex: 0x6E6E73)
    static let chip          = Color(hex: 0xEDEBE7)

    // Marca
    static let primary       = Color(hex: 0xE2603A)
    static let primarySoft   = Color(hex: 0xFBE3DA)
    static let dark          = Color(hex: 0x1C1B1F)
    static let darkElevated  = Color(hex: 0x3A393E)

    // Acentos
    static let blue          = Color(hex: 0x4A6CF7)
    static let purple        = Color(hex: 0x7B5CE6)
    static let green         = Color(hex: 0x3E9B6A)
    static let yellow        = Color(hex: 0xE0A030)
    static let pink          = Color(hex: 0xD94F7A)
    static let teal          = Color(hex: 0x2A9D9F)
    static let gray          = Color(hex: 0x9A9AA0)
    static let red           = Color(hex: 0xD9443A)
}

extension Color {
    /// Crea un color a partir de un hexadecimal, p. ej. `Color(hex: 0xE2603A)`.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

extension View {
    /// Fondo y estilo comunes para los formularios (Form).
    func appFormStyle() -> some View {
        scrollContentBackground(.hidden)
            .background(Theme.background)
    }

    /// Tarjeta blanca redondeada.
    func cardBackground(cornerRadius: CGFloat = 20) -> some View {
        background(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(Theme.surface))
    }
}
