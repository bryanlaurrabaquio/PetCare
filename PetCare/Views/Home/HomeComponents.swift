import SwiftUI

// MARK: - Encabezado con menú de perfil

struct HomeHeader: View {
    let greeting: String
    let userName: String
    let email: String
    let onSignOut: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.textSecondary)
                Text("¿Qué sigue para tus mascotas?")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 16)

            Menu {
                Section(email) {
                    Button(role: .destructive, action: onSignOut) {
                        Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            } label: {
                Text(initials)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Theme.primaryGradient))
                    .overlay(Circle().stroke(.white, lineWidth: 3))
                    .softShadow(Theme.primary, opacity: 0.3, radius: 10, y: 5)
            }
            .accessibilityLabel("Perfil")
        }
        .background(alignment: .topTrailing) {
            PawCluster(scale: 0.9)
                .padding(.trailing, 50)
                .offset(y: -14)
        }
    }

    private var initials: String {
        let letters = userName
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
        return letters.isEmpty ? "?" : letters.uppercased()
    }
}

// MARK: - Tarjeta del siguiente evento

struct NextEventCard: View {
    let item: UpcomingItem
    let pet: PetRecord?
    let onDetail: () -> Void
    let onReschedule: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("PRÓXIMO EVENTO · \(AppFormatters.relativeDay(item.date).uppercased())")
                        .font(.caption2.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(Color(hex: 0xFFD36B))
                    Text(item.headline)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                if let pet {
                    PetPhotoView(pet: pet)
                        .frame(width: 54, height: 54)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 3))
                        .softShadow(.black, opacity: 0.25, radius: 8, y: 4)
                }
            }

            HStack(spacing: 18) {
                Label(
                    item.showsTime ? AppFormatters.appointmentDate(item.date) : AppFormatters.shortDate(item.date),
                    systemImage: "calendar"
                )
                if !item.location.isEmpty {
                    Label(item.location, systemImage: "mappin.and.ellipse")
                }
            }
            .font(.subheadline)
            .lineLimit(1)
            .foregroundStyle(.white.opacity(0.85))

            HStack(spacing: 10) {
                Button("Ver detalle", action: onDetail)
                    .buttonStyle(
                        FilledButtonStyle(
                            gradient: LinearGradient(colors: [Color(hex: 0xA97FFF), Color(hex: 0x8350F2)],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing),
                            glow: Color(hex: 0x1E0A4A),
                            height: 46
                        )
                    )
                if let onReschedule {
                    Button("Reagendar", action: onReschedule)
                        .buttonStyle(FilledButtonStyle(background: Color.white.opacity(0.16), height: 46))
                }
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Theme.heroGradient)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(.white.opacity(0.07))
                        .frame(width: 170, height: 170)
                        .offset(x: 60, y: -80)
                }
                .overlay(alignment: .bottomTrailing) {
                    PawWatermark(size: 96, opacity: 0.09)
                        .offset(x: 10, y: 18)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .softShadow(Theme.dark, opacity: 0.35, radius: 18, y: 10)
    }
}

// MARK: - Fila de evento

struct UpcomingEventRow: View {
    let item: UpcomingItem
    let showsPetName: Bool

    var body: some View {
        HStack(spacing: 14) {
            IconTile(systemImage: item.kind.systemImage, tint: item.kind.tint)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                Text(item.subtitle(showingPet: showsPetName))
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(AppFormatters.relativeDay(item.date))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Theme.primarySoft))

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.textSecondary.opacity(0.7))
        }
        .padding(14)
        .cardBackground(cornerRadius: 20)
    }
}

// MARK: - Detalle del evento

struct EventDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let item: UpcomingItem
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 14) {
                        GradientIconTile(systemImage: item.kind.systemImage, tint: item.kind.tint, size: 58, cornerRadius: 18)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.kind.displayName.uppercased())
                                .font(.caption2.weight(.semibold))
                                .tracking(1)
                                .foregroundStyle(item.kind.tint)
                            Text(item.title)
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(systemImage: "pawprint", label: "Mascota", value: item.petName)
                        DetailRow(
                            systemImage: "calendar",
                            label: "Fecha",
                            value: item.showsTime ? AppFormatters.appointmentDate(item.date) : AppFormatters.shortDate(item.date)
                        )
                        if !item.location.isEmpty {
                            DetailRow(systemImage: "mappin.and.ellipse", label: "Lugar", value: item.location)
                        }
                        if !item.notes.isEmpty {
                            DetailRow(systemImage: "note.text", label: "Notas", value: item.notes)
                        }
                    }
                    .padding(16)
                    .cardBackground(cornerRadius: 22)

                    if let onEdit {
                        Button("Reagendar o editar") {
                            onEdit()
                            dismiss()
                        }
                        .buttonStyle(.primaryFilled)
                    }

                    if let onDelete {
                        Button("Eliminar evento", role: .destructive) {
                            dismiss()
                            onDelete()
                        }
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(20)
            }
            .background(AppBackground())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                }
            }
        }
        .tint(Theme.primary)
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Formulario de evento

struct EventFormView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let pets: [PetRecord]
    let onSave: (EventDraft) -> Void
    @State private var draft: EventDraft

    init(title: String, pets: [PetRecord], draft: EventDraft, onSave: @escaping (EventDraft) -> Void) {
        self.title = title
        self.pets = pets
        self.onSave = onSave
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Mascota") {
                    Picker("Mascota", selection: $draft.petID) {
                        ForEach(pets) { pet in
                            Text(pet.name).tag(Optional(pet.id))
                        }
                    }
                }

                Section("Evento") {
                    Picker("Tipo", selection: $draft.kind) {
                        ForEach(EventKind.allCases) { kind in
                            Label(kind.displayName, systemImage: kind.systemImage).tag(kind)
                        }
                    }
                    TextField("Título (ej. Consulta general)", text: $draft.title)
                    DatePicker("Fecha y hora", selection: $draft.date)
                        .environment(\.locale, AppFormatters.locale)
                }

                Section("Detalles") {
                    TextField("Lugar (opcional)", text: $draft.location)
                    TextField("Notas (opcional)", text: $draft.notes, axis: .vertical)
                        .lineLimit(2...5)
                }
            }
            .appFormStyle()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(draft)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!draft.isValid)
                }
            }
        }
        .tint(Theme.primary)
    }
}
