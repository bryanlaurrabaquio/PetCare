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
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                Text("¿Qué sigue para tus mascotas?")
                    .font(.system(size: 24, weight: .bold))
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
                    .foregroundStyle(Theme.primary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Theme.primarySoft))
            }
            .accessibilityLabel("Perfil")
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
                        .font(.caption2.weight(.semibold))
                        .tracking(1)
                        .foregroundStyle(Theme.primary)
                    Text(item.headline)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                if let pet {
                    PetPhotoView(pet: pet)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 2))
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
                    .buttonStyle(FilledButtonStyle(background: Theme.primary))
                if let onReschedule {
                    Button("Reagendar", action: onReschedule)
                        .buttonStyle(FilledButtonStyle(background: Theme.darkElevated))
                }
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.dark))
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
                .font(.caption.weight(.medium))
                .foregroundStyle(Theme.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Theme.chip))

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(14)
        .cardBackground(cornerRadius: 18)
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
                        IconTile(systemImage: item.kind.systemImage, tint: item.kind.tint, size: 56, cornerRadius: 16)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.kind.displayName.uppercased())
                                .font(.caption2.weight(.semibold))
                                .tracking(1)
                                .foregroundStyle(item.kind.tint)
                            Text(item.title)
                                .font(.title2.weight(.bold))
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
                    .cardBackground()

                    if let onEdit {
                        Button("Reagendar o editar") {
                            onEdit()
                            dismiss()
                        }
                        .buttonStyle(FilledButtonStyle(background: Theme.primary))
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
            .background(Theme.background)
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
