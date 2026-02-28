//
//  DateTimeHeaderView.swift
//  stackit
//
//  Minimalistic date display for the main daily view (PRD FR-12).
//  Shows the currently selected date; today gets the current time appended.
//

import SwiftUI

struct DateTimeHeaderView: View {
    /// The date to display. Defaults to today.
    let date: Date

    @State private var now = Date()

    init(date: Date = Date()) {
        self.date = date
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeZone = .current
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.timeZone = .current
        return f
    }()

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(Self.dateFormatter.string(from: date))
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            if isToday {
                Text(Self.timeFormatter.string(from: now))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
                        now = Date()
                    }
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
