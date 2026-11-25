import SwiftUI

// Componentes reutilizables. Reciben datos simples (no ViewModels)
// para que sean fáciles de previsualizar.

// MARK: - Encabezado de pantalla

/// Decoración de la esquina superior derecha del encabezado.
enum HeaderDecoration {
    case paws, heartPaw, hidden
}

struct ScreenHeader<Trailing: View>: View {
    let title: String
    let subtitle: String?
    var decoration: HeaderDecoration = .paws
    let trailing: Trailing

    init(title: String, subtitle: String? = nil, decoration: HeaderDecoration = .paws,
         @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.subtitle = subtitle
        self.decoration = decoration
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            // Deja aire para que la decoración no quede debajo del texto.
            .padding(.trailing, decoration == .hidden || hasTrailing ? 0 : 64)
            Spacer(minLength: 12)
            trailing
        }
        .padding(.vertical, 4)
        .background(alignment: .topTrailing) {
            decorationView
                .padding(.trailing, hasTrailing ? 54 : 0)
                .offset(y: -10)
        }
    }

    private var hasTrailing: Bool { Trailing.self != EmptyView.self }

    @ViewBuilder
    private var decorationView: some View {
        switch decoration {
        case .paws:
            PawCluster()
        case .heartPaw:
            HeartPawBadge(size: 70)
                .padding(.trailing, 6)
        case .hidden:
            EmptyView()
        }
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, decoration: HeaderDecoration = .paws) {
        self.init(title: title, subtitle: subtitle, decoration: decoration) { EmptyView() }
    }
}

// MARK: - Botón circular morado

struct CircleIconButton: View {
    let systemImage: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(Circle().fill(Theme.primaryGradient))
                .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 2))
                .softShadow(Theme.primary, opacity: 0.35, radius: 10, y: 5)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(Text(label))
    }
}

// MARK: - Encabezado de sección

struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: () -> Void = {}

    var body: some View {
        HStack {
            Text(title)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            if let actionTitle {
                Button(action: action) {
                    HStack(spacing: 3) {
                        Text(actionTitle)
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primary)
            }
        }
    }
}

// MARK: - Buscador

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.primary.opacity(0.7))
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Theme.textSecondary))
                .foregroundStyle(Theme.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textSecondary)
                }
                .accessibilityLabel("Borrar búsqueda")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .cardBackground(cornerRadius: 16)
    }
}

// MARK: - Ícono con fondo suave

struct IconTile: View {
    let systemImage: String
    let tint: Color
    var size: CGFloat = 44
    var cornerRadius: CGFloat = 12

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.4))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(colors: [tint.opacity(0.20), tint.opacity(0.09)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
    }
}

/// Mosaico con degradado sólido e ícono blanco (para destacar).
struct GradientIconTile: View {
    let systemImage: String
    let tint: Color
    var size: CGFloat = 52
    var cornerRadius: CGFloat = 16

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(colors: [tint.opacity(0.75), tint],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: size * 0.32))
                    .foregroundStyle(.white.opacity(0.18))
                    .rotationEffect(.degrees(-20))
                    .offset(x: -3, y: -3)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .softShadow(tint, opacity: 0.25, radius: 8, y: 4)
    }
}

// MARK: - Etiqueta de estado

struct StatusChip: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(tint.opacity(0.13)))
    }
}

// MARK: - Estado vacío

struct EmptyStateCard: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: () -> Void = {}

    var body: some View {
        VStack(spacing: 10) {
            GradientIconTile(systemImage: systemImage, tint: Theme.primary, size: 58, cornerRadius: 18)
                .padding(.bottom, 4)
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            if let actionTitle {
                Button(actionTitle, action: action)
                    .buttonStyle(.primaryFilled)
                    .padding(.top, 6)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(alignment: .topTrailing) {
            PawCluster(scale: 0.7)
                .offset(x: -6, y: 6)
        }
        .cardBackground(cornerRadius: 24)
    }
}

// MARK: - Avatares de mascotas

struct PetAvatar: View {
    let pet: PetRecord
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            PetPhotoView(pet: pet)
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .padding(4)
                .background(Circle().fill(Theme.surface))
                .overlay(AvatarRing(isSelected: isSelected))
                .softShadow(Theme.primary, opacity: isSelected ? 0.25 : 0.06, radius: 8, y: 4)
            Text(pet.name)
                .font(.footnote.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Theme.primary : Theme.textPrimary)
                .lineLimit(1)
        }
        .frame(minWidth: 64)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Carrusel para filtrar por mascota. `selectedPetID == nil` significa "Todas".
struct PetFilterBar: View {
    let pets: [PetRecord]
    let selectedPetID: UUID?
    var showsAllOption = true
    let onSelect: (UUID?) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                if showsAllOption {
                    Button {
                        withAnimation(.snappy) { onSelect(nil) }
                    } label: {
                        allAvatar
                    }
                    .buttonStyle(.plain)
                }
                ForEach(pets) { pet in
                    Button {
                        withAnimation(.snappy) { onSelect(pet.id) }
                    } label: {
                        PetAvatar(pet: pet, isSelected: pet.id == selectedPetID)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, -20) // de orilla a orilla
    }

    private var allAvatar: some View {
        let isSelected = selectedPetID == nil
        return VStack(spacing: 8) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(isSelected ? AnyShapeStyle(Color.white) : AnyShapeStyle(Theme.primary))
                .frame(width: 56, height: 56)
                .background(
                    Circle().fill(isSelected ? AnyShapeStyle(Theme.primaryGradient) : AnyShapeStyle(Theme.primarySoft))
                )
                .padding(4)
                .background(Circle().fill(Theme.surface))
                .overlay(AvatarRing(isSelected: isSelected))
                .softShadow(Theme.primary, opacity: isSelected ? 0.25 : 0.06, radius: 8, y: 4)
            Text("Todas")
                .font(.footnote.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Theme.primary : Theme.textPrimary)
        }
        .frame(minWidth: 64)
    }
}

/// Anillo del avatar: degradado morado si está seleccionado, borde fino si no.
private struct AvatarRing: View {
    let isSelected: Bool

    var body: some View {
        Circle()
            .strokeBorder(
                isSelected ? AnyShapeStyle(Theme.primaryGradient) : AnyShapeStyle(Theme.stroke),
                lineWidth: isSelected ? 2.5 : 1.5
            )
    }
}

// MARK: - Campo de texto con ícono (login)

struct AppTextField: View {
    let title: String
    @Binding var text: String
    let systemImage: String
    var isSecure = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(Theme.primary.opacity(0.75))
                .frame(width: 20)
            Group {
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.field)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Theme.stroke, lineWidth: 1)
        )
    }
}

// MARK: - Fila de detalle (ícono + etiqueta + valor)

struct DetailRow: View {
    let systemImage: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primary)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Theme.primarySoft))
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                Text(value)
                    .font(.body)
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer(minLength: 0)
        }
    }
}
