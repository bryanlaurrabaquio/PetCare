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
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(pet.cardStyle.gradient)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(.white.opacity(0.10))
                        .frame(width: 190, height: 190)
                        .offset(x: 70, y: -100)
                }
                .overlay(alignment: .bottomTrailing) {
                    PawWatermark(size: 130, opacity: 0.10)
                        .offset(x: 26, y: 26)
                }
                .overlay(alignment: .bottomLeading) {
                    PawWatermark(size: 34, opacity: 0.08, angle: 24)
                        .offset(x: 150, y: -22)
                }
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
        .foregroundStyle(.white)
    }

    // MARK: - Encabezado

    private var header: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(pet.cardStyle.gradient)
                }
                .softShadow(.black, opacity: 0.12, radius: 4, y: 2)

            Text(pet.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
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
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(.white, lineWidth: 3)
                    )
                    .softShadow(.black, opacity: 0.18, radius: 10, y: 6)

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
                .fill(.white.opacity(0.35))
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
        .padding(7)
        .frame(width: 76, height: 76)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.white))
        .softShadow(.black, opacity: 0.12, radius: 6, y: 3)
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
