import SwiftUI

/// Carrusel de bienvenida. Se muestra una sola vez, antes del registro.
struct IntroView: View {
    let onFinish: () -> Void
    @State private var page = 0

    private let features: [IntroFeature] = [
        IntroFeature(
            title: "Cuida su salud",
            message: "Lleva el control de vacunas, medicamentos, peso y citas.",
            systemImage: "calendar",
            badgeImage: "bell.fill",
            badgeColors: [Color(hex: 0xFFD36B), Color(hex: 0xF2A33A)]
        ),
        IntroFeature(
            title: "Controla tus gastos",
            message: "Registra, organiza y planea los costos de su cuidado.",
            systemImage: "creditcard.fill",
            badgeImage: "dollarsign",
            badgeColors: [Color(hex: 0xFFD36B), Color(hex: 0xE89B2C)]
        ),
        IntroFeature(
            title: "Contrata servicios confiables",
            message: "Veterinarios, estética, paseos y guardería, en un solo lugar.",
            systemImage: "storefront.fill",
            badgeImage: "mappin",
            badgeColors: [Color(hex: 0xB28BFF), Color(hex: 0x6A2FD8)]
        )
    ]

    private var pageCount: Int { features.count + 1 }
    private var isLastPage: Bool { page == pageCount - 1 }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if !isLastPage {
                    Button("Omitir", action: onFinish)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 24)

            TabView(selection: $page) {
                welcomePage
                    .tag(0)
                ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                    featurePage(feature)
                        .tag(index + 1)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack {
                pageDots
                Spacer()
                Button {
                    if isLastPage {
                        onFinish()
                    } else {
                        withAnimation(.snappy) { page += 1 }
                    }
                } label: {
                    Image(systemName: isLastPage ? "checkmark" : "arrow.right")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 62, height: 62)
                        .background(Circle().fill(Theme.primaryGradient))
                        .softShadow(Theme.primary, opacity: 0.4, radius: 14, y: 8)
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel(isLastPage ? "Comenzar" : "Siguiente")
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
        .background(AppBackground())
    }

    // MARK: - Páginas

    private var welcomePage: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 0)
            BrandWordmark(logoSize: 84, fontSize: 44)
            Text("Salud, servicios y finanzas\npara tu mejor amigo.")
                .font(.title3)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            PetsIllustration()
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 32)
    }

    private func featurePage(_ feature: IntroFeature) -> some View {
        VStack(spacing: 28) {
            Spacer(minLength: 0)
            FeatureIllustration(
                systemImage: feature.systemImage,
                badgeImage: feature.badgeImage,
                badgeColors: feature.badgeColors
            )
            VStack(spacing: 12) {
                Text(feature.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                Text(feature.message)
                    .font(.body)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 32)
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == page ? AnyShapeStyle(Theme.primaryGradient) : AnyShapeStyle(Theme.primary.opacity(0.18)))
                    .frame(width: index == page ? 24 : 8, height: 8)
            }
        }
        .animation(.snappy, value: page)
        .accessibilityElement()
        .accessibilityLabel("Página \(page + 1) de \(pageCount)")
    }
}

private struct IntroFeature {
    let title: String
    let message: String
    let systemImage: String
    let badgeImage: String
    let badgeColors: [Color]
}

/// Perro y gato en burbujas de color (portada del carrusel).
private struct PetsIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.softGradient)
                .frame(width: 230, height: 230)

            PawCluster(scale: 0.85)
                .offset(x: -92, y: -78)

            bubble(systemImage: "dog.fill", colors: [Color(hex: 0xFFC27A), Color(hex: 0xF08A4B)], size: 128)
                .offset(x: -44, y: 6)

            bubble(systemImage: "cat.fill", colors: [Color(hex: 0xA98BFF), Color(hex: 0x6A2FD8)], size: 104)
                .offset(x: 62, y: 34)

            Image(systemName: "heart.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(LinearGradient(colors: [Color(hex: 0xFF8DB8), Color(hex: 0xE8579A)],
                                                         startPoint: .topLeading, endPoint: .bottomTrailing)))
                .overlay(Circle().stroke(.white, lineWidth: 3))
                .softShadow(Theme.pink, opacity: 0.35, radius: 8, y: 4)
                .offset(x: 46, y: -62)
        }
        .frame(width: 260, height: 240)
        .accessibilityHidden(true)
    }

    private func bubble(systemImage: String, colors: [Color], size: CGFloat) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.44, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                Circle().fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .overlay(Circle().stroke(.white, lineWidth: 5))
            .softShadow(colors.last ?? Theme.primary, opacity: 0.35, radius: 14, y: 8)
    }
}
