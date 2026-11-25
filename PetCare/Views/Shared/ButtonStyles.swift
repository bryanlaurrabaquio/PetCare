import SwiftUI

/// Botón sólido de ancho completo. Usa `.primary` para el botón morado con degradado.
struct FilledButtonStyle: ButtonStyle {
    var background: AnyShapeStyle
    var foreground: Color = .white
    var glow: Color = .clear
    var height: CGFloat = 50
    @Environment(\.isEnabled) private var isEnabled

    init(background: Color, foreground: Color = .white, height: CGFloat = 50) {
        self.background = AnyShapeStyle(background)
        self.foreground = foreground
        self.height = height
    }

    init(gradient: LinearGradient, foreground: Color = .white, glow: Color, height: CGFloat = 50) {
        self.background = AnyShapeStyle(gradient)
        self.foreground = foreground
        self.glow = glow
        self.height = height
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(background)
                    .shadow(color: glow.opacity(isEnabled ? 0.35 : 0), radius: 12, x: 0, y: 6)
            )
            .opacity(isEnabled ? (configuration.isPressed ? 0.88 : 1) : 0.45)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == FilledButtonStyle {
    /// Botón principal morado con degradado y brillo suave.
    static var primaryFilled: FilledButtonStyle {
        FilledButtonStyle(gradient: Theme.primaryGradient, glow: Theme.primary)
    }

    /// Botón secundario lavanda con texto morado.
    static var softFilled: FilledButtonStyle {
        FilledButtonStyle(background: Theme.primarySoft, foreground: Theme.primary)
    }
}

/// Feedback sutil al presionar tarjetas y mosaicos.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
