//
//  TimelineTaskListView.swift
//  stackit
//
//  Vertical timeline list for today’s tasks/events with a line and dots per item.
//

import SwiftUI

/// Displays today’s tasks as a vertical timeline with a line and dots.
/// Completed items appear at the top; upcoming items towards the bottom.
/// The current task (if any) is visually highlighted.
struct TimelineTaskListView: View {
    let tasks: [TaskItem]
    let currentTaskId: UUID?
    var onSelect: ((TaskItem) -> Void)?

    private var sortedTasks: [TaskItem] {
        tasks.sorted { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted {
                // Completed at the top, upcoming towards the bottom.
                return lhs.isCompleted && !rhs.isCompleted
            }
            let lhsDate = lhs.scheduledStart ?? .distantPast
            let rhsDate = rhs.scheduledStart ?? .distantPast
            return lhsDate < rhsDate
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if sortedTasks.isEmpty {
                ContentUnavailableView(
                    "No tasks for today",
                    systemImage: "calendar.badge.plus",
                    description: Text("Add a task with the + button to get started.")
                )
            } else {
                Text("Today’s schedule")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(sortedTasks.enumerated()), id: \.element.id) { index, task in
                        let isFirst = index == sortedTasks.startIndex
                        let isLast = index == sortedTasks.index(before: sortedTasks.endIndex)
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
                    .fill(Color(.systemGray4))
                    .frame(width: 2)
                    .opacity(isFirst ? 0 : 1)
                Circle()
                    .fill(isCurrent ? Color.accentColor : Color(.systemGray3))
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 2)
                    .opacity(isLast ? 0 : 1)
            }
            .frame(width: 16)

            // Task content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.subheadline.weight(isCurrent ? .semibold : .regular))
                        .foregroundStyle(isCurrent ? Color.primary : Color.primary.opacity(0.9))
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
                            .foregroundStyle(.accentColor)
                    }
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isCurrent ? Color.accentColor.opacity(0.08) : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .contentShape(Rectangle())
            .onTapGesture {
                onTap?()
            }
        }
    }

    private func priorityBackground(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return Color.red.opacity(0.12)
        case .medium: return Color.orange.opacity(0.12)
        case .low: return Color.green.opacity(0.12)
        }
    }

    private func priorityForeground(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

// MARK: - Previews

#Preview {
    ScrollView {
        TimelineTaskListView(
            tasks: [
                TaskItem(
                    title: "Morning deep work",
                    notes: "",
                    priority: .high,
                    scheduledStart: Date().addingTimeInterval(-3600),
                    isCompleted: true
                ),
                TaskItem(
                    title: "Inbox zero",
                    notes: "",
                    priority: .medium,
                    scheduledStart: Date().addingTimeInterval(-1800),
                    isCompleted: true
                ),
                TaskItem(
                    title: "Ship Stackit MVP",
                    notes: "",
                    priority: .high,
                    scheduledStart: Date().addingTimeInterval(600)
                ),
                TaskItem(
                    title: "Workout",
                    notes: "",
                    priority: .low,
                    scheduledStart: Date().addingTimeInterval(3600)
                )
            ],
            currentTaskId: nil,
            onSelect: { _ in }
        )
        .padding()
    }
}

