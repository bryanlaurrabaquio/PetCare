import SwiftUI

/// Pantalla de carga: un círculo al centro donde van apareciendo animales.
/// Se muestra cada vez que se abre la app y se puede saltar.
struct SplashView: View {
    /// Duración total en segundos. Cámbiala aquí (por ejemplo a 4 para una carga corta).
    static let duration: Double = 60
    /// Segundos que se queda cada animal.
    static let animalInterval: Double = 2.2

    let onFinish: () -> Void

    @State private var index = 0
    @State private var progress: Double = 0
    @State private var isPulsing = false
    @State private var isSpinning = false
    @State private var didFinish = false

    private let animals: [SplashAnimal] = [
        SplashAnimal(symbol: "dog.fill", name: "Perros", colors: [Color(hex: 0xFFC27A), Color(hex: 0xF08A4B)]),
        SplashAnimal(symbol: "cat.fill", name: "Gatos", colors: [Color(hex: 0xB28BFF), Color(hex: 0x6A2FD8)]),
        SplashAnimal(symbol: "bird.fill", name: "Aves", colors: [Color(hex: 0x6FD3F2), Color(hex: 0x2B8FD6)]),
        SplashAnimal(symbol: "hare.fill", name: "Conejos", colors: [Color(hex: 0xFF9CC4), Color(hex: 0xE8579A)]),
        SplashAnimal(symbol: "fish.fill", name: "Peces", colors: [Color(hex: 0x7BA4FF), Color(hex: 0x4B55E3)]),
        SplashAnimal(symbol: "tortoise.fill", name: "Tortugas", colors: [Color(hex: 0x4AD3A0), Color(hex: 0x11926F)]),
        SplashAnimal(symbol: "lizard.fill", name: "Reptiles", colors: [Color(hex: 0xC6E06B), Color(hex: 0x6FA82E)])
    ]

    private var animal: SplashAnimal { animals[index] }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AppBackground(showsPaws: true)

            VStack(spacing: 0) {
                Spacer()

                animalCircle

                // ZStack: el nombre nuevo y el anterior se enciman durante la transición.
                ZStack {
                    Text(animal.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .id("name-\(index)")
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
                .frame(height: 32)
                .clipped()
                .padding(.top, 36)

                Text("Cuidamos a todos tus amigos")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.top, 6)

                Spacer()

                VStack(spacing: 14) {
                    HStack(spacing: 8) {
                        PawHeartLogo(size: 30)
                        Text("Psh Psh")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.primaryGradient)
                    }
                    GradientProgressBar(value: progress, height: 6)
                        .frame(width: 180)
                    Text("Preparando todo para tus mascotas…")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)

            Button("Saltar", action: finish)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Theme.surface.opacity(0.85)))
                .overlay(Capsule().strokeBorder(Theme.stroke, lineWidth: 1))
                .padding(.trailing, 20)
                .padding(.top, 8)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Cargando Psh Psh")
        .onAppear {
            withAnimation(.linear(duration: Self.duration)) { progress = 1 }
            withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) { isPulsing = true }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) { isSpinning = true }
        }
        .task {
            // Cambia de animal cada `animalInterval` segundos.
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Self.animalInterval))
                guard !Task.isCancelled else { return }
                withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                    index = (index + 1) % animals.count
                }
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(Self.duration))
            guard !Task.isCancelled else { return }
            finish()
        }
    }

    // MARK: - Círculo con el animal

    private var animalCircle: some View {
        ZStack {
            // Ondas que se expanden
            ForEach(0..<2, id: \.self) { ring in
                Circle()
                    .stroke(animal.colors.last ?? Theme.primary, lineWidth: 2)
                    .frame(width: 210, height: 210)
                    .scaleEffect(isPulsing ? 1.45 + Double(ring) * 0.2 : 1)
                    .opacity(isPulsing ? 0 : 0.45)
            }

            // Anillo punteado que gira
            Circle()
                .stroke(
                    Theme.primary.opacity(0.35),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [2, 12])
                )
                .frame(width: 248, height: 248)
                .rotationEffect(.degrees(isSpinning ? 360 : 0))

            // Huellitas alrededor
            ForEach(0..<6, id: \.self) { paw in
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.primary.opacity(0.25))
                    .rotationEffect(.degrees(Double(paw) * 60 + 90))
                    .offset(y: -150)
                    .rotationEffect(.degrees(Double(paw) * 60 + (isSpinning ? -360 : 0)))
            }

            Circle()
                .fill(Theme.surface)
                .frame(width: 214, height: 214)
                .softShadow(Theme.primary, opacity: 0.2, radius: 24, y: 12)

            Circle()
                .fill(LinearGradient(colors: animal.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 184, height: 184)

            Image(systemName: animal.symbol)
                .font(.system(size: 84, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
                .id("animal-\(index)")
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.2).combined(with: .opacity),
                    removal: .scale(scale: 1.5).combined(with: .opacity)
                ))
        }
        .frame(width: 300, height: 300)
        .accessibilityHidden(true)
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        onFinish()
    }
}

private struct SplashAnimal {
    let symbol: String
    let name: String
    let colors: [Color]
}

#Preview {
    SplashView(onFinish: {})
}
