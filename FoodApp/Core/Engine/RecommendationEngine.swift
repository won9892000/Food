import Foundation

struct RecommendResult: Identifiable {
    let id = UUID()
    let food: Food
    let score: Double
    let reason: String
}

enum RecommendationEngine {
    static func recommend(
        answers: [String: String],
        foods: [Food],
        excludeIds: Set<String>,
        avoidIngredients: Set<String>,
        recentIds: Set<String>,
        avoidDuplicates: Bool
    ) -> [RecommendResult] {
        let filtered = foods.filter { food in
            if excludeIds.contains(food.id) { return false }

            for avoid in avoidIngredients {
                if food.avoidTags.contains(avoid) { return false }
            }

            if let mealTime = answers["meal_time"],
               !food.mealTime.contains(mealTime) {
                return false
            }

            if let avoidTag = answers["avoid_tags"], !avoidTag.isEmpty {
                if food.avoidTags.contains(avoidTag) { return false }
            }

            if let spicyStr = answers["spicy"],
               let spicy = Int(spicyStr),
               spicy == 0 && food.spicy >= 2 {
                return false
            }

            return true
        }

        let scored = filtered.map { food -> (food: Food, score: Double) in
            var score: Double = 0

            if let spicyStr = answers["spicy"], let spicy = Int(spicyStr) {
                let diff = abs(food.spicy - spicy)
                score += Double(3 - diff) * 2.0
            }

            if let carbBase = answers["carb_base"], carbBase != "any" {
                if food.carbBase == carbBase {
                    score += 3.0 * 1.2
                } else if food.carbBase == "any" {
                    score += 1.0
                }
            }

            if let health = answers["health"] {
                if food.health == health {
                    score += 2.0
                }
            }

            if let greasyStr = answers["greasy"], let greasy = Int(greasyStr) {
                let diff = abs(food.greasy - greasy)
                score += Double(2 - diff) * 1.0
            }

            if let soup = answers["soup"] {
                if soup == "true" && food.soup { score += 2.0 }
                if soup == "false" && !food.soup { score += 1.0 }
            }

            if let mood = answers["mood"], food.moodFit.contains(mood) {
                score += 2.0
            }

            if food.isPopular {
                score += 0.5
            }

            if avoidDuplicates && recentIds.contains(food.id) {
                score -= 5.0
            }

            return (food, score)
        }

        let sorted = scored.sorted { $0.score > $1.score }
        let topN = Array(sorted.prefix(min(10, sorted.count)))
        let picked = weightedRandomPick(topN, count: 3)

        return picked.map { item in
            RecommendResult(
                food: item.food,
                score: item.score,
                reason: buildReason(food: item.food, answers: answers)
            )
        }
    }

    private static func weightedRandomPick(
        _ items: [(food: Food, score: Double)],
        count: Int
    ) -> [(food: Food, score: Double)] {
        guard !items.isEmpty else { return [] }
        guard items.count > count else { return items }

        let minScore = items.last?.score ?? 0
        let weighted = items.map { (food: $0.food, score: $0.score, w: max($0.score - minScore + 1, 0.1)) }
        var results: [(food: Food, score: Double)] = []
        var used: Set<String> = []

        for _ in 0..<count {
            let totalW = weighted.filter { !used.contains($0.food.id) }.reduce(0.0) { $0 + $1.w }
            guard totalW > 0 else { break }

            var r = Double.random(in: 0..<totalW)
            for item in weighted {
                if used.contains(item.food.id) { continue }
                r -= item.w
                if r <= 0 {
                    results.append((food: item.food, score: item.score))
                    used.insert(item.food.id)
                    break
                }
            }
        }

        return results
    }

    private static func buildReason(food: Food, answers: [String: String]) -> String {
        var parts: [String] = []

        if answers["soup"] == "true" && food.soup {
            parts.append("국물 있는")
        }
        if answers["health"] == "light" && food.health == "light" {
            parts.append("가벼운")
        }
        if answers["health"] == "heavy" && food.health == "heavy" {
            parts.append("든든한")
        }
        if answers["mood"] == "stress" && food.moodFit.contains("stress") {
            parts.append("스트레스 해소에 딱인")
        }
        if answers["mood"] == "healing" && food.moodFit.contains("healing") {
            parts.append("힐링에 좋은")
        }
        if answers["mood"] == "happy" && food.moodFit.contains("happy") {
            parts.append("기분 좋을 때 먹는")
        }

        if parts.isEmpty {
            let defaults = ["오늘 딱 맞는", "취향에 어울리는", "이런 날 생각나는"]
            parts.append(defaults.randomElement() ?? "오늘 딱 맞는")
        }

        return parts.joined(separator: " ") + " 메뉴예요! 😋"
    }
}
