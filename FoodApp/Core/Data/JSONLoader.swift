import Foundation

enum JSONLoader {
    static func load<T: Decodable>(_ filename: String) -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            fatalError("Could not find \(filename).json in bundle")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(filename).json")
        }
        guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            fatalError("Could not decode \(filename).json")
        }
        return decoded
    }
}
