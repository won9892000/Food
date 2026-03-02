import Foundation

enum JSONLoaderError: Error, LocalizedError {
    case fileNotFound(String)
    case dataLoadFailed(String)
    case decodingFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Could not find \(name).json in bundle"
        case .dataLoadFailed(let name):
            return "Could not load \(name).json"
        case .decodingFailed(let name, let error):
            return "Could not decode \(name).json: \(error.localizedDescription)"
        }
    }
}

enum JSONLoader {
    static func load<T: Decodable>(_ filename: String) -> T {
        do {
            return try loadThrowing(filename)
        } catch {
            fatalError("[JSONLoader] \(error.localizedDescription)")
        }
    }

    static func loadThrowing<T: Decodable>(_ filename: String) throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw JSONLoaderError.fileNotFound(filename)
        }
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw JSONLoaderError.dataLoadFailed(filename)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw JSONLoaderError.decodingFailed(filename, error)
        }
    }
}
