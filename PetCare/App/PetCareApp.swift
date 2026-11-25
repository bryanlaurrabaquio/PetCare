import SwiftUI
import SwiftData

@main
struct PetCareApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: UserAccount.self, PetRecord.self, PetEvent.self,
                Vaccine.self, Medication.self, Consultation.self, Expense.self,
                InsurancePolicy.self
            )
        } catch {
            // Si cambias los modelos y la app truena aquí, borra la app del simulador.
            fatalError("No se pudo abrir la base de datos: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .preferredColorScheme(.light) // el diseño es claro (fondo lavanda)
        }
        .modelContainer(container)
    }
}
