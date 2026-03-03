import Foundation

/// Structured model representing user answers from the question flow.
struct AnswerState {
    let mealTime: String
    let mood: String
    let spicy: Int
    let soup: Bool?
    let carbBase: String
    let health: String
    let greasy: Int
    let avoidTags: Set<String>

    /// Initialize from the legacy dictionary format used by QuestionFlowViewModel.
    init(from dict: [String: String]) {
        self.mealTime = dict["meal_time"] ?? ""
        self.mood = dict["mood"] ?? ""
        self.spicy = Int(dict["spicy"] ?? "0") ?? 0
        self.soup = dict["soup"].map { $0 == "true" }
        self.carbBase = dict["carb_base"] ?? "any"
        self.health = dict["health"] ?? "balanced"
        self.greasy = Int(dict["greasy"] ?? "1") ?? 1
        let avoidStr = dict["avoid_tags"] ?? ""
        self.avoidTags = avoidStr.isEmpty ? [] : Set(avoidStr.split(separator: ",").map(String.init))
    }

    init(
        mealTime: String,
        mood: String,
        spicy: Int,
        soup: Bool?,
        carbBase: String,
        health: String,
        greasy: Int,
        avoidTags: Set<String>
    ) {
        self.mealTime = mealTime
        self.mood = mood
        self.spicy = spicy
        self.soup = soup
        self.carbBase = carbBase
        self.health = health
        self.greasy = greasy
        self.avoidTags = avoidTags
    }
}

/// Settings that control recommendation behavior.
struct RecommendationSettings {
    let avoidRecent: Bool
    let avoidWindowDays: Int

    init(avoidRecent: Bool = false, avoidWindowDays: Int = 3) {
        self.avoidRecent = avoidRecent
        self.avoidWindowDays = avoidWindowDays
    }
}
