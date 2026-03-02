import Foundation

struct AnswerOption: Codable, Identifiable {
    var id: String { label }
    let label: String
    let value: String
    let tags: [String: String]
}

struct Question: Codable, Identifiable {
    let id: String
    let text: String
    let emoji: String
    let tag: String
    let multi: Bool
    let options: [AnswerOption]
}
