import SwiftUI
import UIKit

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func toggle(on: Bool) {
        UIImpactFeedbackGenerator(style: on ? .medium : .light).impactOccurred()
    }

    static func select() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

struct HapticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed { Haptics.tap() }
            }
    }
}
