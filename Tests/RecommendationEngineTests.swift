import XCTest
@testable import FoodEngine

// MARK: - Test Helpers

/// Fixed RNG that returns values from a predefined sequence (cycles).
struct FixedRandom: RandomNumberGenerating {
    private var values: [Double]
    private var index: Int = 0

    init(values: [Double]) {
        self.values = values
    }

    mutating func nextDouble() -> Double {
        let value = values[index % values.count]
        index += 1
        return value
    }
}

/// Helper to create Food for testing.
func makeFood(
    id: String = "f1",
    name: String = "Test Food",
    cuisine: String = "한식",
    mealTime: [String] = ["lunch", "dinner"],
    carbBase: String = "rice",
    soup: Bool = false,
    spicy: Int = 1,
    greasy: Int = 1,
    health: String = "balanced",
    moodFit: [String] = [],
    avoidTags: [String] = [],
    isPopular: Bool = false
) -> Food {
    return Food(
        id: id, name: name, cuisine: cuisine,
        mealTime: mealTime, carbBase: carbBase, soup: soup,
        spicy: spicy, greasy: greasy, health: health,
        moodFit: moodFit, avoidTags: avoidTags, isPopular: isPopular
    )
}

// MARK: - Tests

final class RecommendationEngineTests: XCTestCase {

    // MARK: 1. Hard Filter - avoid_tags

    func testHardFilter_avoidTags_excludesMatching() {
        let foods = [
            makeFood(id: "f1", name: "Seafood Soup", avoidTags: ["seafood"]),
            makeFood(id: "f2", name: "Chicken Rice", avoidTags: ["meat"]),
            makeFood(id: "f3", name: "Veggie Salad", avoidTags: []),
        ]
        let answers = AnswerState(
            mealTime: "lunch", mood: "happy", spicy: 1,
            soup: nil, carbBase: "rice", health: "balanced",
            greasy: 1, avoidTags: ["seafood"]
        )

        let result = RecommendationEngine.hardFilter(foods: foods, answers: answers)

        XCTAssertEqual(result.count, 2)
        XCTAssertFalse(result.contains(where: { $0.id == "f1" }), "Seafood food should be excluded")
        XCTAssertTrue(result.contains(where: { $0.id == "f2" }))
        XCTAssertTrue(result.contains(where: { $0.id == "f3" }))
    }

    // MARK: 2. Hard Filter - mealTime

    func testHardFilter_mealTime_excludesMismatch() {
        let foods = [
            makeFood(id: "f1", name: "Lunch Only", mealTime: ["lunch"]),
            makeFood(id: "f2", name: "Dinner Only", mealTime: ["dinner"]),
            makeFood(id: "f3", name: "Both", mealTime: ["lunch", "dinner"]),
        ]
        let answers = AnswerState(
            mealTime: "dinner", mood: "", spicy: 0,
            soup: nil, carbBase: "any", health: "balanced",
            greasy: 1, avoidTags: []
        )

        let result = RecommendationEngine.hardFilter(foods: foods, answers: answers)

        XCTAssertEqual(result.count, 2)
        XCTAssertFalse(result.contains(where: { $0.id == "f1" }), "Lunch-only should be excluded for dinner")
        XCTAssertTrue(result.contains(where: { $0.id == "f2" }))
        XCTAssertTrue(result.contains(where: { $0.id == "f3" }))
    }

    // MARK: 3. Scoring - spicy match gives higher score

    func testScoring_spicyMatch_higherScore() {
        let foodMatch = makeFood(id: "f1", spicy: 2)
        let foodMismatch = makeFood(id: "f2", spicy: 0)
        let answers = AnswerState(
            mealTime: "lunch", mood: "", spicy: 2,
            soup: nil, carbBase: "any", health: "balanced",
            greasy: 1, avoidTags: []
        )
        let settings = RecommendationSettings()

        let scoreMatch = RecommendationEngine.scoreSingle(
            food: foodMatch, answers: answers, recentIds: [], settings: settings
        )
        let scoreMismatch = RecommendationEngine.scoreSingle(
            food: foodMismatch, answers: answers, recentIds: [], settings: settings
        )

        XCTAssertGreaterThan(scoreMatch.score, scoreMismatch.score,
            "Food with matching spicy level should score higher")
    }

    // MARK: 4. Scoring - soup match adds score

    func testScoring_soupMatch_addsScore() {
        let soupFood = makeFood(id: "f1", soup: true)
        let noSoupFood = makeFood(id: "f2", soup: false)
        let answers = AnswerState(
            mealTime: "lunch", mood: "", spicy: 1,
            soup: true, carbBase: "any", health: "balanced",
            greasy: 1, avoidTags: []
        )
        let settings = RecommendationSettings()

        let soupScore = RecommendationEngine.scoreSingle(
            food: soupFood, answers: answers, recentIds: [], settings: settings
        )
        let noSoupScore = RecommendationEngine.scoreSingle(
            food: noSoupFood, answers: answers, recentIds: [], settings: settings
        )

        XCTAssertGreaterThan(soupScore.score, noSoupScore.score,
            "Soup food should score higher when user wants soup")
    }

    // MARK: 5. Recent Avoidance - penalty applied

