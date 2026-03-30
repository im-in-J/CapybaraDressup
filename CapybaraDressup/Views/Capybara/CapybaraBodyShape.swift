import SwiftUI

/// 카피바라 몸통 — 통통한 타원형 배럴 체형
struct CapybaraBodyShape: Shape {
    let widthScale: CGFloat
    let heightScale: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width * widthScale
        let h = rect.height * heightScale
        let x = rect.midX - w / 2
        let y = rect.midY - h / 2

        // 둥근 배럴 형태 — 약간 아래가 넓은 타원
        path.addEllipse(in: CGRect(x: x, y: y, width: w, height: h))

        return path
    }
}

#Preview {
    VStack(spacing: 20) {
        CapybaraBodyShape(widthScale: 0.8, heightScale: 0.85)
            .fill(Color.brown)
            .frame(width: 200, height: 150)

        CapybaraBodyShape(widthScale: 1.2, heightScale: 1.15)
            .fill(Color.brown)
            .frame(width: 200, height: 150)
    }
}
