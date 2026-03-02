//
//  DateTimeHeaderView.swift
//  stackit
//
//  Date header for the main daily view (PRD FR-12).
//  Shows month + day for the selected date; today gets a live "time remaining" countdown.
//

import SwiftUI

struct DateTimeHeaderView: View {
    /// The date to display. Defaults to today.
    let date: Date

    @State private var now = Date()

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    init(date: Date = Date()) {
        self.date = date
    }

    // MARK: - Formatters

    /// "February 25" — locale-aware month + day, no year, no weekday.
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("MMMMd")
        f.timeZone = .current
        return f
    }()

    // MARK: - Helpers

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    /// Hours and minutes remaining until midnight.
    private var timeUntilMidnight: (hours: Int, minutes: Int) {
        let calendar = Calendar.current
        guard let midnight = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else { return (0, 0) }

        let remaining = max(0, Int(midnight.timeIntervalSince(now)))
        return (remaining / 3600, (remaining % 3600) / 60)
    }

    private var countdownText: String {
        let (hours, minutes) = timeUntilMidnight
        if hours > 0 {
            return "\(hours)h \(minutes)m left"
        } else {
            return "\(minutes)m left"
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(Self.dateFormatter.string(from: date))
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            if isToday {
                Text(countdownText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .onReceive(timer) { _ in now = Date() }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { now = Date() }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        DateTimeHeaderView()
        DateTimeHeaderView(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!)
    }
    .padding()
}
