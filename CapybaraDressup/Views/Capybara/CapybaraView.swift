import SwiftUI

/// 카피바라 전체 조합 뷰 — 모든 부위를 ZStack으로 합성
struct CapybaraView: View {
    let appearance: CapybaraAppearance
    let expression: ExpressionState
    var size: CGFloat = 250

    // 점프 애니메이션
    @State private var jumpOffset: CGFloat = 0

    private var bodySize: CGSize {
        CGSize(width: size * 0.85, height: size * 0.55)
    }

    private var headSize: CGSize {
        CGSize(
            width: size * 0.45 * appearance.headSizeScale,
            height: size * 0.35 * appearance.headSizeScale
        )
    }

    var body: some View {
        ZStack {
            // MARK: - 꼬리 (가장 뒤)
            CapybaraTailShape(lengthScale: appearance.tailLengthScale)
                .fill(appearance.furColor)
                .frame(width: bodySize.width, height: bodySize.height)

            // MARK: - 다리 (몸통 뒤)
            CapybaraLegShape(thicknessScale: appearance.legThicknessScale)
                .fill(appearance.furColor.opacity(0.85))
                .frame(width: bodySize.width, height: bodySize.height)

            // MARK: - 몸통
            CapybaraBodyShape(
                widthScale: appearance.bodyWidthScale,
                heightScale: appearance.bodyHeightScale
            )
            .fill(appearance.furColor)
            .frame(width: bodySize.width, height: bodySize.height)

            // 배 부분 밝은색
            Ellipse()
                .fill(appearance.furColorLight)
                .frame(
                    width: bodySize.width * 0.5 * appearance.bodyWidthScale,
                    height: bodySize.height * 0.4 * appearance.bodyHeightScale
                )
                .offset(y: bodySize.height * 0.05)

            // MARK: - 머리
            ZStack {
                // 머리 형태
                CapybaraHeadShape(sizeScale: 1.0)
                    .fill(appearance.furColor)
                    .frame(width: headSize.width, height: headSize.height)

                // 귀 (머리 위 양쪽)
                HStack(spacing: headSize.width * 0.55) {
                    CapybaraEarShape(
                        sizeScale: appearance.earSizeScale,
                        pointiness: appearance.earPointiness,
                        angle: expression.earAngle
                    )
                    .fill(appearance.furColor)
                    .frame(width: headSize.width * 0.2, height: headSize.height * 0.25)
                    .rotationEffect(.degrees(-15 + Double(expression.earAngle) * 10))

                    CapybaraEarShape(
                        sizeScale: appearance.earSizeScale,
                        pointiness: appearance.earPointiness,
                        angle: expression.earAngle
                    )
                    .fill(appearance.furColor)
                    .frame(width: headSize.width * 0.2, height: headSize.height * 0.25)
                    .rotationEffect(.degrees(15 - Double(expression.earAngle) * 10))
                }
                .offset(y: -headSize.height * 0.4)

                // 얼굴
                CapybaraFaceView(
                    appearance: appearance,
                    expression: expression,
                    headSize: headSize
                )
            }
            .offset(x: -size * 0.22, y: -size * 0.18)
        }
        .frame(width: size, height: size)
        .offset(y: jumpOffset)
        .animation(.easeInOut(duration: 0.3), value: expression)
        .onChange(of: expression) { _, newValue in
            if newValue == .excited {
                triggerJump()
            }
        }
    }

    private func triggerJump() {
        let jumpHeight: CGFloat = -30 * (0.7 + appearance.energy * 0.6)
        withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
            jumpOffset = jumpHeight
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                jumpOffset = 0
            }
        }
    }
}

// MARK: - 미니 버전 (목록용)

struct CapybaraMiniView: View {
    let appearance: CapybaraAppearance

    var body: some View {
        CapybaraView(appearance: appearance, expression: .idle, size: 80)
    }
}

#Preview("다양한 유전자") {
    VStack(spacing: 30) {
        ForEach(0..<3, id: \.self) { _ in
            CapybaraView(
                appearance: CapybaraAppearance(genes: .random()),
                expression: .idle
            )
        }
    }
}

#Preview("표정") {
    let appearance = CapybaraAppearance(genes: .random())
    ScrollView {
        VStack(spacing: 20) {
            ForEach(ExpressionState.allCases, id: \.self) { expr in
                VStack {
                    Text(expr.rawValue)
                        .font(.caption)
                    CapybaraView(
                        appearance: appearance,
                        expression: expr,
                        size: 150
                    )
                }
            }
        }
    }
}
