import Foundation

/// Enum defining all valid effect keys used by the RecommendationEngine
enum EffectKey: String, CaseIterable {
    case mealTime = "meal_time"
    case mood
    case spicy
    case soup
    case carbBase = "carb_base"
    case health
    case greasy
    case avoidTags = "avoid_tags"
}

/// Type-safe effects structure for answer options
struct AnswerEffect: Codable, Equatable {
    var mealTime: String?
    var mood: String?
    var spicy: String?
    var soup: String?
    var carbBase: String?
    var health: String?
    var greasy: String?
    var avoidTags: String?

    enum CodingKeys: String, CodingKey {
        case mealTime = "meal_time"
        case mood, spicy, soup
        case carbBase = "carb_base"
        case health, greasy
        case avoidTags = "avoid_tags"
    }

    subscript(key: EffectKey) -> String? {
        get {
            switch key {
            case .mealTime: return mealTime
            case .mood: return mood
            case .spicy: return spicy
            case .soup: return soup
            case .carbBase: return carbBase
            case .health: return health
            case .greasy: return greasy
            case .avoidTags: return avoidTags
            }
        }
        set {
            switch key {
            case .mealTime: mealTime = newValue
            case .mood: mood = newValue
            case .spicy: spicy = newValue
            case .soup: soup = newValue
            case .carbBase: carbBase = newValue
            case .health: health = newValue
            case .greasy: greasy = newValue
            case .avoidTags: avoidTags = newValue
            }
        }
    }

    /// Convert to dictionary for RecommendationEngine compatibility
    func toDictionary() -> [String: String] {
        var dict: [String: String] = [:]
        for key in EffectKey.allCases {
            if let value = self[key] {
                dict[key.rawValue] = value
            }
        }
        return dict
    }
}
