import SwiftUI

/// Salud: carnet de la mascota con vacunas, medicamentos y consultas recientes.
struct HealthView: View {
    @Bindable var viewModel: HealthViewModel
    @State private var activeForm: HealthForm?

    enum HealthForm: String, Identifiable {
        case vaccine, medication, consultation
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(
                    title: "Salud",
                    subtitle: "Controla el bienestar y la historia clínica de tus mascotas",
                    decoration: .heartPaw
                )

                PetFilterBar(
                    pets: viewModel.pets,
                    selectedPetID: viewModel.selectedPet?.id,
                    showsAllOption: false,
                    onSelect: { viewModel.selectPet($0) }
                )

                if let pet = viewModel.selectedPet {
                    HealthCardHeader(
                        pet: pet,
                        vaccineCount: viewModel.vaccines.count,
                        activeMedications: pet.activeMedicationsCount,
                        consultationCount: viewModel.consultations.count
                    )

                    vaccinesSection
                    medicationsSection
                    consultationsSection
                } else {
                    EmptyStateCard(
                        systemImage: "heart.text.square",
                        title: "Sin mascotas",
                        message: "Agrega una mascota en “Mis mascotas” para ver su carnet."
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(AppBackground())
        .sheet(item: $activeForm) { form in
            let petName = viewModel.selectedPet?.name ?? ""
            switch form {
            case .vaccine:
                VaccineFormView(petName: petName) { viewModel.addVaccine($0) }
            case .medication:
                MedicationFormView(petName: petName) { viewModel.addMedication($0) }
            case .consultation:
                ConsultationFormView(petName: petName) { viewModel.addConsultation($0) }
            }
        }
    }

    // MARK: - Secciones del carnet

    private var vaccinesSection: some View {
        CarnetSection(
            title: "Vacunas", systemImage: "syringe", tint: Theme.green,
            count: viewModel.vaccines.count, onAdd: { activeForm = .vaccine }
        ) {
            if viewModel.vaccines.isEmpty {
                CarnetEmptyRow(text: "Aún no hay vacunas registradas.")
            }
            ForEach(Array(viewModel.vaccines.enumerated()), id: \.element.id) { index, vaccine in
                if index > 0 { Divider().padding(.leading, 16) }
                VaccineRow(vaccine: vaccine, status: viewModel.doseStatus(for: vaccine))
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.delete(vaccine)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
            }
        }
    }

    private var medicationsSection: some View {
        CarnetSection(
            title: "Medicamentos", systemImage: "pills", tint: Theme.pink,
            count: viewModel.medications.count, onAdd: { activeForm = .medication }
        ) {
            if viewModel.medications.isEmpty {
                CarnetEmptyRow(text: "Sin medicamentos registrados.")
            }
            ForEach(Array(viewModel.medications.enumerated()), id: \.element.id) { index, medication in
                if index > 0 { Divider().padding(.leading, 16) }
                MedicationRow(medication: medication, period: viewModel.medicationPeriodText(medication))
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.delete(medication)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
            }
        }
    }

    private var consultationsSection: some View {
        CarnetSection(
            title: "Consultas recientes", systemImage: "stethoscope", tint: Theme.primary,
            count: viewModel.consultations.count, onAdd: { activeForm = .consultation }
        ) {
            if viewModel.consultations.isEmpty {
                CarnetEmptyRow(text: "Sin consultas registradas.")
            }
            ForEach(Array(viewModel.consultations.enumerated()), id: \.element.id) { index, consultation in
                if index > 0 { Divider().padding(.leading, 16) }
                ConsultationRow(consultation: consultation)
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.delete(consultation)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
            }
        }
    }
}

// MARK: - Portada del carnet

struct HealthCardHeader: View {
    let pet: PetRecord
    let vaccineCount: Int
    let activeMedications: Int
    let consultationCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 14) {
                PetPhotoView(pet: pet)
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(.white, lineWidth: 3)
                    )
                    .softShadow(pet.cardStyle.color, opacity: 0.30, radius: 10, y: 5)

