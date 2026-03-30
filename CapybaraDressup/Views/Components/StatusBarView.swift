import SwiftUI

struct StatusBarView: View {
    let affection: Double
    let hunger: Double

    var body: some View {
        VStack(spacing: 8) {
            StatBar(
                icon: "heart.fill",
                iconColor: .pink,
                label: "호감도",
                value: affection
            )
            StatBar(
                icon: "leaf.fill",
                iconColor: .green,
                label: "포만감",
                value: hunger
            )
        }
        .padding(.horizontal, 24)
    }
}

private struct StatBar: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: Double

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.system(size: 14))
                .frame(width: 20)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(iconColor.opacity(0.7))
                        .frame(width: geo.size.width * CGFloat(value / 100))
                        .animation(.easeInOut(duration: 0.3), value: value)
                }
            }
            .frame(height: 8)

            Text("\(Int(value))")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .trailing)
        }
    }
}

#Preview {
    StatusBarView(affection: 72, hunger: 45)
        .padding()
}
