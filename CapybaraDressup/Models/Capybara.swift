import Foundation
import SwiftData

@Model
final class Capybara {
    var id: UUID
    var name: String
    var genesData: Data
    var parentAId: UUID?
    var parentBId: UUID?
    var affection: Double
    var hunger: Double
    var createdAt: Date
    var lastInteractedAt: Date

    init(
        name: String,
        genes: CapybaraGenes,
        parentAId: UUID? = nil,
        parentBId: UUID? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.genesData = (try? JSONEncoder().encode(genes)) ?? Data()
        self.parentAId = parentAId
        self.parentBId = parentBId
        self.affection = 50
        self.hunger = 50
        self.createdAt = Date()
        self.lastInteractedAt = Date()
    }

    var genes: CapybaraGenes {
        get {
            (try? JSONDecoder().decode(CapybaraGenes.self, from: genesData)) ?? .random()
        }
        set {
            genesData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    func addAffection(_ amount: Double) {
        affection = min(100, max(0, affection + amount))
        lastInteractedAt = Date()
    }

    func addHunger(_ amount: Double) {
        hunger = min(100, max(0, hunger + amount))
        lastInteractedAt = Date()
    }
}
