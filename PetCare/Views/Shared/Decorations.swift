import SwiftUI

// Detalles decorativos: fondo lavanda, huellitas y logotipo.
// Todos se ocultan a VoiceOver porque no aportan información.

// MARK: - Fondo de la app

/// Fondo lavanda claro con dos manchas de luz difuminadas y, opcionalmente,
/// un rastro de huellitas muy tenue en la esquina superior.
struct AppBackground: View {
    var showsPaws = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Theme.backgroundGradient
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Theme.primaryLight.opacity(0.28))
                        .frame(width: 320, height: 320)
                        .blur(radius: 90)
                        .offset(x: 130, y: -150)
                }
                .overlay(alignment: .bottomLeading) {
                    Circle()
                        .fill(Color(hex: 0xD9C9FF).opacity(0.45))
                        .frame(width: 300, height: 300)
                        .blur(radius: 100)
                        .offset(x: -140, y: 80)
                }
                .ignoresSafeArea()

            if showsPaws {
                PawTrail()
                    .padding(.top, 10)
                    .padding(.leading, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityHidden(true)
    }
}

/// Rastro diagonal de huellitas (como si una mascota hubiera caminado por arriba).
struct PawTrail: View {
    var tint: Color = Theme.primary

    private let steps: [(x: CGFloat, y: CGFloat, size: CGFloat, angle: Double)] = [
        (18, 34, 13, 62), (44, 18, 12, 70), (70, 30, 13, 64), (96, 12, 12, 72)
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(steps.indices, id: \.self) { index in
                let step = steps[index]
                Image(systemName: "pawprint.fill")
                    .font(.system(size: step.size))
                    .rotationEffect(.degrees(step.angle))
                    .offset(x: step.x, y: step.y)
                    .opacity(0.10 + Double(index) * 0.02)
            }
        }
        .foregroundStyle(tint)
        .frame(width: 130, height: 60, alignment: .topLeading)
        .accessibilityHidden(true)
    }
}

// MARK: - Huellitas para encabezados

/// Grupo de tres huellitas en degradado lavanda, para la esquina de los encabezados.
struct PawCluster: View {
    var tint: Color = Theme.primary
    var scale: CGFloat = 1

    var body: some View {
        ZStack {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 56 * scale))
                .rotationEffect(.degrees(-16))
                .offset(x: 14 * scale, y: 6 * scale)
            Image(systemName: "pawprint.fill")
                .font(.system(size: 26 * scale))
                .rotationEffect(.degrees(18))
                .offset(x: -40 * scale, y: -22 * scale)
            Image(systemName: "pawprint.fill")
                .font(.system(size: 16 * scale))
                .rotationEffect(.degrees(-28))
                .offset(x: -52 * scale, y: 22 * scale)
        }
        .foregroundStyle(
            LinearGradient(colors: [tint.opacity(0.30), tint.opacity(0.12)],
                           startPoint: .topTrailing, endPoint: .bottomLeading)
        )
        .frame(width: 120 * scale, height: 90 * scale)
        .accessibilityHidden(true)
    }
}

/// Corazón con huellita adentro (decoración de Salud).
struct HeartPawBadge: View {
    var size: CGFloat = 76

    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .font(.system(size: size))
                .foregroundStyle(
                    LinearGradient(colors: [Theme.primaryLight.opacity(0.45), Theme.primary.opacity(0.22)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            Image(systemName: "pawprint.fill")
                .font(.system(size: size * 0.36))
                .foregroundStyle(.white.opacity(0.95))
                .offset(y: -size * 0.02)
        }
        .rotationEffect(.degrees(8))
        .accessibilityHidden(true)
    }
}

/// Huella grande y transparente para el fondo de tarjetas de color.
struct PawWatermark: View {
    var size: CGFloat = 120
    var opacity: Double = 0.12
    var angle: Double = -20

    var body: some View {
        Image(systemName: "pawprint.fill")
            .font(.system(size: size))
            .foregroundStyle(.white.opacity(opacity))
            .rotationEffect(.degrees(angle))
            .accessibilityHidden(true)
    }
}

// MARK: - Marca

/// Logotipo: huella cuyo cojinete principal es un corazón.
struct PawHeartLogo: View {
    var size: CGFloat = 64

    var body: some View {
        Theme.primaryGradient
            .mask { shape }
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }

    private var shape: some View {
        ZStack {
            toe(width: 0.17, height: 0.23, x: -0.37, y: -0.06, angle: -28)
            toe(width: 0.19, height: 0.25, x: -0.14, y: -0.32, angle: -10)
            toe(width: 0.19, height: 0.25, x: 0.14, y: -0.32, angle: 10)
            toe(width: 0.17, height: 0.23, x: 0.37, y: -0.06, angle: 28)
            Image(systemName: "heart.fill")
                .font(.system(size: size * 0.52, weight: .bold))
                .offset(y: size * 0.2)
        }
        .frame(width: size, height: size)
    }

    private func toe(width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat, angle: Double) -> some View {
        Ellipse()
            .frame(width: size * width, height: size * height)
            .rotationEffect(.degrees(angle))
            .offset(x: size * x, y: size * y)
    }
}

/// Logotipo + nombre de la app.
struct BrandWordmark: View {
    var logoSize: CGFloat = 64
    var fontSize: CGFloat = 34

    var body: some View {
        VStack(spacing: 6) {
            PawHeartLogo(size: logoSize)
            Text("PetCare")
                .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.primaryGradient)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("PetCare")
    }
}

// MARK: - Ilustraciones

/// Ilustración tipo "ícono 3D": tarjeta morada con un símbolo grande,
/// una insignia de acento y huellitas flotando alrededor.
struct FeatureIllustration: View {
    let systemImage: String
    let badgeImage: String
    var badgeColors: [Color] = [Color(hex: 0xFFD36B), Color(hex: 0xF2A33A)]

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.softGradient)
                .frame(width: 220, height: 220)

            PawCluster(scale: 0.8)
                .offset(x: -88, y: -78)

            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Theme.primaryGradient)
                .frame(width: 132, height: 132)
                .overlay {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(LinearGradient(colors: [.white.opacity(0.35), .clear],
                                             startPoint: .top, endPoint: .center))
                }
                .overlay {
                    Image(systemName: systemImage)
                        .font(.system(size: 58, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .softShadow(Theme.primary, opacity: 0.35, radius: 20, y: 12)
                .rotationEffect(.degrees(-6))

            Circle()
                .fill(LinearGradient(colors: badgeColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: badgeImage)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }
                .overlay(Circle().stroke(.white, lineWidth: 4))
                .softShadow(badgeColors.last ?? Theme.yellow, opacity: 0.4, radius: 10, y: 6)
                .offset(x: 62, y: 52)
        }
        .frame(width: 260, height: 240)
        .accessibilityHidden(true)
    }
}
