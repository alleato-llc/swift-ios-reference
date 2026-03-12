import RecipePlannerCore
import SwiftUI

struct MealPlanWeekView: View {
    let weekDays: [Date]
    let plans: [MealPlan]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(weekDays, id: \.self) { day in
                VStack(spacing: 4) {
                    Text(dayAbbreviation(for: day))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(dayNumber(for: day))
                        .font(.caption)
                        .fontWeight(Calendar.current.isDateInToday(day) ? .bold : .regular)

                    let dayPlans = plans.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
                    Circle()
                        .fill(dayPlans.isEmpty ? Color.clear : Color.accentColor)
                        .frame(width: 6, height: 6)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}
