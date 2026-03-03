import Foundation

/// Represents a scored food item with reason components explaining the score.
struct FoodScore {
    let food: Food
    let score: Double
    let reasonComponents: [String]

    /// Generates a human-readable reason string from the reason components.
    var reason: String {
        guard !reasonComponents.isEmpty else {
            return "오늘 딱 맞는 메뉴예요! 😋"
        }
        return reasonComponents.joined(separator: " + ") + " 👉 추천!"
    }
}
