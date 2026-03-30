import SwiftUI

/// 카피바라 귀 — 작고 둥근/뾰족한 귀 한 쪽
struct CapybaraEarShape: Shape {
    let sizeScale: CGFloat
    let pointiness: CGFloat   // 0 = 둥근, 1 = 뾰족

    /// 귀 각도 애니메이션용 (-1 뒤로, 0 자연, 0.5 옆, 1 위)
    var angle: CGFloat = 0

    var animatableData: CGFloat {
        get { angle }
        set { angle = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width * sizeScale
        let h = rect.height * sizeScale
        let cx = rect.midX
        let cy = rect.midY

        // 뾰족한 정도에 따라 상단 꼭짓점 조정
        let topY = cy - h / 2
        let topControlOffset = w * 0.3 * (1 - pointiness)

        path.move(to: CGPoint(x: cx - w / 2, y: cy + h * 0.2))

        // 왼쪽 곡선 → 꼭대기
        path.addQuadCurve(
            to: CGPoint(x: cx, y: topY),
            control: CGPoint(x: cx - w / 2 - topControlOffset * 0.3, y: cy - h * 0.3)
        )

        // 꼭대기 → 오른쪽 곡선
        path.addQuadCurve(
            to: CGPoint(x: cx + w / 2, y: cy + h * 0.2),
            control: CGPoint(x: cx + w / 2 + topControlOffset * 0.3, y: cy - h * 0.3)
        )

        path.closeSubpath()

        return path
    }
}

#Preview {
    HStack(spacing: 20) {
        // 둥근 귀
        CapybaraEarShape(sizeScale: 1.0, pointiness: 0.0)
            .fill(Color.brown)
            .frame(width: 30, height: 25)

        // 뾰족한 귀
        CapybaraEarShape(sizeScale: 1.0, pointiness: 1.0)
            .fill(Color.brown)
            .frame(width: 30, height: 25)
    }
}
