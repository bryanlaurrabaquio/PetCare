import SwiftUI
import UIKit

/// Credencial de la mascota. Colapsada muestra solo el encabezado;
/// expandida muestra foto, datos, QR y estado de vacunas.
struct PetIDCard: View {
    let pet: PetRecord
    let isExpanded: Bool
    let qrImage: UIImage?
    var collapsedHeight: CGFloat = 92

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            if isExpanded {
                details
                    .transition(.opacity)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: isExpanded ? nil : collapsedHeight, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous).fill(pet.cardStyle.color)
        )
        .foregroundStyle(.white)
    }

    // MARK: - Encabezado

    private var header: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.white)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(pet.cardStyle.color)
                }

            Text(pet.name)
                .font(.system(size: 24, weight: .bold))
                .lineLimit(1)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("ESPECIE")
                    .font(.caption2.weight(.semibold))
                    .tracking(0.8)
                    .opacity(0.8)
                Text(pet.species.displayName)
                    .font(.headline)
            }
        }
    }

    // MARK: - Detalle

    private var details: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                PetPhotoView(pet: pet)
                    .frame(width: 124, height: 124)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white, lineWidth: 2)
                    )

                VStack(alignment: .leading, spacing: 10) {
                    InfoField(label: "RAZA", value: pet.breedText)
                    InfoField(label: "EDAD", value: pet.ageText)
                    InfoField(label: "SEXO", value: pet.sex.displayName)
                }
                Spacer(minLength: 0)
            }

            HStack(alignment: .top) {
                InfoField(label: "PESO", value: pet.weightText)
                Spacer()
                InfoField(label: "NACIMIENTO", value: pet.birthDateText)
                Spacer()
                InfoField(label: "MICROCHIP", value: pet.microchipText, alignment: .trailing)
            }

            Rectangle()
                .fill(.white.opacity(0.6))
                .frame(height: 1)

            HStack(spacing: 14) {
                qrCode

                VStack(alignment: .leading, spacing: 8) {
                    vaccineBadge
                    Text("ID PetCare · Escanea si me encuentras para contactar a mi familia")
                        .font(.footnote)
                        .opacity(0.9)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var qrCode: some View {
        Group {
            if let qrImage {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.black)
            }
        }
        .padding(6)
        .frame(width: 72, height: 72)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.white))
        .accessibilityLabel("Código QR de \(pet.name)")
    }

    private var vaccineBadge: some View {
        let status = pet.vaccineStatus
        return HStack(spacing: 4) {
            Image(systemName: status.systemImage)
                .font(.caption2.weight(.bold))
            Text(status.text)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(Theme.textPrimary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(.white))
    }
}

/// Par etiqueta / valor ("RAZA" / "Golden Retriever").
struct InfoField: View {
    let label: String
    let value: String
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .tracking(0.8)
                .opacity(0.75)
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
