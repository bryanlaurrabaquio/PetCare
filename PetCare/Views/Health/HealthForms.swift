import SwiftUI

// Formularios del carnet. Cada uno trabaja con su draft y lo regresa en `onSave`.

struct VaccineFormView: View {
    @Environment(\.dismiss) private var dismiss
    let petName: String
    let onSave: (VaccineDraft) -> Void
    @State private var draft: VaccineDraft

    init(petName: String, onSave: @escaping (VaccineDraft) -> Void) {
        self.petName = petName
        self.onSave = onSave
        _draft = State(initialValue: VaccineDraft())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Vacuna (ej. Antirrábica)", text: $draft.name)
                        .textInputAutocapitalization(.sentences)
                    DatePicker("Aplicada el", selection: $draft.appliedOn, in: ...Date.now, displayedComponents: .date)
                } header: {
                    Text("Vacuna de \(petName)")
                }

                Section("Refuerzo") {
                    Toggle("Tiene siguiente dosis", isOn: $draft.hasNextDose)
                    if draft.hasNextDose {
                        DatePicker("Próxima dosis", selection: $draft.nextDose, displayedComponents: .date)
                    }
                }

                Section("Detalles (opcional)") {
                    TextField("Veterinario", text: $draft.veterinarian)
                    TextField("Lote", text: $draft.batch)
                }
            }
            .environment(\.locale, AppFormatters.locale)
            .appFormStyle()
            .navigationTitle("Nueva vacuna")
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

struct MedicationFormView: View {
    @Environment(\.dismiss) private var dismiss
    let petName: String
    let onSave: (MedicationDraft) -> Void
    @State private var draft: MedicationDraft

    init(petName: String, onSave: @escaping (MedicationDraft) -> Void) {
        self.petName = petName
        self.onSave = onSave
        _draft = State(initialValue: MedicationDraft())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Medicamento", text: $draft.name)
                    TextField("Dosis (ej. 1 tableta)", text: $draft.dosage)
                    TextField("Frecuencia (ej. Cada 12 horas)", text: $draft.frequency)
                } header: {
                    Text("Medicamento de \(petName)")
                }

                Section("Periodo") {
                    DatePicker("Inicio", selection: $draft.startDate, displayedComponents: .date)
                    Toggle("Tiene fecha de fin", isOn: $draft.hasEndDate)
                    if draft.hasEndDate {
                        DatePicker("Fin", selection: $draft.endDate, in: draft.startDate..., displayedComponents: .date)
                    }
                }

                Section("Notas (opcional)") {
                    TextField("Indicaciones del veterinario", text: $draft.notes, axis: .vertical)
                        .lineLimit(2...5)
                }
            }
            .environment(\.locale, AppFormatters.locale)
            .appFormStyle()
            .navigationTitle("Nuevo medicamento")
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

struct ConsultationFormView: View {
    @Environment(\.dismiss) private var dismiss
    let petName: String
    let onSave: (ConsultationDraft) -> Void
    @State private var draft: ConsultationDraft

    init(petName: String, onSave: @escaping (ConsultationDraft) -> Void) {
        self.petName = petName
        self.onSave = onSave
        _draft = State(initialValue: ConsultationDraft())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Motivo (ej. Revisión anual)", text: $draft.reason)
                    DatePicker("Fecha", selection: $draft.date, in: ...Date.now, displayedComponents: .date)
                } header: {
                    Text("Consulta de \(petName)")
                }

                Section("Dónde (opcional)") {
                    TextField("Clínica", text: $draft.clinic)
                    TextField("Veterinario", text: $draft.veterinarian)
                }

                Section("Diagnóstico (opcional)") {
                    TextField("Diagnóstico o indicaciones", text: $draft.diagnosis, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .environment(\.locale, AppFormatters.locale)
            .appFormStyle()
            .navigationTitle("Nueva consulta")
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
