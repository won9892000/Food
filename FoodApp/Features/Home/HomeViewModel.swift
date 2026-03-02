import Foundation

class HomeViewModel: ObservableObject {
    @Published var showQuestionFlow = false
    @Published var selectedMealTime: String = ""

    func startRecommendation(mealTime: String) {
        selectedMealTime = mealTime
        showQuestionFlow = true
    }
}
