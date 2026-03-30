import SwiftUI
import SwiftData

@Observable
final class CapybaraViewModel {

    // MARK: - State

    var selectedCapybara: Capybara?
    var expression: ExpressionState = .idle
    var isInWater: Bool = false
    var showParticles: ParticleType? = nil
    var capybaraOffset: CGSize = .zero

    // MARK: - Constants

    static let maxCapybaras = 10

    private var interactionCount: Int = 0
    private var lastInteractionTime: Date = .distantPast
    private var longPressTimer: Timer?

    // MARK: - Appearance (computed)

    var appearance: CapybaraAppearance? {
        guard let capybara = selectedCapybara else { return nil }
        return CapybaraAppearance(genes: capybara.genes)
    }

    // MARK: - CRUD

    func adopt(name: String, context: ModelContext) -> Capybara? {
        let count = capybaraCount(context: context)
        guard count < Self.maxCapybaras else { return nil }

        let genes = CapybaraGenes.random()
        let capybara = Capybara(name: name, genes: genes)
        context.insert(capybara)
        selectedCapybara = capybara
        return capybara
    }

    func fetchAll(context: ModelContext) -> [Capybara] {
        let descriptor = FetchDescriptor<Capybara>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func capybaraCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Capybara>()
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func select(_ capybara: Capybara) {
        selectedCapybara = capybara
        expression = .idle
        isInWater = false
        capybaraOffset = .zero
    }

    func rename(_ capybara: Capybara, to newName: String) {
        capybara.name = newName
    }

    // MARK: - 상호작용

    func pet() {
        guard let capybara = selectedCapybara else { return }
        if detectOverTouch() {
            expression = .irritated
            showParticles = nil
            HapticManager.shared.play(.light)
            SoundManager.shared.play(.chatter)
            return
        }
        expression = .happy
        capybara.addAffection(2)
        showParticles = .hearts
        HapticManager.shared.play(.soft)
        SoundManager.shared.play(.purr)
        scheduleReturnToIdle()
    }

    func feed() {
        guard let capybara = selectedCapybara else { return }
        expression = .eating
        capybara.addHunger(10)
        capybara.addAffection(1)
        showParticles = nil
        HapticManager.shared.play(.medium)
        SoundManager.shared.play(.click)
        scheduleReturnToIdle(delay: 1.5)
    }

    func play() {
        guard let capybara = selectedCapybara else { return }
        expression = .excited
        capybara.addAffection(5)
        showParticles = .stars
        HapticManager.shared.play(.rigid)
        SoundManager.shared.play(.click)
        scheduleReturnToIdle(delay: 1.0)
    }

    func startLongPress() {
        guard let capybara = selectedCapybara else { return }
        expression = .sleepy
        HapticManager.shared.play(.soft)
        SoundManager.shared.play(.purr)

        longPressTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            capybara.addAffection(1)
            HapticManager.shared.play(.soft)
        }
    }

    func endLongPress() {
        longPressTimer?.invalidate()
        longPressTimer = nil
        scheduleReturnToIdle(delay: 0.3)
    }

    func surprise() {
        guard selectedCapybara != nil else { return }
        expression = .surprised
        HapticManager.shared.play(.rigid)
        SoundManager.shared.play(.bark)
        scheduleReturnToIdle(delay: 0.8)
    }

    // MARK: - 물웅덩이

    func enterWater() {
        guard let capybara = selectedCapybara else { return }
        isInWater = true
        expression = .bathing
        showParticles = .water
        HapticManager.shared.play(.soft)
        SoundManager.shared.play(.purr)

        // bathing 보너스: patience에 따라 호감도 증가
        let patienceBonus = appearance?.patience ?? 0.5
        capybara.addAffection(3 + Double(patienceBonus) * 2)
    }

    func exitWater() {
        isInWater = false
        showParticles = nil
        scheduleReturnToIdle(delay: 0.5)
    }

    // MARK: - Private

    private func detectOverTouch() -> Bool {
        let now = Date()
        if now.timeIntervalSince(lastInteractionTime) < 0.5 {
            interactionCount += 1
        } else {
            interactionCount = 1
        }
        lastInteractionTime = now
        return interactionCount > 10
    }

    private func scheduleReturnToIdle(delay: TimeInterval = 2.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            if self.expression != .bathing && self.expression != .sleepy {
                self.expression = .idle
                self.showParticles = nil
            }
        }
    }
}

// MARK: - 파티클 타입

enum ParticleType {
    case hearts
    case stars
    case water
}
