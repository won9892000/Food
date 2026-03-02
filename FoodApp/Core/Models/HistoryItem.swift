import Foundation

struct HistoryItem: Codable, Identifiable {
    let id: UUID
    let foodId: Int
    let foodName: String
    let foodEmoji: String
    let date: Date

    init(food: Food) {
        self.id = UUID()
        self.foodId = food.id
        self.foodName = food.name
        self.foodEmoji = food.emoji
        self.date = Date()
    }
}
