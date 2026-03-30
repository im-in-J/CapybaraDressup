import SwiftUI

/// 카피바라 머리 — 넓적하고 둥근 사각형 느낌
struct CapybaraHeadShape: Shape {
    let sizeScale: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.width * sizeScale
        let h = rect.height * sizeScale * 0.85  // 가로로 약간 넓적
        let x = rect.midX - w / 2
        let y = rect.midY - h / 2

        let cornerRadius = min(w, h) * 0.35

        path.addRoundedRect(
            in: CGRect(x: x, y: y, width: w, height: h),
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )

        return path
    }
}

#Preview {
    CapybaraHeadShape(sizeScale: 1.0)
        .fill(Color.brown)
        .frame(width: 120, height: 100)
}
