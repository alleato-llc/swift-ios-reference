import Foundation

public struct NutritionInfo: Sendable, Equatable {
    public let calories: Double
    public let proteinGrams: Double
    public let carbsGrams: Double
    public let fatGrams: Double

    public init(
        calories: Double,
        proteinGrams: Double,
        carbsGrams: Double,
        fatGrams: Double
    ) {
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
    }

    public static let zero = NutritionInfo(
        calories: 0,
        proteinGrams: 0,
        carbsGrams: 0,
        fatGrams: 0
    )

    public static func + (lhs: NutritionInfo, rhs: NutritionInfo) -> NutritionInfo {
        NutritionInfo(
            calories: lhs.calories + rhs.calories,
            proteinGrams: lhs.proteinGrams + rhs.proteinGrams,
            carbsGrams: lhs.carbsGrams + rhs.carbsGrams,
            fatGrams: lhs.fatGrams + rhs.fatGrams
        )
    }
}
