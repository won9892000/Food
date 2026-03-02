import Foundation

struct Food: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let cuisine: String
    let mealTime: [String]
    let carbBase: String
    let soup: Bool
    let spicy: Int
    let greasy: Int
    let health: String
    let moodFit: [String]
    let avoidTags: [String]
    let isPopular: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, cuisine
        case mealTime = "meal_time"
        case carbBase = "carb_base"
        case soup, spicy, greasy, health
        case moodFit = "mood_fit"
        case avoidTags = "avoid_tags"
        case isPopular = "is_popular"
    }
}
