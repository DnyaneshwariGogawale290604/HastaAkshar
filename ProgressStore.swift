import Foundation
import Combine

final class ProgressStore: ObservableObject {

    @Published private(set) var completedMudraIds: Set<UUID> = []
    @Published private(set) var practiceHistory:  [PracticeResult] = []
    @Published private(set) var lastPracticedId:  UUID? = nil

    private enum Keys {
        static let completed = "hastaakshar.completed_ids"
        static let history   = "hastaakshar.practice_history"
    }

    private let defaults = UserDefaults.standard

    init() {
        loadFromDisk()
    }

    func isUnlocked(_ mudra: Mudra, in allMudras: [Mudra]) -> Bool {
        let categoryMudras = allMudras
            .filter { $0.category == mudra.category }
            .sorted { $0.orderIndex < $1.orderIndex }

        guard let position = categoryMudras.firstIndex(where: { $0.id == mudra.id }) else {
            return false
        }
        if position == 0 { return true }
        let previous = categoryMudras[position - 1]
        return completedMudraIds.contains(previous.id)
    }

    func recordResult(_ result: PracticeResult) {
        practiceHistory.append(result)
        if result.passed {
            completedMudraIds.insert(result.mudraId)
        }
        lastPracticedId = result.mudraId
        saveToDisk()
    }

    func bestScore(for mudraId: UUID) -> Double? {
        practiceHistory
            .filter { $0.mudraId == mudraId }
            .map    { $0.accuracyScore }
            .max()
    }

    func attemptCount(for mudraId: UUID) -> Int {
        practiceHistory.filter { $0.mudraId == mudraId }.count
    }

    func progress(for category: MudraCategory, in allMudras: [Mudra]) -> Double {
        let total = allMudras.filter { $0.category == category }.count
        guard total > 0 else { return 0 }
        let done  = allMudras.filter { $0.category == category && completedMudraIds.contains($0.id) }.count
        return Double(done) / Double(total)
    }

    private func saveToDisk() {
        let idStrings = completedMudraIds.map { $0.uuidString }
        defaults.set(idStrings, forKey: Keys.completed)

        if let data = try? JSONEncoder().encode(practiceHistory) {
            defaults.set(data, forKey: Keys.history)
        }
    }

    private func loadFromDisk() {
        if let idStrings = defaults.stringArray(forKey: Keys.completed) {
            completedMudraIds = Set(idStrings.compactMap { UUID(uuidString: $0) })
        }

        if let data    = defaults.data(forKey: Keys.history),
           let history = try? JSONDecoder().decode([PracticeResult].self, from: data) {
            practiceHistory = history
        }
    }
}
