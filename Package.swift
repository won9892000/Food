// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FoodEngine",
    targets: [
        .target(
            name: "FoodEngine",
            path: "FoodApp/Core",
            exclude: ["Data"],
            sources: [
                "Engine/RecommendationEngine.swift",
                "Engine/FoodScore.swift",
                "Models/Food.swift",
                "Models/HistoryItem.swift",
                "Models/AnswerState.swift"
            ]
        ),
        .testTarget(
            name: "FoodEngineTests",
            dependencies: ["FoodEngine"],
            path: "Tests"
        )
    ]
)
