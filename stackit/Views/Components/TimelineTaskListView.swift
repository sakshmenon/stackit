//
//  TimelineTaskListView.swift
//  stackit
//
//  Vertical timeline list for a day's tasks/events with a line and dots per item.
//  Task order is determined by the active ScheduleMode in ScheduleStore — this view renders as-is.
//

import SwiftUI

/// Displays a day's tasks as a vertical timeline with a line and dots.
/// The ordering of `tasks` is fully controlled by the caller (via ScheduleStore + TaskScheduler).
/// Completed items are expected at the front of the array (the store guarantees this).
struct TimelineTaskListView: View {
    let tasks: [TaskItem]
    let currentTaskId: UUID?
    var selectedDate: Date = Date()
    var onSelect: ((TaskItem) -> Void)?

    private var headerLabel: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today's schedule"
        }
        let f = DateFormatter()
        f.dateFormat = "EEEE's schedule"
        return f.string(from: selectedDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if tasks.isEmpty {
                ContentUnavailableView(
                    "Nothing scheduled",
                    systemImage: "calendar.badge.plus",
                    description: Text("Tap + to add a task or event.")
                )
            } else {
                Text(headerLabel)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                        let isFirst = index == tasks.startIndex
                        let isLast  = index == tasks.index(before: tasks.endIndex)
                        let isCurrent = task.id == currentTaskId
                        TimelineTaskRowView(
                            task: task,
                            isCurrent: isCurrent,
                            isFirst: isFirst,
                            isLast: isLast,
                            onTap: { onSelect?(task) }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Row

private struct TimelineTaskRowView: View {
    let task: TaskItem
    let isCurrent: Bool
    let isFirst: Bool
    let isLast: Bool
    var onTap: (() -> Void)?

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline rail with dot
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 2)
                    .opacity(isFirst ? 0 : 1)
                Circle()
                    .fill(isCurrent ? Color.accentColor : Color(.tertiaryLabel))
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 2)
                    .opacity(isLast ? 0 : 1)
            }
            .frame(width: 16)

            // Task content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.subheadline.weight(isCurrent ? .semibold : .regular))
                        .foregroundStyle(.primary)
                        .strikethrough(task.isCompleted, pattern: .solid, color: Color.secondary)
                    Spacer()
                    if let start = task.scheduledStart {
                        Text(Self.timeFormatter.string(from: start))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
                HStack(spacing: 8) {
                    Text(task.priority.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(priorityBackground(task.priority))
                        .foregroundStyle(priorityForeground(task.priority))
                        .clipShape(Capsule())
                    if task.isCompleted {
                        Text("Done")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else if isCurrent {
                        Text("Current")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isCurrent ? Color.accentColor.opacity(0.1) : Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .contentShape(Rectangle())
            .onTapGesture { onTap?() }
        }
    }

    private func priorityBackground(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high:   return Color.red.opacity(0.12)
        case .medium: return Color.orange.opacity(0.12)
        case .low:    return Color.green.opacity(0.12)
        }
    }

    private func priorityForeground(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high:   return .red
        case .medium: return .orange
        case .low:    return .green
        }
    }
}

// MARK: - Previews

#Preview {
    ScrollView {
        TimelineTaskListView(
            tasks: [
                TaskItem(title: "Morning deep work", priority: .high,
                         scheduledStart: Date().addingTimeInterval(-3600), isCompleted: true),
                TaskItem(title: "Inbox zero", priority: .medium,
                         scheduledStart: Date().addingTimeInterval(-1800), isCompleted: true),
                TaskItem(title: "Ship Stackit MVP", priority: .high,
                         scheduledStart: Date().addingTimeInterval(600)),
                TaskItem(title: "Workout", priority: .low,
                         scheduledStart: Date().addingTimeInterval(3600))
            ],
            currentTaskId: nil,
            onSelect: { _ in }
        )
        .padding()
    }
}
