import SwiftUI

/// 유전자 값(0~1)을 실제 렌더링에 사용할 CGFloat 파라미터로 변환
struct CapybaraAppearance {

    // MARK: - 외형

    let bodyWidthScale: CGFloat      // 0.8 ~ 1.2
    let bodyHeightScale: CGFloat     // 0.85 ~ 1.15
    let headSizeScale: CGFloat       // 0.85 ~ 1.15
    let noseSizeScale: CGFloat       // 0.7 ~ 1.3
    let noseHeightOffset: CGFloat    // 0.8 ~ 1.2
    let earSizeScale: CGFloat        // 0.7 ~ 1.3
    let earPointiness: CGFloat       // 0.0 ~ 1.0 (그대로)
    let eyeSizeScale: CGFloat        // 0.8 ~ 1.2
    let eyeSpacingScale: CGFloat     // 0.8 ~ 1.2
    let cheekSize: CGFloat           // 0.0 ~ 1.0 (그대로)
    let tailLengthScale: CGFloat     // 0.7 ~ 1.3
    let legThicknessScale: CGFloat   // 0.8 ~ 1.2

    // MARK: - 털 색상

    let furColor: Color
    let furColorLight: Color         // 배 부분 밝은 색

    // MARK: - 성격

    let patience: CGFloat            // 0.0 ~ 1.0
    let energy: CGFloat              // 0.0 ~ 1.0

    // MARK: - 기본 털 색상 (갈색 계열)

    private static let baseFurHue: Double = 25.0 / 360.0       // 갈색
    private static let baseFurSaturation: Double = 0.55
    private static let baseFurBrightness: Double = 0.50

    // MARK: - 생성

    init(genes: CapybaraGenes) {
        bodyWidthScale = Self.map(genes.bodyWidth, to: 0.8...1.2)
        bodyHeightScale = Self.map(genes.bodyHeight, to: 0.85...1.15)
        headSizeScale = Self.map(genes.headSize, to: 0.85...1.15)
        noseSizeScale = Self.map(genes.noseSize, to: 0.7...1.3)
        noseHeightOffset = Self.map(genes.noseHeight, to: 0.8...1.2)
        earSizeScale = Self.map(genes.earSize, to: 0.7...1.3)
        earPointiness = CGFloat(genes.earPointiness)
        eyeSizeScale = Self.map(genes.eyeSize, to: 0.8...1.2)
        eyeSpacingScale = Self.map(genes.eyeSpacing, to: 0.8...1.2)
        cheekSize = CGFloat(genes.cheekSize)
        tailLengthScale = Self.map(genes.tailLength, to: 0.7...1.3)
        legThicknessScale = Self.map(genes.legThickness, to: 0.8...1.2)

        let hue = Self.baseFurHue + Double(genes.furHue - 0.5) * (30.0 / 360.0)
        let sat = Self.baseFurSaturation + Double(genes.furSaturation - 0.5) * 0.30
        let bri = Self.baseFurBrightness + Double(genes.furBrightness - 0.5) * 0.20

        furColor = Color(
            hue: max(0, min(1, hue)),
            saturation: max(0.1, min(1, sat)),
            brightness: max(0.2, min(0.85, bri))
        )
        furColorLight = Color(
            hue: max(0, min(1, hue)),
            saturation: max(0.05, min(0.8, sat - 0.15)),
            brightness: max(0.3, min(0.95, bri + 0.15))
        )

        patience = CGFloat(genes.patience)
        energy = CGFloat(genes.energy)
    }

    /// gene 값(0~1)을 target 범위로 선형 매핑
    private static func map(_ gene: Float, to range: ClosedRange<CGFloat>) -> CGFloat {
        let t = CGFloat(gene)
        return range.lowerBound + t * (range.upperBound - range.lowerBound)
    }
}
