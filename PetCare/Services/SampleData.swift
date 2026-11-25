import UIKit
import SwiftData

/// Datos de demostración para el pitch del hackathon.
/// Se cargan con el botón "Usar datos de demostración" del alta de mascotas.
@MainActor
enum SampleData {
    static func populate(_ store: PetCareStore) {
        let luna = store.addPet(PetDraft(
            name: "Luna", species: .dog, breed: "Golden Retriever", sex: .female,
            birthDate: date(2022, 3, 12), weightKg: 28.4, microchip: "985 112 004",
            photoData: photo("luna"), cardStyle: .orange
        ))
        let maxPet = store.addPet(PetDraft(
            name: "Max", species: .dog, breed: "Bulldog francés", sex: .male,
            birthDate: date(2021, 6, 4), weightKg: 12.1, microchip: "985 112 017",
            photoData: photo("max"), cardStyle: .blue
        ))
        let michi = store.addPet(PetDraft(
            name: "Michi", species: .cat, breed: "Doméstico de pelo corto", sex: .male,
            birthDate: date(2023, 1, 20), weightKg: 4.6, microchip: "985 112 031",
            photoData: photo("michi"), cardStyle: .purple
        ))

        // Agenda
        store.addEvent(EventDraft(petID: luna.id, title: "Consulta general", kind: .consultation,
                                  date: day(1, 10, 30), location: "VetCare Polanco", notes: "Llevar la cartilla."))
        store.addEvent(EventDraft(petID: luna.id, title: "Baño y corte", kind: .grooming,
                                  date: day(9, 12), location: "Pet Spa Condesa", notes: ""))
        store.addEvent(EventDraft(petID: maxPet.id, title: "Desparasitación", kind: .medication,
                                  date: day(0, 20), location: "Casa", notes: "Dosis trimestral."))
        store.addEvent(EventDraft(petID: maxPet.id, title: "Paseo en grupo", kind: .walk,
                                  date: day(2, 8), location: "Parque México", notes: ""))
        store.addEvent(EventDraft(petID: michi.id, title: "Vacuna triple felina", kind: .vaccine,
                                  date: day(5, 17), location: "Clínica Patitas Narvarte", notes: "Refuerzo pendiente."))

        // Vacunas
        store.addVaccine(VaccineDraft(name: "Antirrábica", appliedOn: day(-362), hasNextDose: true, nextDose: day(3),
                                      veterinarian: "Dra. Mariana Ruiz", batch: "RB-2291"), to: luna)
        store.addVaccine(VaccineDraft(name: "Múltiple (DHPPi+L)", appliedOn: day(-120), hasNextDose: true, nextDose: day(245),
                                      veterinarian: "Dra. Mariana Ruiz", batch: "MX-7734"), to: luna)
        store.addVaccine(VaccineDraft(name: "Antirrábica", appliedOn: day(-200), hasNextDose: true, nextDose: day(165),
                                      veterinarian: "Dr. Jorge Medina", batch: "RB-1180"), to: maxPet)
        store.addVaccine(VaccineDraft(name: "Triple felina", appliedOn: day(-375), hasNextDose: true, nextDose: day(-10),
                                      veterinarian: "Dra. Ana Torres", batch: "TF-5521"), to: michi)

        // Medicamentos
        store.addMedication(MedicationDraft(name: "Omega 3", dosage: "1 cápsula", frequency: "Diario con la comida",
                                            startDate: day(-30), hasEndDate: false, endDate: .now,
                                            notes: "Para pelaje y articulaciones."), to: luna)
        store.addMedication(MedicationDraft(name: "Gotas óticas", dosage: "4 gotas", frequency: "Cada 12 horas",
                                            startDate: day(-160), hasEndDate: true, endDate: day(-150), notes: ""), to: luna)
        store.addMedication(MedicationDraft(name: "Desparasitante interno", dosage: "1 tableta", frequency: "Cada 3 meses",
                                            startDate: day(-90), hasEndDate: false, endDate: .now, notes: ""), to: maxPet)

        // Consultas
        store.addConsultation(ConsultationDraft(date: day(-60), reason: "Revisión anual", clinic: "VetCare Polanco",
                                                veterinarian: "Dra. Mariana Ruiz",
                                                diagnosis: "Saludable. Peso adecuado; mantener ejercicio diario."), to: luna)
        store.addConsultation(ConsultationDraft(date: day(-160), reason: "Otitis leve", clinic: "VetCare Polanco",
                                                veterinarian: "Dra. Mariana Ruiz",
                                                diagnosis: "Inflamación en oído derecho. Tratamiento con gotas por 10 días."), to: luna)
        store.addConsultation(ConsultationDraft(date: day(-35), reason: "Tos y estornudos", clinic: "Hospital Veterinario Roma",
                                                veterinarian: "Dr. Jorge Medina",
                                                diagnosis: "Irritación respiratoria leve. Reposo y vigilancia."), to: maxPet)
        store.addConsultation(ConsultationDraft(date: day(-375), reason: "Chequeo y vacunación", clinic: "Clínica Patitas Narvarte",
                                                veterinarian: "Dra. Ana Torres",
                                                diagnosis: "Sin hallazgos. Se aplicó triple felina."), to: michi)

        // Gastos
        let expenses: [(PetRecord, Double, ExpenseCategory, Int, String)] = [
            (luna, 850, .veterinary, -2, "Consulta general"),
            (luna, 1_290, .food, -6, "Croquetas 15 kg"),
            (maxPet, 420, .grooming, -9, "Baño"),
            (michi, 380, .food, -12, "Alimento húmedo"),
            (maxPet, 260, .medication, -15, "Desparasitante"),
            (luna, 349, .accessories, -18, "Correa nueva"),
            (luna, 699, .insurance, -22, "Seguro mensual"),
            (michi, 210, .accessories, -27, "Arena"),
            (maxPet, 1_100, .veterinary, -35, "Consulta respiratoria"),
            (luna, 1_290, .food, -38, "Croquetas 15 kg"),
            (maxPet, 600, .services, -44, "Paseos (4 sesiones)"),
            (luna, 699, .insurance, -52, "Seguro mensual")
        ]
        for (pet, amount, category, offset, note) in expenses {
            store.addExpense(ExpenseDraft(petID: pet.id, amountText: String(amount), category: category,
                                          date: day(offset, 12), note: note))
        }
    }

    // MARK: - Helpers

    private static func day(_ offset: Int, _ hour: Int = 10, _ minute: Int = 0) -> Date {
        let calendar = Calendar.current
        let base = calendar.date(byAdding: .day, value: offset, to: .now) ?? .now
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }

    /// Usa las imágenes "luna", "max" y "michi" de Assets si existen.
    private static func photo(_ name: String) -> Data? {
        guard let data = UIImage(named: name)?.jpegData(compressionQuality: 0.9) else { return nil }
        return ImageResizer.jpegData(from: data)
    }
}

/// Store en memoria para los #Preview de Xcode.
@MainActor
enum PreviewData {
    static let container: ModelContainer = {
        do {
            return try ModelContainer(
                for: UserAccount.self, PetRecord.self, PetEvent.self,
                Vaccine.self, Medication.self, Consultation.self, Expense.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            fatalError("No se pudo crear el contenedor de preview: \(error)")
        }
    }()

    static let store: PetCareStore = {
        let user = UserAccount(name: "Sofía Ramírez", email: "sofia@demo.mx", passwordHash: "", salt: "")
        container.mainContext.insert(user)
        let store = PetCareStore(context: container.mainContext, user: user)
        SampleData.populate(store)
        return store
    }()
}
