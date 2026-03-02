import Foundation

enum QuestionType: String, Codable {
    case single
    case multi
}

struct Question: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let type: QuestionType
    let options: [AnswerOption]
}
