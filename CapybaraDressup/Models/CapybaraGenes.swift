import Foundation

struct CapybaraGenes: Codable, Equatable {

    // MARK: - 외형 유전자 (0.0 ~ 1.0)

    var bodyWidth: Float
    var bodyHeight: Float
    var headSize: Float
    var noseSize: Float
    var noseHeight: Float
    var earSize: Float
    var earPointiness: Float
    var eyeSize: Float
    var eyeSpacing: Float
    var furHue: Float
    var furSaturation: Float
    var furBrightness: Float
    var cheekSize: Float
    var tailLength: Float
    var legThickness: Float

    // MARK: - 성격 유전자 (0.0 ~ 1.0)

    var patience: Float
    var energy: Float

    // MARK: - 랜덤 생성

    static func random() -> CapybaraGenes {
        CapybaraGenes(
            bodyWidth: .random(in: 0...1),
            bodyHeight: .random(in: 0...1),
            headSize: .random(in: 0...1),
            noseSize: .random(in: 0...1),
            noseHeight: .random(in: 0...1),
            earSize: .random(in: 0...1),
            earPointiness: .random(in: 0...1),
            eyeSize: .random(in: 0...1),
            eyeSpacing: .random(in: 0...1),
            furHue: .random(in: 0...1),
            furSaturation: .random(in: 0...1),
            furBrightness: .random(in: 0...1),
            cheekSize: .random(in: 0...1),
            tailLength: .random(in: 0...1),
            legThickness: .random(in: 0...1),
            patience: .random(in: 0...1),
            energy: .random(in: 0...1)
        )
    }

    // MARK: - 교배

    static func breed(parentA: CapybaraGenes, parentB: CapybaraGenes) -> CapybaraGenes {
        func inherit(_ a: Float, _ b: Float) -> Float {
            var value = Bool.random() ? a : b
            // 5% 확률로 돌연변이
            if Float.random(in: 0...1) < 0.05 {
                value += Float.random(in: -0.1...0.1)
            }
            return min(max(value, 0), 1)
        }

        return CapybaraGenes(
            bodyWidth: inherit(parentA.bodyWidth, parentB.bodyWidth),
            bodyHeight: inherit(parentA.bodyHeight, parentB.bodyHeight),
            headSize: inherit(parentA.headSize, parentB.headSize),
            noseSize: inherit(parentA.noseSize, parentB.noseSize),
            noseHeight: inherit(parentA.noseHeight, parentB.noseHeight),
            earSize: inherit(parentA.earSize, parentB.earSize),
            earPointiness: inherit(parentA.earPointiness, parentB.earPointiness),
            eyeSize: inherit(parentA.eyeSize, parentB.eyeSize),
            eyeSpacing: inherit(parentA.eyeSpacing, parentB.eyeSpacing),
            furHue: inherit(parentA.furHue, parentB.furHue),
            furSaturation: inherit(parentA.furSaturation, parentB.furSaturation),
            furBrightness: inherit(parentA.furBrightness, parentB.furBrightness),
            cheekSize: inherit(parentA.cheekSize, parentB.cheekSize),
            tailLength: inherit(parentA.tailLength, parentB.tailLength),
            legThickness: inherit(parentA.legThickness, parentB.legThickness),
            patience: inherit(parentA.patience, parentB.patience),
            energy: inherit(parentA.energy, parentB.energy)
        )
    }
}
