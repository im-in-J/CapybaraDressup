import SwiftUI

/// 카피바라 다리 — 짧고 통통한 네 다리
struct CapybaraLegShape: Shape {
    let thicknessScale: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let legWidth = rect.width * 0.13 * thicknessScale
        let legHeight = rect.height * 0.35
        let bodyBottom = rect.midY + rect.height * 0.15
        let cornerRadius = legWidth * 0.4

        // 다리 위치: 앞다리 2개, 뒷다리 2개
        let positions: [CGFloat] = [
            rect.midX - rect.width * 0.28,  // 왼쪽 앞다리
            rect.midX - rect.width * 0.10,  // 왼쪽 뒷다리
            rect.midX + rect.width * 0.10,  // 오른쪽 뒷다리
            rect.midX + rect.width * 0.28,  // 오른쪽 앞다리
        ]

        for x in positions {
            let legRect = CGRect(
                x: x - legWidth / 2,
                y: bodyBottom,
                width: legWidth,
                height: legHeight
            )
            path.addRoundedRect(
                in: legRect,
                cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
            )
        }

        return path
    }
}

#Preview {
    ZStack {
        CapybaraLegShape(thicknessScale: 1.0)
            .fill(Color.brown)
    }
    .frame(width: 200, height: 200)
}
