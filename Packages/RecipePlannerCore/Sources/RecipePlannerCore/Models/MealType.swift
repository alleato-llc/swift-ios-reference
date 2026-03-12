import Foundation

public enum MealType: String, CaseIterable, Sendable {
    case breakfast
    case lunch
    case dinner
    case snack

    public var displayName: String {
        rawValue.capitalized
    }
}
