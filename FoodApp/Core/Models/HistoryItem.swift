import Foundation

struct HistoryItem: Codable, Identifiable {
    let id: UUID
    let foodId: String
    let foodName: String
    let date: Date

    init(food: Food) {
        self.id = UUID()
        self.foodId = food.id
        self.foodName = food.name
        self.date = Date()
    }

    init(foodId: String, foodName: String, date: Date) {
        self.id = UUID()
        self.foodId = foodId
        self.foodName = foodName
        self.date = date
    }
}
