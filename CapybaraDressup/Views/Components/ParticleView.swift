import SwiftUI

struct ParticleView: View {
    let type: ParticleType
    @State private var particles: [Particle] = []

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate

                for particle in particles {
                    let age = now - particle.birthTime
                    guard age < particle.lifetime else { continue }

                    let progress = age / particle.lifetime
                    let opacity = 1.0 - progress
                    let y = particle.startY - CGFloat(age) * particle.speed
                    let x = particle.startX + sin(CGFloat(age) * particle.wobble) * 10

                    let symbol = particleSymbol
                    let point = CGPoint(x: x, y: y)
                    let scale = particle.scale * (1.0 - CGFloat(progress) * 0.3)

                    context.opacity = opacity
                    context.draw(
                        context.resolve(
                            Text(symbol)
                                .font(.system(size: 20 * scale))
                        ),
                        at: point
                    )
                }
            }
        }
        .onAppear { spawnParticles() }
        .onChange(of: type) { _, _ in spawnParticles() }
    }

    private var particleSymbol: String {
        switch type {
        case .hearts: return ["❤️", "💕", "💗"].randomElement()!
        case .stars: return ["⭐", "✨", "🌟"].randomElement()!
        case .water: return ["💧", "💦"].randomElement()!
        }
    }

    private func spawnParticles() {
        let now = Date.timeIntervalSinceReferenceDate
        particles = (0..<8).map { _ in
            Particle(
                startX: CGFloat.random(in: 50...200),
                startY: CGFloat.random(in: 100...180),
                speed: CGFloat.random(in: 30...60),
                wobble: CGFloat.random(in: 2...5),
                scale: CGFloat.random(in: 0.6...1.2),
                lifetime: Double.random(in: 1.0...2.0),
                birthTime: now + Double.random(in: 0...0.5)
            )
        }
    }
}

private struct Particle: Identifiable {
    let id = UUID()
    let startX: CGFloat
    let startY: CGFloat
    let speed: CGFloat
    let wobble: CGFloat
    let scale: CGFloat
    let lifetime: TimeInterval
    let birthTime: TimeInterval
}

#Preview {
    ParticleView(type: .hearts)
        .frame(width: 250, height: 250)
        .background(Color.gray.opacity(0.1))
}
