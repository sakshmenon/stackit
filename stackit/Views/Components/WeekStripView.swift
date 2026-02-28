//
//  WeekStripView.swift
//  stackit
//
//  Horizontal Sunday–Saturday week strip for the main daily view.
//  Tapping a day calls onSelectDate; the selected day is highlighted.
//

import SwiftUI

struct WeekStripView: View {
    let selectedDate: Date
    let onSelectDate: (Date) -> Void

    /// The 7 calendar days of the week containing selectedDate (Sun → Sat).
    private var weekDays: [Date] {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: selectedDate)
        // weekday: 1=Sun … 7=Sat; offset back to Sunday
        let offset = cal.component(.weekday, from: startOfDay) - 1
        guard let sunday = cal.date(byAdding: .day, value: -offset, to: startOfDay) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: sunday) }
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(weekDays, id: \.self) { day in
                DayCell(
                    date: day,
                    isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
                    isToday: Calendar.current.isDateInToday(day),
                    onTap: { onSelectDate(day) }
                )
            }
        }
    }
}

// MARK: - Day cell

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let onTap: () -> Void

    private static let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEEE"   // single-letter weekday: S M T W T F S
        return f
    }()
    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                Text(Self.weekdayFormatter.string(from: date))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .secondary)

                ZStack {
                    Circle()
                        .fill(isSelected ? Color.accentColor : Color.clear)
                        .frame(width: 30, height: 30)

                    Text(Self.dayFormatter.string(from: date))
                        .font(.subheadline.weight(isSelected || isToday ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected ? .white :
                            isToday    ? Color.accentColor :
                                         Color.primary
                        )
                }

                // Dot indicator for today (only when not selected)
                Circle()
                    .fill(isToday && !isSelected ? Color.accentColor : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    WeekStripView(selectedDate: Date(), onSelectDate: { _ in })
        .padding()
}
