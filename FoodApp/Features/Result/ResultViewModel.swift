import Foundation

class ResultViewModel: ObservableObject {
    @Published var results: [RecommendResult] = []
    @Published var savedFood: Food?

    let answers: [String: String]
    let allFoods: [Food]
    private var excludeIds: Set<String> = []

    init(answers: [String: String], foods: [Food]) {
        self.answers = answers
        self.allFoods = foods
    }

    func generateResults(
        avoidIngredients: Set<String>,
        recentIds: Set<String>,
        avoidDuplicates: Bool
    ) {
        results = RecommendationEngine.recommend(
            answers: answers,
            foods: allFoods,
            excludeIds: excludeIds,
            avoidIngredients: avoidIngredients,
            recentIds: recentIds,
            avoidDuplicates: avoidDuplicates
        )
    }

    func retryExcludingCurrent(
        avoidIngredients: Set<String>,
        recentIds: Set<String>,
        avoidDuplicates: Bool
    ) {
        for r in results {
            excludeIds.insert(r.food.id)
        }
        generateResults(
            avoidIngredients: avoidIngredients,
            recentIds: recentIds,
            avoidDuplicates: avoidDuplicates
        )
    }

    func saveChoice(_ food: Food, repository: FoodRepository) {
        repository.saveChoice(food)
        savedFood = food
    }
}
