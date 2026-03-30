import SwiftUI

/// 카피바라 꼬리 — 거의 퇴화된 아주 짧은 꼬리
struct CapybaraTailShape: Shape {
    let lengthScale: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tailWidth = rect.width * 0.06
        let tailLength = rect.height * 0.08 * lengthScale

        let startX = rect.midX + rect.width * 0.4
        let startY = rect.midY - rect.height * 0.05

        // 짧은 꼬리 — 약간 위로 올라가는 곡선
        path.move(to: CGPoint(x: startX, y: startY))
        path.addQuadCurve(
            to: CGPoint(x: startX + tailLength, y: startY - tailLength * 0.5),
            control: CGPoint(x: startX + tailLength * 0.7, y: startY + tailWidth * 0.3)
        )
        path.addQuadCurve(
            to: CGPoint(x: startX, y: startY + tailWidth),
            control: CGPoint(x: startX + tailLength * 0.5, y: startY + tailWidth * 1.2)
        )
        path.closeSubpath()

        return path
    }
}

#Preview {
    CapybaraTailShape(lengthScale: 1.0)
        .fill(Color.brown)
        .frame(width: 200, height: 150)
}
