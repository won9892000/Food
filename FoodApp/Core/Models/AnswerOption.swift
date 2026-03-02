import Foundation

struct AnswerOption: Codable, Identifiable, Equatable {
    let id: String
    let label: String
    let emoji: String?
    let effects: AnswerEffect
}
