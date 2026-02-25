//
//  DateTimeHeaderView.swift
//  stackit
//
//  Minimalistic date and time display for the main daily view (PRD FR-12).
//

import SwiftUI

/// Displays current date and time with a clean, low-distraction layout.
struct DateTimeHeaderView: View {
    @State private var now = Date()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeZone = .current
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(DateTimeHeaderView.dateFormatter.string(from: now))
                .font(.title2.weight(.medium))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            now = Date()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            now = Date()
        }
    }
}

#Preview {
    DateTimeHeaderView()
        .padding()
}
