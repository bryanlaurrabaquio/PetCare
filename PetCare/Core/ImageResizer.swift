import UIKit

/// Reduce las fotos antes de guardarlas para que la base de datos no crezca de más.
enum ImageResizer {
    static func jpegData(from data: Data, maxDimension: CGFloat = 900, quality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: data) else { return nil }

        let size = image.size
        let scale = min(1, maxDimension / max(size.width, size.height))
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
