import SwiftUI
import PhotosUI
import Observation

/// Alta y edición de una mascota (incluye la foto).
@MainActor
@Observable
final class PetFormViewModel: Identifiable {
    let id = UUID()
    var draft: PetDraft
    var weightText: String
    var photoItem: PhotosPickerItem?
    private(set) var isLoadingPhoto = false

    private let store: PetCareStore
    private let pet: PetRecord?

    init(store: PetCareStore, pet: PetRecord?) {
        self.store = store
        self.pet = pet
        let draft = pet.map(PetDraft.init(pet:)) ?? PetDraft()
        self.draft = draft
        self.weightText = draft.weightKg > 0 ? String(format: "%.1f", draft.weightKg) : ""
    }

    var isEditing: Bool { pet != nil }
    var title: String { isEditing ? "Editar mascota" : "Nueva mascota" }
    var canSave: Bool { draft.isValid }

    func loadSelectedPhoto() async {
        guard let photoItem else { return }
        isLoadingPhoto = true
        defer { isLoadingPhoto = false }
        if let data = try? await photoItem.loadTransferable(type: Data.self) {
            draft.photoData = ImageResizer.jpegData(from: data)
        }
    }

    func removePhoto() {
        draft.photoData = nil
        photoItem = nil
    }

    /// Regresa `true` si se guardó.
    func save() -> Bool {
        draft.weightKg = Double(weightText.replacingOccurrences(of: ",", with: ".").trimmed) ?? 0
        guard canSave else { return false }
        if let pet {
            store.updatePet(pet, with: draft)
        } else {
            store.addPet(draft)
        }
        return true
    }

    func delete() {
        guard let pet else { return }
        store.deletePet(pet)
    }
}
