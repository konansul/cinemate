import Foundation
import SwiftUI

enum WidgetImage {
    static func poster(_ path: String?) async -> Image? {
        await load(path, size: "w500")
    }

    static func backdrop(_ path: String?) async -> Image? {
        await load(path, size: "w780")
    }

    private static func load(_ path: String?, size: String) async -> Image? {
        guard let path else { return nil }
        guard let url = URL(string: "https://image.tmdb.org/t/p/\(size)\(path)") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else { return nil }
            return Image(uiImage: uiImage)
        } catch {
            return nil
        }
    }
}
