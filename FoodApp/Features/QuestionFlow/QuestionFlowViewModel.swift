import Foundation

class QuestionFlowViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var answers: [String: String] = [:]
    @Published var isFinished = false

    @Published var questions: [Question] = []

    /// Tracks selected option IDs per question index for back-navigation restoration.
    @Published var selectedOptionIds: [Int: Set<String>] = [:]

    /// Direction for card transition animation.
    @Published var transitionDirection: TransitionDirection = .forward

    enum TransitionDirection {
        case forward, backward
    }

    init(mealTime: String) {
        self.answers["meal_time"] = mealTime
    }

    func loadQuestions(_ allQuestions: [Question]) {
        if questions.isEmpty {
            questions = allQuestions.filter { $0.id != "q1" }
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

    var canGoBack: Bool {
        currentIndex > 0
    }

    /// Returns whether a given option is currently selected for the current question.
    func isOptionSelected(_ option: AnswerOption) -> Bool {
        selectedOptionIds[currentIndex]?.contains(option.id) == true
    }

    // MARK: - Single select

    func selectOption(_ option: AnswerOption) {
        // Store selection for restoration
        selectedOptionIds[currentIndex] = [option.id]

        for (key, value) in option.effects.toDictionary() {
            answers[key] = value
        }

        advanceToNext()
    }

    // MARK: - Multi select

    func toggleOption(_ option: AnswerOption) {
        var current = selectedOptionIds[currentIndex] ?? []
        if current.contains(option.id) {
            current.remove(option.id)
        } else {
            current.insert(option.id)
        }
        selectedOptionIds[currentIndex] = current
    }

    func confirmMultiSelection() {
        guard let question = currentQuestion else { return }
        let selected = selectedOptionIds[currentIndex] ?? []

        // Clear previous effects for this question's keys
        for opt in question.options where selected.contains(opt.id) {
            for (key, value) in opt.effects.toDictionary() {
                if let existing = answers[key], !existing.isEmpty {
                    // Append with comma for multi
                    answers[key] = existing + "," + value
                } else {
                    answers[key] = value
                }
            }
        }

        advanceToNext()
    }

    // MARK: - Navigation

    func goBack() {
        guard canGoBack else { return }
        transitionDirection = .backward

        // Remove effects from current question's stored selection before going back
        if let question = currentQuestion {
            removeEffects(for: question)
        }

        currentIndex -= 1

        // Remove effects from the question we're going back to (will be re-applied on re-selection)
        if let prevQuestion = currentQuestion {
            removeEffects(for: prevQuestion)
        }
    }

    private func advanceToNext() {
        transitionDirection = .forward
        currentIndex += 1
        if currentIndex >= questions.count {
            isFinished = true
        }
    }

    private func removeEffects(for question: Question) {
        for option in question.options {
            for key in option.effects.toDictionary().keys {
                answers.removeValue(forKey: key)
            }
        }
    }
}
