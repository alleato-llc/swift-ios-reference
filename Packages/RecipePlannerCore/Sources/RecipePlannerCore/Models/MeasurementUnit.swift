import Foundation

public enum MeasurementUnit: String, CaseIterable, Sendable {
    case cups
    case tablespoons
    case teaspoons
    case ounces
    case grams
    case pieces
    case whole

    public var displayName: String {
        rawValue.capitalized
    }

    public var abbreviation: String {
        switch self {
        case .cups: "cup"
        case .tablespoons: "tbsp"
        case .teaspoons: "tsp"
        case .ounces: "oz"
        case .grams: "g"
        case .pieces: "pcs"
        case .whole: ""
        }
    }
}
