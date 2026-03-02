import Foundation

class FoodRepository: ObservableObject {
    let foods: [Food]
    let questions: [Question]

    @Published var history: [HistoryItem] = [] {
        didSet { saveHistory() }
    }

    private let historyKey = "foodHistory"
    private let maxHistoryItems = 100

    init() {
        self.foods = JSONLoader.load("foods")
        self.questions = JSONLoader.load("questions")
        self.history = Self.loadHistory()
        printLoadingLog()
    }

    func saveChoice(_ food: Food) {
        let item = HistoryItem(food: food)
        history.insert(item, at: 0)
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }
    }

    func recentFoodIds(days: Int) -> Set<String> {
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

    private func printLoadingLog() {
        print("[FoodRepository] ✅ foods.json loaded: \(foods.count) items")
        print("[FoodRepository] ✅ questions.json loaded: \(questions.count) questions")
        if let first = foods.first {
            print("[FoodRepository] 📋 First food: \(first.name) (id: \(first.id), cuisine: \(first.cuisine))")
        }
        if let first = questions.first {
            print("[FoodRepository] 📋 First question: \(first.title) (id: \(first.id), type: \(first.type.rawValue))")
        }
    }
}
