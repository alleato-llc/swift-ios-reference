import Foundation

public enum RecipeCategory: String, CaseIterable, Sendable {
    case breakfast
    case lunch
    case dinner
    case snack
    case dessert

    public var displayName: String {
        rawValue.capitalized
    }
}
