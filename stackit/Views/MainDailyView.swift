//
//  MainDailyView.swift
//  stackit
//
//  Main page: minimalistic UI with date, time, daily progress, and current task (PRD FR-12).
//  NFR-1: Lightweight; NFR-2: Local state ready for offline/sync later.
//

import SwiftUI

/// Main screen showing today's date, time, daily progress, current task, and today's schedule.
struct MainDailyView: View {
    /// Current task suggested by the scheduler. Nil when none or all done.
    var currentTask: TaskItem?
    /// All tasks/events for today, used to build the timeline list.
    var todayTasks: [TaskItem]
    /// Today's progress for the progress indicator.
    var progress: DailyProgress
    /// Navigation callbacks; optional so the view can be used in previews without a container.
    var onOpenSettings: (() -> Void)?
    var onOpenTask: ((TaskItem) -> Void)?
    var onAddTask: (() -> Void)?
    var onCompleteCurrentTask: (() -> Void)?

    init(
        currentTask: TaskItem? = nil,
        todayTasks: [TaskItem] = [],
        progress: DailyProgress = .empty,
        onOpenSettings: (() -> Void)? = nil,
        onOpenTask: ((TaskItem) -> Void)? = nil,
        onAddTask: (() -> Void)? = nil,
        onCompleteCurrentTask: (() -> Void)? = nil
    ) {
        self.currentTask = currentTask
        self.todayTasks = todayTasks
        self.progress = progress
        self.onOpenSettings = onOpenSettings
        self.onOpenTask = onOpenTask
        self.onAddTask = onAddTask
        self.onCompleteCurrentTask = onCompleteCurrentTask
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DateTimeHeaderView()
                DailyProgressView(progress: progress)
                CurrentTaskCardView(
                    task: currentTask,
                    onTap: { if let currentTask { onOpenTask?(currentTask) } },
                    onComplete: onCompleteCurrentTask
                )
                TimelineTaskListView(
                    tasks: todayTasks,
                    currentTaskId: currentTask?.id,
                    onSelect: { onOpenTask?($0) }
                )
            }
            .padding()
        }
        .background(Color(.sRGB, red: 0.95, green: 0.95, blue: 0.98, opacity: 1.0))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    onAddTask?()
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    onOpenSettings?()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("With task and progress") {
    MainDailyView(
        currentTask: TaskItem(
            title: "Ship Stackit MVP",
            notes: "Final pass on main screen",
            priority: .high,
            scheduledStart: Date()
        ),
        todayTasks: [
            TaskItem(
                title: "Morning deep work",
                priority: .high,
                scheduledStart: Date().addingTimeInterval(-3600),
                isCompleted: true
            ),
            TaskItem(
                title: "Ship Stackit MVP",
                priority: .high,
                scheduledStart: Date().addingTimeInterval(600)
            ),
            TaskItem(
                title: "Workout",
                priority: .low,
                scheduledStart: Date().addingTimeInterval(3600)
            )
        ],
        progress: DailyProgress(completedCount: 1, totalCount: 3)
    )
}

#Preview("Empty state") {
    MainDailyView(progress: .empty)
}

