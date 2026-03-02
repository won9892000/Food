import Foundation

class UserProfile: ObservableObject {
    @Published var avoidIngredients: Set<String> {
        didSet { save() }
    }
    @Published var avoidDuplicates: Bool {
        didSet { save() }
    }

    private let avoidKey = "avoidIngredients"
    private let duplicateKey = "avoidDuplicates"

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "avoidIngredients") ?? []
        self.avoidIngredients = Set(saved)
        self.avoidDuplicates = UserDefaults.standard.bool(forKey: "avoidDuplicates")
    }

    private func save() {
        UserDefaults.standard.set(Array(avoidIngredients), forKey: avoidKey)
        UserDefaults.standard.set(avoidDuplicates, forKey: duplicateKey)
    }

    static let allIngredients: [(id: String, label: String)] = [
        ("seafood", "해산물 🦐"),
        ("dairy", "유제품 🥛"),
        ("meat", "고기 🥩"),
        ("gluten", "밀가루 🍞")
    ]
}
