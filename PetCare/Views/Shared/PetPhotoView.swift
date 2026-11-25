import SwiftUI
import UIKit

/// Foto de la mascota. Si no tiene, dibuja un ícono de su especie.
struct PetPhotoView: View {
    let photoData: Data?
    let species: Species
    let style: PetCardStyle

    init(pet: PetRecord) {
        photoData = pet.photoData
        species = pet.species
        style = pet.cardStyle
    }

    init(photoData: Data?, species: Species, style: PetCardStyle) {
        self.photoData = photoData
        self.species = species
        self.style = style
    }

    var body: some View {
        if let photoData, let image = UIImage(data: photoData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Color.white
                style.color.opacity(0.15)
                Image(systemName: species.systemImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.45)
                    .foregroundStyle(style.color)
            }
        }
    }
}
