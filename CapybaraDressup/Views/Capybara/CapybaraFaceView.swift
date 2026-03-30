import SwiftUI

/// 카피바라 얼굴 — 눈, 코, 입, 볼 (표정 애니메이션 포함)
struct CapybaraFaceView: View {
    let appearance: CapybaraAppearance
    let expression: ExpressionState
    let headSize: CGSize

    @State private var blinkTimer: Bool = false

    private var eyeOpenness: CGFloat {
        // idle 상태에서 깜빡임
        if expression == .idle && blinkTimer {
            return 0.05
        }
        return expression.eyeOpenness
    }

    var body: some View {
        let eyeSpacing = headSize.width * 0.15 * appearance.eyeSpacingScale
        let eyeSize = headSize.width * 0.08 * appearance.eyeSizeScale

        ZStack {
            // MARK: - 눈
            HStack(spacing: eyeSpacing) {
                EyeView(
                    size: eyeSize,
                    openness: eyeOpenness
                )
                EyeView(
                    size: eyeSize,
                    openness: eyeOpenness
                )
            }
            .offset(y: -headSize.height * 0.08)

            // MARK: - 코
            NoseView(
                width: headSize.width * 0.18 * appearance.noseSizeScale,
                height: headSize.height * 0.12 * appearance.noseSizeScale
            )
            .offset(y: headSize.height * 0.08 * appearance.noseHeightOffset)

            // MARK: - 입
            MouthView(
                width: headSize.width * 0.12,
                openness: expression.mouthOpenness,
                isSmiling: expression.isSmiling
            )
            .offset(y: headSize.height * 0.22)

            // MARK: - 볼터치
            if appearance.cheekSize > 0.2 {
                let cheekRadius = headSize.width * 0.06 * appearance.cheekSize
                HStack(spacing: headSize.width * 0.35) {
                    Circle()
                        .fill(Color.pink.opacity(0.3 * Double(appearance.cheekSize)))
                        .frame(width: cheekRadius, height: cheekRadius)
                    Circle()
                        .fill(Color.pink.opacity(0.3 * Double(appearance.cheekSize)))
                        .frame(width: cheekRadius, height: cheekRadius)
                }
                .offset(y: headSize.height * 0.1)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: expression)
        .onAppear { startBlinking() }
    }

    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            guard expression == .idle else { return }
            withAnimation(.easeInOut(duration: 0.15)) {
                blinkTimer = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    blinkTimer = false
                }
            }
        }
    }
}

// MARK: - 눈

private struct EyeView: View {
    let size: CGFloat
    let openness: CGFloat

    var body: some View {
        ZStack {
            // 눈 흰자
            Ellipse()
                .fill(Color.white)
                .frame(width: size, height: size * openness)

            // 눈동자
            if openness > 0.2 {
                Circle()
                    .fill(Color(white: 0.15))
                    .frame(width: size * 0.55, height: size * 0.55)
                    .offset(y: size * 0.02)

                // 하이라이트
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.18, height: size * 0.18)
                    .offset(x: -size * 0.1, y: -size * 0.08)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: openness)
    }
}

// MARK: - 코

private struct NoseView: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Ellipse()
            .fill(Color(red: 0.25, green: 0.18, blue: 0.15))
            .frame(width: width, height: height)
            .overlay(
                // 콧구멍
                HStack(spacing: width * 0.2) {
                    Ellipse()
                        .fill(Color(red: 0.15, green: 0.1, blue: 0.08))
                        .frame(width: width * 0.2, height: height * 0.25)
                    Ellipse()
                        .fill(Color(red: 0.15, green: 0.1, blue: 0.08))
                        .frame(width: width * 0.2, height: height * 0.25)
                }
            )
    }
}

// MARK: - 입

private struct MouthView: View {
    let width: CGFloat
    let openness: CGFloat
    let isSmiling: Bool

    var body: some View {
        Canvas { context, size in
            var path = Path()
            let midX = size.width / 2
            let midY = size.height / 2

            if isSmiling {
                // 미소 — 아래로 볼록한 곡선
                path.move(to: CGPoint(x: midX - width / 2, y: midY))
                path.addQuadCurve(
                    to: CGPoint(x: midX + width / 2, y: midY),
                    control: CGPoint(x: midX, y: midY + width * openness * 0.5)
                )
            } else if openness > 0.1 {
                // 벌린 입 — 타원
                let rect = CGRect(
                    x: midX - width * 0.4,
                    y: midY - width * openness * 0.2,
                    width: width * 0.8,
                    height: width * openness * 0.4
                )
                path.addEllipse(in: rect)
            } else {
                // 닫힌 입 — 수평선
                path.move(to: CGPoint(x: midX - width / 3, y: midY))
                path.addLine(to: CGPoint(x: midX + width / 3, y: midY))
            }

            if openness > 0.1 && !isSmiling {
                context.fill(path, with: .color(Color(red: 0.3, green: 0.15, blue: 0.15)))
            } else {
                context.stroke(
                    path,
                    with: .color(Color(red: 0.25, green: 0.18, blue: 0.15)),
                    lineWidth: 1.5
                )
            }
        }
        .frame(width: width * 1.2, height: width * 0.8)
        .animation(.easeInOut(duration: 0.3), value: openness)
        .animation(.easeInOut(duration: 0.3), value: isSmiling)
    }
}