    func testScoring_recentAvoidance_penaltyApplied() {
        let food = makeFood(id: "f1")
        let answers = AnswerState(
            mealTime: "lunch", mood: "", spicy: 1,
            soup: nil, carbBase: "any", health: "balanced",
            greasy: 1, avoidTags: []
        )
        let settingsOn = RecommendationSettings(avoidRecent: true, avoidWindowDays: 3)
        let settingsOff = RecommendationSettings(avoidRecent: false, avoidWindowDays: 3)

        let scoreWithPenalty = RecommendationEngine.scoreSingle(
            food: food, answers: answers, recentIds: ["f1"], settings: settingsOn
        )
        let scoreWithoutPenalty = RecommendationEngine.scoreSingle(
            food: food, answers: answers, recentIds: [], settings: settingsOff
        )

        XCTAssertEqual(scoreWithPenalty.score, scoreWithoutPenalty.score - 5.0, accuracy: 0.01,
            "Recent food should get -5.0 penalty when avoidRecent is on")
    }

    // MARK: 6. Weighted Random - deterministic with fixed RNG

    func testWeightedRandomPick_deterministicWithFixedRNG() {
        let items: [FoodScore] = (0..<5).map { i in
            FoodScore(
                food: makeFood(id: "f\(i)", name: "Food \(i)"),
                score: Double(5 - i),
                reasonComponents: ["test"]
            )
        }

        var rng1: FixedRandom = FixedRandom(values: [0.1, 0.2, 0.3])
        var rng2: FixedRandom = FixedRandom(values: [0.1, 0.2, 0.3])

        let pick1 = RecommendationEngine.weightedRandomPick(items, count: 3, rng: &rng1)
        let pick2 = RecommendationEngine.weightedRandomPick(items, count: 3, rng: &rng2)

        XCTAssertEqual(pick1.count, 3)
        XCTAssertEqual(pick2.count, 3)
        // Same RNG values should produce same picks
        for i in 0..<3 {
            XCTAssertEqual(pick1[i].food.id, pick2[i].food.id,
                "Same RNG should produce same food selection at index \(i)")
        }
    }

    // MARK: 7. Weighted Random - no duplicates

    func testWeightedRandomPick_noDuplicates() {
        let items: [FoodScore] = (0..<5).map { i in
            FoodScore(
                food: makeFood(id: "f\(i)", name: "Food \(i)"),
                score: Double(5 - i),
                reasonComponents: ["test"]
            )
        }

        var rng: FixedRandom = FixedRandom(values: [0.0, 0.0, 0.0]) // Always pick first available

        let picked = RecommendationEngine.weightedRandomPick(items, count: 3, rng: &rng)

        let ids = picked.map { $0.food.id }
        XCTAssertEqual(Set(ids).count, ids.count, "All picked foods should be unique")
    }

    // MARK: 8. Full Recommend - returns 3 results

    func testRecommend_returns3Results() {
        let foods = (0..<15).map { i in
            makeFood(
                id: "f\(i)", name: "Food \(i)",
                mealTime: ["lunch"], spicy: i % 4,
                health: "balanced"
            )
        }
        let answers = AnswerState(
            mealTime: "lunch", mood: "", spicy: 1,
            soup: nil, carbBase: "any", health: "balanced",
            greasy: 1, avoidTags: []
        )
        let settings = RecommendationSettings()
        var rng: FixedRandom = FixedRandom(values: [0.3, 0.5, 0.7])

        let results = RecommendationEngine.recommend(
            foods: foods, answers: answers,
            history: [], settings: settings, rng: &rng
        )

        XCTAssertEqual(results.count, 3, "Should return exactly 3 recommendations")
    }

    // MARK: 9. Reason Components - at least 2

    func testReasonComponents_atLeast2() {
        let food = makeFood(id: "f1", soup: true, spicy: 2, health: "light", moodFit: ["stress"])
        let answers = AnswerState(
            mealTime: "lunch", mood: "stress", spicy: 2,
            soup: true, carbBase: "rice", health: "light",
            greasy: 1, avoidTags: []
        )
        let settings = RecommendationSettings()

        let scored = RecommendationEngine.scoreSingle(
            food: food, answers: answers, recentIds: [], settings: settings
        )

        XCTAssertGreaterThanOrEqual(scored.reasonComponents.count, 2,
            "Reason should have at least 2 components")
        XCTAssertFalse(scored.reason.isEmpty, "Reason string should not be empty")
    }

    // MARK: 10. Scoring - carbBase match

    func testScoring_carbBaseMatch_higherScore() {
        let riceFood = makeFood(id: "f1", carbBase: "rice")
        let noodleFood = makeFood(id: "f2", carbBase: "noodle")
        let answers = AnswerState(
            mealTime: "lunch", mood: "", spicy: 1,
            soup: nil, carbBase: "rice", health: "balanced",
            greasy: 1, avoidTags: []
        )
        let settings = RecommendationSettings()

        let riceScore = RecommendationEngine.scoreSingle(
            food: riceFood, answers: answers, recentIds: [], settings: settings
        )
        let noodleScore = RecommendationEngine.scoreSingle(
            food: noodleFood, answers: answers, recentIds: [], settings: settings
        )

        XCTAssertGreaterThan(riceScore.score, noodleScore.score,
            "Rice food should score higher when user wants rice")
    }
}
