import Foundation

struct RecommendResult: Identifiable {
    let id = UUID()
    let food: Food
    let score: Double
    let reason: String
}

/// Protocol for injectable random number generation (deterministic testing).
protocol RandomNumberGenerating {
    mutating func nextDouble() -> Double
}

/// Default RNG using the system random number generator.
struct SystemRandom: RandomNumberGenerating {
    mutating func nextDouble() -> Double {
        return Double.random(in: 0..<1)
    }
}

/// Seeded RNG for deterministic testing.
struct SeededRandom: RandomNumberGenerating {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func nextDouble() -> Double {
        // Simple xorshift64 PRNG
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return Double(state % 1_000_000) / 1_000_000.0
    }
}

enum RecommendationEngine {

    // MARK: - New API (AnswerState-based with RNG injection)

    /// Primary recommendation method with structured inputs and RNG injection.
    static func recommend(
        foods: [Food],
        answers: AnswerState,
        history: [HistoryItem],
        settings: RecommendationSettings = RecommendationSettings(),
        rng: inout some RandomNumberGenerating
    ) -> [FoodScore] {
        // 1) Hard filter
        let filtered = hardFilter(foods: foods, answers: answers)

        // 2) Scoring
        let recentIds = recentFoodIds(from: history, windowDays: settings.avoidWindowDays)
        let scored = filtered.map { food -> FoodScore in
            scoreSingle(food: food, answers: answers, recentIds: recentIds, settings: settings)
        }

        // 3) Sort and pick top 10
        let sorted = scored.sorted { $0.score > $1.score }
        let topN = Array(sorted.prefix(min(10, sorted.count)))

        // 4) Weighted random pick 3
        let picked = weightedRandomPick(topN, count: 3, rng: &rng)

        // 5) Fill if insufficient
        if picked.count < 3 {
            var result = picked
            for item in topN where result.count < 3 {
                if !result.contains(where: { $0.food.id == item.food.id }) {
                    result.append(item)
                }
            }
            return result
        }

        return picked
    }

    // MARK: - Legacy API (backward compatible)

    static func recommend(
        answers: [String: String],
        foods: [Food],
        excludeIds: Set<String>,
        avoidIngredients: Set<String>,
        recentIds: Set<String>,
        avoidDuplicates: Bool
    ) -> [RecommendResult] {
        var answerState = AnswerState(from: answers)
        // Merge avoidIngredients into avoidTags
        let mergedTags = answerState.avoidTags.union(avoidIngredients)
        answerState = AnswerState(
            mealTime: answerState.mealTime,
            mood: answerState.mood,
            spicy: answerState.spicy,
            soup: answerState.soup,
            carbBase: answerState.carbBase,
            health: answerState.health,
            greasy: answerState.greasy,
            avoidTags: mergedTags
        )

        let settings = RecommendationSettings(
            avoidRecent: avoidDuplicates,
            avoidWindowDays: 3
        )

        // Build synthetic history from recentIds (use current date so they fall within window)
        var history: [HistoryItem] = []
        if avoidDuplicates {
            history = recentIds.map { id in
                HistoryItem(foodId: id, foodName: "", date: Date())
            }
        }

        // Exclude explicitly excluded IDs by filtering foods
        let availableFoods = foods.filter { !excludeIds.contains($0.id) }

        var rng: some RandomNumberGenerating = SystemRandom()
        let scores = recommend(
            foods: availableFoods,
            answers: answerState,
            history: history,
            settings: settings,
            rng: &rng
        )

        return scores.map { fs in
            RecommendResult(food: fs.food, score: fs.score, reason: fs.reason)
        }
    }

    // MARK: - Hard Filter

    static func hardFilter(foods: [Food], answers: AnswerState) -> [Food] {
        return foods.filter { food in
            // avoid_tags overlap → exclude
            let foodTags = Set(food.avoidTags)
            if !answers.avoidTags.isDisjoint(with: foodTags) {
                return false
            }

            // meal_time mismatch → exclude
            if !answers.mealTime.isEmpty && !food.mealTime.contains(answers.mealTime) {
                return false
            }

            return true
        }
    }

    // MARK: - Scoring

