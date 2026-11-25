import SwiftUI

// Componentes reutilizables. Reciben datos simples (no ViewModels)
// para que sean fáciles de previsualizar.

// MARK: - Encabezado de pantalla

struct ScreenHeader<Trailing: View>: View {
    let title: String
    let subtitle: String?
    let trailing: Trailing

    init(title: String, subtitle: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            Spacer(minLength: 12)
            trailing
        }
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil) {
        self.init(title: title, subtitle: subtitle) { EmptyView() }
    }
}

// MARK: - Botón circular naranja

struct CircleIconButton: View {
    let systemImage: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Theme.primary))
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
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            if let actionTitle {
                Button(actionTitle, action: action)
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
                .foregroundStyle(Theme.textSecondary)
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
        .cardBackground(cornerRadius: 14)
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
                    .fill(tint.opacity(0.14))
            )
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
            .background(Capsule().fill(tint.opacity(0.14)))
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
            IconTile(systemImage: systemImage, tint: Theme.primary, size: 52, cornerRadius: 16)
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
                    .buttonStyle(FilledButtonStyle(background: Theme.primary))
                    .padding(.top, 6)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .cardBackground()
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
                .overlay(Circle().strokeBorder(isSelected ? Theme.primary : Theme.chip, lineWidth: 2))
            Text(pet.name)
                .font(.footnote.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(Theme.textPrimary)
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
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 20))
                .foregroundStyle(isSelected ? Theme.primary : Theme.textSecondary)
                .frame(width: 56, height: 56)
                .background(Circle().fill(isSelected ? Theme.primarySoft : Theme.chip))
                .padding(4)
                .background(Circle().fill(Theme.surface))
                .overlay(Circle().strokeBorder(isSelected ? Theme.primary : Theme.chip, lineWidth: 2))
            Text("Todas")
                .font(.footnote.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(minWidth: 64)
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
                .foregroundStyle(Theme.textSecondary)
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
        .cardBackground(cornerRadius: 14)
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
                .foregroundStyle(Theme.primary)
                .frame(width: 22)
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
