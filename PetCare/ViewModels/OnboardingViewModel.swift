import Foundation
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    private let store: PetCareStore

    init(store: PetCareStore) {
        self.store = store
    }

    var pets: [PetRecord] { store.pets }
    var canContinue: Bool { !store.pets.isEmpty }

    var title: String {
        let firstName = store.user.name.split(separator: " ").first.map(String.init) ?? store.user.name
        return "Hola, \(firstName) 👋"
    }

    var addButtonTitle: String {
        pets.isEmpty ? "Agregar mi primera mascota" : "Agregar otra mascota"
    }

    func makeFormViewModel() -> PetFormViewModel {
        PetFormViewModel(store: store, pet: nil)
    }

    func loadDemoData() {
        SampleData.populate(store)
    }
}