    static func scoreSingle(
        food: Food,
        answers: AnswerState,
        recentIds: Set<String>,
        settings: RecommendationSettings
    ) -> FoodScore {
        var score: Double = 0
        var reasons: [String] = []

        // spicy 일치도: weight 2.0 (max diff is 3 for range 0-3)
        let spicyDiff = abs(food.spicy - answers.spicy)
        let spicyScore = Double(3 - spicyDiff) / 3.0 * 2.0
        score += spicyScore
        if spicyDiff == 0 {
            let spicyLabels = ["안 매운", "살짝 매운", "매콤한", "아주 매운"]
            let label = answers.spicy < spicyLabels.count ? spicyLabels[answers.spicy] : "매운"
            reasons.append("\(label) 거 OK")
        }

        // soup 일치: weight 1.5
        if let wantSoup = answers.soup {
            if wantSoup == food.soup {
                score += 1.5
                reasons.append(wantSoup ? "국물 선호" : "국물 없는 거")
            }
        }

        // carb_base 일치: weight 1.2 (any → 0.6)
        if answers.carbBase != "any" {
            if food.carbBase == answers.carbBase {
                score += 1.2
                let carbLabels = ["rice": "밥", "noodle": "면", "bread": "빵"]
                reasons.append("\(carbLabels[answers.carbBase] ?? answers.carbBase) 베이스")
            }
        } else {
            score += 0.6
        }

        // health 일치: weight 1.0
        if food.health == answers.health {
            score += 1.0
            let healthLabels = ["light": "가벼운 느낌", "balanced": "적당한 느낌", "heavy": "든든한 느낌"]
            reasons.append(healthLabels[answers.health] ?? answers.health)
        }

        // greasy 일치/근접: weight 0.8
        let greasyDiff = abs(food.greasy - answers.greasy)
        let greasyScore = Double(max(2 - greasyDiff, 0)) / 2.0 * 0.8
        score += greasyScore
        if greasyDiff == 0 {
            let greasyLabels = ["담백한", "보통", "기름진"]
            let label = answers.greasy < greasyLabels.count ? greasyLabels[answers.greasy] : "기름진"
            reasons.append(label)
        }

        // moodFit 포함: weight 1.0
        if !answers.mood.isEmpty && food.moodFit.contains(answers.mood) {
            score += 1.0
            let moodLabels = [
                "stress": "스트레스 해소",
                "healing": "힐링",
                "happy": "기분 좋을 때",
                "lazy": "간편하게"
            ]
            reasons.append(moodLabels[answers.mood] ?? answers.mood)
        }

        // isPopular bonus: +0.2
        if food.isPopular {
            score += 0.2
        }

        // Recent avoidance penalty: -5.0
        if settings.avoidRecent && recentIds.contains(food.id) {
            score -= 5.0
        }

        // Avoid tags note
        if !answers.avoidTags.isEmpty {
            reasons.append("제외 조건 반영됨")
        }

        // Ensure at least 2 reason components
        if reasons.count < 2 {
            let defaults = ["오늘 딱 맞는", "취향에 어울리는"]
            for d in defaults {
                if reasons.count >= 2 { break }
                if !reasons.contains(d) {
                    reasons.append(d)
                }
            }
        }

        return FoodScore(food: food, score: score, reasonComponents: reasons)
    }

    // MARK: - Weighted Random Pick

    static func weightedRandomPick(
        _ items: [FoodScore],
        count: Int,
        rng: inout some RandomNumberGenerating
    ) -> [FoodScore] {
        guard !items.isEmpty else { return [] }
        guard items.count > count else { return items }

        // Softmax-like weighting
        let maxScore = items.map(\.score).max() ?? 0
        let weights = items.map { exp($0.score - maxScore) }

        var results: [FoodScore] = []
        var usedIndices: Set<Int> = []

        for _ in 0..<count {
            let available = weights.enumerated().filter { !usedIndices.contains($0.offset) }
            let totalW = available.reduce(0.0) { $0 + $1.element }
            guard totalW > 0 else { break }

            var r = rng.nextDouble() * totalW
            for (idx, w) in available {
                r -= w
                if r <= 0 {
                    results.append(items[idx])
                    usedIndices.insert(idx)
                    break
                }
            }
        }

        return results
    }

    // MARK: - Helpers

    static func recentFoodIds(from history: [HistoryItem], windowDays: Int) -> Set<String> {
        let cutoff = Date().addingTimeInterval(-Double(windowDays) * 86400)
        return Set(
            history
                .filter { $0.date > cutoff }
                .map { $0.foodId }
        )
    }
}
