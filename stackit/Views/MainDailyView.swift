//
//  MainDailyView.swift
//  stackit
//
//  Main page: minimalistic UI with date, time, daily progress, and current task (PRD FR-12).
//  NFR-1: Lightweight; NFR-2: Local state ready for offline/sync later.
//

import SwiftUI

/// Main screen showing today's date, time, daily progress, and the task at hand.
struct MainDailyView: View {
    /// Current task suggested by the scheduler. Nil when none or all done.
    var currentTask: TaskItem?
    /// Today's progress for the progress indicator.
    var progress: DailyProgress

    init(currentTask: TaskItem? = nil, progress: DailyProgress = .empty) {
        self.currentTask = currentTask
        self.progress = progress
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DateTimeHeaderView()
                DailyProgressView(progress: progress)
                CurrentTaskCardView(task: currentTask)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
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
        progress: DailyProgress(completedCount: 3, totalCount: 8)
    )
}

#Preview("Empty state") {
    MainDailyView(progress: .empty)
}