                VStack(alignment: .leading, spacing: 3) {
                    Text("CARNET DE SALUD")
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(pet.cardStyle.color)
                    Text(pet.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    Text(pet.summaryText)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                let status = pet.vaccineStatus
                chip(text: status.text, systemImage: "\(status.systemImage).circle.fill", tint: status.tint)
                chip(text: pet.weightText, systemImage: "scalemass.fill", tint: Theme.primary)
            }

            HStack(spacing: 10) {
                stat(value: vaccineCount, label: "Vacunas", systemImage: "syringe", tint: Theme.green)
                stat(value: activeMedications, label: "Med. activos", systemImage: "pills", tint: Theme.orange)
                stat(value: consultationCount, label: "Consultas", systemImage: "stethoscope", tint: Theme.primary)
            }
        }
        .padding(18)
        .background {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Theme.surface)
                    .shadow(color: Theme.shadow.opacity(0.08), radius: 16, x: 0, y: 8)
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(pet.cardStyle.gradient)
                    .opacity(0.10)
                    .mask {
                        LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .center)
                    }
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(pet.cardStyle.color.opacity(0.10))
                    .rotationEffect(.degrees(-18))
                    .offset(x: -16, y: 14)
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(Theme.stroke, lineWidth: 1)
            }
        }
    }

    private func chip(text: String, systemImage: String, tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
            Text(text)
                .lineLimit(1)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(tint.opacity(0.12)))
    }

    private func stat(value: Int, label: String, systemImage: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: systemImage)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(tint)
            Text("\(value)")
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(Theme.textPrimary)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.field)
        )
    }
}

// MARK: - Sección del carnet

struct CarnetSection<Content: View>: View {
    let title: String
    let systemImage: String
    let tint: Color
    let count: Int
    let onAdd: () -> Void
    let content: Content

    init(title: String, systemImage: String, tint: Color, count: Int,
         onAdd: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
        self.count = count
        self.onAdd = onAdd
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                IconTile(systemImage: systemImage, tint: tint, size: 38, cornerRadius: 12)
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                Text("\(count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Theme.primarySoft))
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Theme.primaryGradient))
                        .softShadow(Theme.primary, opacity: 0.3, radius: 6, y: 3)
                }
                .accessibilityLabel(Text("Agregar en \(title)"))
            }
            .padding(16)

            Divider()
                .overlay(Theme.stroke)

            content
        }
        .cardBackground(cornerRadius: 22)
    }
}

struct CarnetEmptyRow: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(Theme.textSecondary)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Filas

struct VaccineRow: View {
    let vaccine: Vaccine
    let status: DoseStatus

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vaccine.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text("Aplicada el \(AppFormatters.shortDate(vaccine.appliedOn))")
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
                if !details.isEmpty {
                    Text(details)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            Spacer(minLength: 8)
            StatusChip(text: status.text, tint: status.tint)
        }
        .padding(16)
        .contentShape(Rectangle())
    }

    private var details: String {
        [
            vaccine.veterinarian.isEmpty ? nil : vaccine.veterinarian,
            vaccine.batch.isEmpty ? nil : "Lote \(vaccine.batch)"
        ]
        .compactMap { $0 }
        .joined(separator: " · ")
    }
}

struct MedicationRow: View {
    let medication: Medication
    let period: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                if !dose.isEmpty {
                    Text(dose)
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
                Text(period)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                if !medication.notes.isEmpty {
                    Text(medication.notes)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .italic()
                }
            }
            Spacer(minLength: 8)
            StatusChip(
                text: medication.isActive ? "Activo" : "Terminado",
                tint: medication.isActive ? Theme.green : Theme.gray
            )
        }
        .padding(16)
        .contentShape(Rectangle())
    }

    private var dose: String {
        [medication.dosage, medication.frequency]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}

struct ConsultationRow: View {
    let consultation: Consultation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(consultation.reason)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer(minLength: 8)
                Text(AppFormatters.shortDate(consultation.date))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            if !place.isEmpty {
                Text(place)
                    .font(.footnote)
                    .foregroundStyle(Theme.textSecondary)
            }
            if !consultation.diagnosis.isEmpty {
                Text(consultation.diagnosis)
                    .font(.footnote)
                    .foregroundStyle(Theme.textPrimary.opacity(0.8))
                    .lineLimit(3)
                    .padding(.top, 2)
            }
        }
        .padding(16)
        .contentShape(Rectangle())
    }

    private var place: String {
        [consultation.clinic, consultation.veterinarian]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}

#Preview {
    HealthView(viewModel: HealthViewModel(store: PreviewData.store))
}
