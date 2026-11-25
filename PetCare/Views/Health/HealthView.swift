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
                ScreenHeader(title: "Salud", subtitle: "Carnet de salud")

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
        .background(Theme.background)
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
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("CARNET DE SALUD")
                        .font(.caption2.weight(.bold))
                        .tracking(1.2)
                        .opacity(0.85)
                    Text(pet.name)
                        .font(.system(size: 28, weight: .bold))
                    Text("\(pet.summaryText) · \(pet.weightText)")
                        .font(.subheadline)
                        .opacity(0.9)
                }
                Spacer()
                PetPhotoView(pet: pet)
                    .frame(width: 68, height: 68)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(.white, lineWidth: 2))
            }

            let status = pet.vaccineStatus
            HStack(spacing: 4) {
                Image(systemName: status.systemImage)
                    .font(.caption2.weight(.bold))
                Text(status.text)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(status.tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(.white))

            Rectangle()
                .fill(.white.opacity(0.5))
                .frame(height: 1)

            HStack {
                stat(value: vaccineCount, label: "VACUNAS")
                Spacer()
                stat(value: activeMedications, label: "MED. ACTIVOS")
                Spacer()
                stat(value: consultationCount, label: "CONSULTAS")
            }
        }
        .padding(18)
        .foregroundStyle(.white)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(pet.cardStyle.color))
    }

    private func stat(value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.title3.weight(.bold))
            Text(label)
                .font(.caption2.weight(.semibold))
                .tracking(0.8)
                .opacity(0.8)
        }
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
                IconTile(systemImage: systemImage, tint: tint, size: 36, cornerRadius: 10)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text("\(count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Theme.chip))
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(tint)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(tint.opacity(0.14)))
                }
                .accessibilityLabel(Text("Agregar en \(title)"))
            }
            .padding(16)

            Divider()

            content
        }
        .cardBackground()
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
