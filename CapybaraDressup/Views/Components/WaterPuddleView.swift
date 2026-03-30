import SwiftUI

/// 물웅덩이 — 메인 화면 하단에 배치
struct WaterPuddleView: View {
    let isOccupied: Bool

    @State private var ripplePhase: CGFloat = 0

    var body: some View {
        ZStack {
            // 물 웅덩이 본체
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.4, green: 0.7, blue: 0.85).opacity(0.6),
                            Color(red: 0.3, green: 0.55, blue: 0.75).opacity(0.8)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 60
                    )
                )
                .frame(width: 140, height: 50)

            // 물결 효과
            if isOccupied {
                ForEach(0..<3, id: \.self) { i in
                    Ellipse()
                        .stroke(
                            Color.white.opacity(0.3 - Double(i) * 0.1),
                            lineWidth: 1
                        )
                        .frame(
                            width: 80 + CGFloat(i) * 25 + ripplePhase * 5,
                            height: 30 + CGFloat(i) * 10 + ripplePhase * 2
                        )
                }
            }

            // 하이라이트
            Ellipse()
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 15)
                .offset(x: -20, y: -8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                ripplePhase = 1
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        WaterPuddleView(isOccupied: false)
        WaterPuddleView(isOccupied: true)
    }
    .padding()
    .background(Color(red: 0.95, green: 0.93, blue: 0.88))
}
