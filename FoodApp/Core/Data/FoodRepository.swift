import Foundation

class FoodRepository: ObservableObject {
    let foods: [Food]
    let questions: [Question]

    @Published var history: [HistoryItem] = [] {
        didSet { saveHistory() }
    }

    private let historyKey = "foodHistory"

    init() {
        self.foods = JSONLoader.load("foods")
        self.questions = JSONLoader.load("questions")
        self.history = Self.loadHistory()
    }

    func saveChoice(_ food: Food) {
        let item = HistoryItem(food: food)
        history.insert(item, at: 0)
        if history.count > 100 {
            history = Array(history.prefix(100))
        }
    }

    func recentFoodIds(days: Int) -> Set<Int> {
        let cutoff = Date().addingTimeInterval(-Double(days) * 86400)
        return Set(
            history
                .filter { $0.date > cutoff }
                .map { $0.foodId }
        )
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    private static func loadHistory() -> [HistoryItem] {
        guard let data = UserDefaults.standard.data(forKey: "foodHistory"),
              let items = try? JSONDecoder().decode([HistoryItem].self, from: data) else {
            return []
        }
        return items
    }
}
