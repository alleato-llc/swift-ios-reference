import Foundation
import SwiftData

@Model
public final class Ingredient {
    public var id: UUID = UUID()
    public var name: String = ""
    public var quantity: Double = 0
    public var unit: String = MeasurementUnit.whole.rawValue
    public var createdAt: Date = Date()
    public var modifiedAt: Date = Date()

    @Relationship
    public var recipe: Recipe?

    public var measurementUnit: MeasurementUnit {
        MeasurementUnit(rawValue: unit) ?? .whole
    }

    public var displayQuantity: String {
        if quantity == quantity.rounded() {
            return String(Int(quantity))
        }
        return String(format: "%.1f", quantity)
    }

    public init(
        id: UUID = UUID(),
        name: String,
        quantity: Double,
        unit: MeasurementUnit = .whole,
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit.rawValue
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
