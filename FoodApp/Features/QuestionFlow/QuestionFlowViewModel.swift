import Foundation

class QuestionFlowViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var answers: [String: String] = [:]
    @Published var isFinished = false

    @Published var questions: [Question] = []

    init(questions: [Question] = [], mealTime: String) {
        self.questions = questions.filter { $0.tag != "meal_time" }
        self.answers["meal_time"] = mealTime
    }

    func loadQuestions(_ allQuestions: [Question]) {
        if questions.isEmpty {
            questions = allQuestions.filter { $0.tag != "meal_time" }
        }
    }

    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 1.0 }
        return Double(currentIndex + 1) / Double(questions.count)
    }

    var progressText: String {
        "\(currentIndex + 1) / \(questions.count)"
    }

    func selectOption(_ option: AnswerOption) {
        for (key, value) in option.tags {
            answers[key] = value
        }

        currentIndex += 1
        if currentIndex >= questions.count {
            isFinished = true
        }
    }
}
