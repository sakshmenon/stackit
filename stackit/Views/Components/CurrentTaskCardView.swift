//
//  CurrentTaskCardView.swift
//  stackit
//
//  Displays basic info about the current/next task (PRD FR-12 minimalistic daily view).
//

import SwiftUI

/// Card showing the task at hand: title, priority, and optional time.
struct CurrentTaskCardView: View {
    let task: TaskItem?
    /// Called when the user taps the card (only when `task` is non-nil).
    var onTap: (() -> Void)?

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    var body: some View {
        Group {
            if let task = task {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Now")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(task.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    HStack(spacing: 12) {
                        Label(task.priority.displayName, systemImage: "flag.fill")
                            .font(.caption)
                            .foregroundStyle(priorityColor(task.priority))
                        if let start = task.scheduledStart {
                            Label(CurrentTaskCardView.timeFormatter.string(from: start), systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap?()
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    Text("No task right now")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

#Preview("With task") {
    CurrentTaskCardView(
        task: TaskItem(
            title: "Review PRD",
            priority: .high,
            scheduledStart: Date()
        ),
        onTap: nil
    )
    .padding()
}

#Preview("Empty") {
    CurrentTaskCardView(task: nil)
        .padding()
}
