import UIKit

final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    enum HapticStyle {
        case soft
        case light
        case medium
        case rigid
    }

    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)

    func prepare(_ style: HapticStyle) {
        generator(for: style).prepare()
    }

    func play(_ style: HapticStyle) {
        generator(for: style).impactOccurred()
    }

    private func generator(for style: HapticStyle) -> UIImpactFeedbackGenerator {
        switch style {
        case .soft: return softGenerator
        case .light: return lightGenerator
        case .medium: return mediumGenerator
        case .rigid: return rigidGenerator
        }
    }
}
