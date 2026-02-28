//
//  MainDailyView.swift
//  stackit
//
//  Main page: date header, week strip, daily progress, current task, timeline (PRD FR-12).
//

import SwiftUI

struct MainDailyView: View {
    var currentTask: TaskItem?
    var todayTasks: [TaskItem]
    var progress: DailyProgress
    var selectedDate: Date
    var onOpenSettings: (() -> Void)?
    var onOpenTask: ((TaskItem) -> Void)?
    var onAddTask: ((ScheduleItemType) -> Void)?
    var onSelectDate: ((Date) -> Void)?
    var onCompleteCurrentTask: (() -> Void)?

    @State private var showAddTypeSheet = false
    @State private var pendingAddType: ScheduleItemType?

    init(
        currentTask: TaskItem? = nil,
        todayTasks: [TaskItem] = [],
        progress: DailyProgress = .empty,
        selectedDate: Date = Date(),
        onOpenSettings: (() -> Void)? = nil,
        onOpenTask: ((TaskItem) -> Void)? = nil,
        onAddTask: ((ScheduleItemType) -> Void)? = nil,
        onSelectDate: ((Date) -> Void)? = nil,
        onCompleteCurrentTask: (() -> Void)? = nil
    ) {
        self.currentTask = currentTask
        self.todayTasks = todayTasks
        self.progress = progress
        self.selectedDate = selectedDate
        self.onOpenSettings = onOpenSettings
        self.onOpenTask = onOpenTask
        self.onAddTask = onAddTask
        self.onSelectDate = onSelectDate
        self.onCompleteCurrentTask = onCompleteCurrentTask
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date header for the selected day
                    DateTimeHeaderView(date: selectedDate)

                    // Week strip — tap a day to view its schedule
                    WeekStripView(selectedDate: selectedDate, onSelectDate: { date in
                        onSelectDate?(date)
                    })

                    DailyProgressView(progress: progress)

                    CurrentTaskCardView(
                        task: currentTask,
                        onTap: { if let currentTask { onOpenTask?(currentTask) } },
                        onComplete: onCompleteCurrentTask
                    )

                    TimelineTaskListView(
                        tasks: todayTasks,
                        currentTaskId: currentTask?.id,
                        selectedDate: selectedDate,
                        onSelect: { onOpenTask?($0) }
                    )
                }
                .padding()
                .padding(.bottom, 96)
            }
            .background(Color(.systemGroupedBackground))

            // Floating action button
            Button {
                showAddTypeSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .frame(width: 60, height: 60)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
            }
            .padding(.bottom, 36)
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .topBarLeading) {
                Button { onOpenSettings?() } label: {
                    Image(systemName: "gearshape")
                }
            }
#endif
        }
        .sheet(isPresented: $showAddTypeSheet, onDismiss: {
            if let type = pendingAddType {
                onAddTask?(type)
                pendingAddType = nil
            }
        }) {
            AddTypePickerSheet { type in
                pendingAddType = type
                showAddTypeSheet = false
            }
        }
    }
}

// MARK: - Add Type Picker Sheet

private struct AddTypePickerSheet: View {
    var onSelect: (ScheduleItemType) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            Text("What would you like to add?")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                typeButton(type: .task, icon: "checkmark.circle.fill", color: .blue)
                typeButton(type: .event, icon: "calendar.circle.fill", color: .orange)
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 32)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.hidden)
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func typeButton(type: ScheduleItemType, icon: String, color: Color) -> some View {
        Button {
            onSelect(type)
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(color)
                Text(type.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("With task and progress") {
    let today = Date()
    MainDailyView(
        currentTask: TaskItem(
            title: "Ship Stackit MVP",
            notes: "Final pass on main screen",
            priority: .high,
            scheduledStart: today
        ),
        todayTasks: [
            TaskItem(title: "Morning deep work", priority: .high,
                     scheduledStart: today.addingTimeInterval(-3600), isCompleted: true),
            TaskItem(title: "Ship Stackit MVP", priority: .high,
                     scheduledStart: today.addingTimeInterval(600)),
            TaskItem(title: "Workout", priority: .low,
                     scheduledStart: today.addingTimeInterval(3600))
        ],
        progress: DailyProgress(completedCount: 1, totalCount: 3),
        selectedDate: today
    )
}

#Preview("Empty state") {
    MainDailyView(selectedDate: Date())
}
