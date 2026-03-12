import Foundation

extension Date {
    public var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    public var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    public var endOfWeek: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? self
    }

    public func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    public func daysFrom(_ other: Date) -> Int {
        Calendar.current.dateComponents([.day], from: other.startOfDay, to: startOfDay).day ?? 0
    }
}
