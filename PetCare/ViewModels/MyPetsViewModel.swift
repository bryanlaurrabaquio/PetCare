import UIKit
import Observation

@MainActor
@Observable
final class MyPetsViewModel {
    private(set) var selectedPetID: UUID?

    private let store: PetCareStore
    @ObservationIgnored private var qrCache: [UUID: UIImage] = [:]

    init(store: PetCareStore) {
        self.store = store
    }

    // MARK: - Datos de la vista

    var pets: [PetRecord] { store.pets }

    var subtitle: String {
        switch pets.count {
        case 0: "Aún no tienes mascotas"
        case 1: "1 mascota registrada"
        default: "\(pets.count) mascotas registradas"
        }
    }

    /// Si no hay selección (o se borró), se usa la primera.
    var selectedPet: PetRecord? { store.pet(withID: selectedPetID) ?? store.pets.first }

    /// Orden tipo Wallet: las no seleccionadas arriba (colapsadas) y la seleccionada al final.
    var stackedPets: [PetRecord] {
        guard let selectedID = selectedPet?.id else { return pets }
        return pets.filter { $0.id != selectedID } + pets.filter { $0.id == selectedID }
    }

    func isSelected(_ pet: PetRecord) -> Bool {
        pet.id == selectedPet?.id
    }

    func qrPayload(for pet: PetRecord) -> String {
        "https://petcare.app/id/\(pet.id.uuidString)"
    }

    func qrCode(for pet: PetRecord) -> UIImage? {
        if let cached = qrCache[pet.id] { return cached }
        let image = QRCodeGenerator.make(from: qrPayload(for: pet))
        qrCache[pet.id] = image
        return image
    }

    func shareText(for pet: PetRecord) -> String {
        "Conoce a \(pet.name) 🐾 \(pet.summaryText). ID Psh Psh: \(qrPayload(for: pet))"
    }

    // MARK: - Acciones

    func select(_ pet: PetRecord) {
        selectedPetID = pet.id
    }

    func makeFormViewModel(for pet: PetRecord?) -> PetFormViewModel {
        PetFormViewModel(store: store, pet: pet)
    }
}
