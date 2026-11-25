import SwiftUI

/// Paleta y tokens del diseño. Cambia aquí y se actualiza toda la app.
enum Theme {
    // Base
    static let background     = Color(hex: 0xF7F4FD)
    static let backgroundTop  = Color(hex: 0xFAF7FF)
    static let backgroundEnd  = Color(hex: 0xF0E9FC)
    static let surface        = Color.white
    static let field          = Color(hex: 0xF7F3FE)
    static let textPrimary    = Color(hex: 0x1F1535)
    static let textSecondary  = Color(hex: 0x6C6684)
    static let chip           = Color(hex: 0xF2EDFB)
    static let stroke         = Color(hex: 0xECE6F7)
    static let shadow         = Color(hex: 0x4B2A9A)

    // Marca (morado)
    static let primary        = Color(hex: 0x7B3FE4)
    static let primaryDark    = Color(hex: 0x5B2BC0)
    static let primaryLight   = Color(hex: 0xA78BFA)
    static let primarySoft    = Color(hex: 0xEFE7FE)
    static let dark           = Color(hex: 0x3B1C7A)
    static let darkElevated   = Color(hex: 0x56309E)

    // Acentos
    static let blue           = Color(hex: 0x4F7CF7)
    static let purple         = Color(hex: 0x9B6BF2)
    static let green          = Color(hex: 0x22A06B)
    static let yellow         = Color(hex: 0xF2A33A)
    static let pink           = Color(hex: 0xE8579A)
    static let teal           = Color(hex: 0x16A3B5)
    static let orange         = Color(hex: 0xF28C4B)
    static let gray           = Color(hex: 0x9C97AE)
    static let red            = Color(hex: 0xE5484D)

    // Degradados
    /// Botones principales, ícono de marca, indicadores.
    static var primaryGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: 0x9461F5), Color(hex: 0x6A2FD8)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Tarjetas protagonistas (próxima cita).
    static var heroGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: 0x6A35C9), Color(hex: 0x3B1C7A)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Fondo general de la app: lavanda muy claro.
    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [backgroundTop, background, backgroundEnd],
                       startPoint: .top, endPoint: .bottom)
    }

    /// Relleno suave para mosaicos y banners.
    static var softGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: 0xF4EEFF), Color(hex: 0xE9DEFD)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension Color {
    /// Crea un color a partir de un hexadecimal, p. ej. `Color(hex: 0x7B3FE4)`.
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
            .background(AppBackground(showsPaws: false))
    }

    /// Tarjeta blanca redondeada con borde fino y sombra lila suave.
    func cardBackground(cornerRadius: CGFloat = 20) -> some View {
        background {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.surface)
                    .shadow(color: Theme.shadow.opacity(0.07), radius: 14, x: 0, y: 6)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Theme.stroke, lineWidth: 1)
            }
        }
    }

    /// Sombra lila para elementos que flotan (botones, tarjetas de color).
    /// `compositingGroup()` hace que la sombra sea de la silueta completa
    /// y no de cada texto o ícono interno.
    func softShadow(_ color: Color = Theme.primary, opacity: Double = 0.25, radius: CGFloat = 12, y: CGFloat = 6) -> some View {
        compositingGroup()
            .shadow(color: color.opacity(opacity), radius: radius, x: 0, y: y)
    }
}
