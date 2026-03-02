import Foundation

struct Food: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let emoji: String
    let cuisine: String
    let carbBase: String
    let soup: String
    let spicy: Int
    let greasy: Int
    let health: String
    let moodFit: [String]
    let avoidTags: [String]
    let mealTime: [String]

    enum CodingKeys: String, CodingKey {
        case id, name, emoji, cuisine
        case carbBase = "carb_base"
        case soup, spicy, greasy, health
        case moodFit = "mood_fit"
        case avoidTags = "avoid_tags"
        case mealTime = "meal_time"
    }
}
