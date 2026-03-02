//
//  MainDailyView.swift
//  Dispatch
//
//  Main page: date header, week strip, daily progress, current task, timeline (PRD FR-12).
//

import SwiftUI

struct MainDailyView: View {
    var currentTask: TaskItem?
    var todayTasks: [TaskItem]
    var progress: DailyProgress
    var selectedDate: Date
    var scheduleMode: ScheduleMode
    var onOpenSettings: (() -> Void)?
    var onOpenTask: ((TaskItem) -> Void)?
    var onAddTask: ((ScheduleItemType) -> Void)?
    var onSelectDate: ((Date) -> Void)?
    var onCompleteCurrentTask: (() -> Void)?
    var onChangeMode: ((ScheduleMode) -> Void)?

    @State private var showAddTypeSheet = false
    @State private var pendingAddType: ScheduleItemType?
    /// Drives the staggered enter animations; set once in onAppear.
    @State private var appeared = false

    init(
        currentTask: TaskItem? = nil,
        todayTasks: [TaskItem] = [],
        progress: DailyProgress = .empty,
        selectedDate: Date = Date(),
        scheduleMode: ScheduleMode = .priority,
        onOpenSettings: (() -> Void)? = nil,
        onOpenTask: ((TaskItem) -> Void)? = nil,
        onAddTask: ((ScheduleItemType) -> Void)? = nil,
        onSelectDate: ((Date) -> Void)? = nil,
        onCompleteCurrentTask: (() -> Void)? = nil,
        onChangeMode: ((ScheduleMode) -> Void)? = nil
    ) {
        self.currentTask = currentTask
        self.todayTasks = todayTasks
        self.progress = progress
        self.selectedDate = selectedDate
        self.scheduleMode = scheduleMode
        self.onOpenSettings = onOpenSettings
        self.onOpenTask = onOpenTask
        self.onAddTask = onAddTask
        self.onSelectDate = onSelectDate
        self.onCompleteCurrentTask = onCompleteCurrentTask
        self.onChangeMode = onChangeMode
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date header — slides in from the left
                    DateTimeHeaderView(date: selectedDate)
                        .offset(x: appeared ? 0 : -48)
                        .opacity(appeared ? 1 : 0)
                        .animation(enter(delay: 0.05), value: appeared)

                    // Week strip — slides in from the right
                    WeekStripView(selectedDate: selectedDate, onSelectDate: { date in
                        onSelectDate?(date)
                    })
                    .offset(x: appeared ? 0 : 48)
                    .opacity(appeared ? 1 : 0)
                    .animation(enter(delay: 0.15), value: appeared)

                    // Progress bar — slides in from the left
                    DailyProgressView(progress: progress)
                        .offset(x: appeared ? 0 : -48)
                        .opacity(appeared ? 1 : 0)
                        .animation(enter(delay: 0.25), value: appeared)

                    // Current task card — slides up from below
                    CurrentTaskCardView(
                        task: currentTask,
                        onTap: { if let currentTask { onOpenTask?(currentTask) } },
                        onComplete: onCompleteCurrentTask
                    )
                    .offset(y: appeared ? 0 : 40)
                    .opacity(appeared ? 1 : 0)
                    .animation(enter(delay: 0.35), value: appeared)

                    // Queue-mode picker — slides in from the right
                    ScheduleModePickerView(selectedMode: scheduleMode) { newMode in
                        onChangeMode?(newMode)
                    }
                    .offset(x: appeared ? 0 : 48)
                    .opacity(appeared ? 1 : 0)
                    .animation(enter(delay: 0.45), value: appeared)

                    // Task list — slides up from below
                    TimelineTaskListView(
                        tasks: todayTasks,
                        currentTaskId: currentTask?.id,
                        selectedDate: selectedDate,
                        onSelect: { onOpenTask?($0) }
                    )
                    .offset(y: appeared ? 0 : 50)
                    .opacity(appeared ? 1 : 0)
                    .animation(enter(delay: 0.55), value: appeared)
                }
                .padding()
                .padding(.bottom, 96)
            }
            .background(Color(.systemGroupedBackground))

            // FAB — scales up from centre
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
            .scaleEffect(appeared ? 1 : 0.2)
            .opacity(appeared ? 1 : 0)
            .animation(enter(delay: 0.65), value: appeared)
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
        .onAppear { appeared = true }
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
    }   // end of body

    /// Shared spring animation for all enter transitions. Each component passes its own delay.
    private func enter(delay: Double) -> Animation {
        .spring(response: 0.52, dampingFraction: 0.82).delay(delay)
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
                typeButton(type: .task, icon: "checkmark.circle.fill", color: .green)
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
    MainDailyView(
        currentTask: TaskItem(
            title: "Ship Stackit MVP",
            notes: "Final pass on main screen",
            priority: .high,
            scheduledStart: Date()
        ),
        todayTasks: [
            TaskItem(title: "Morning deep work", priority: .high,
                     scheduledStart: Date().addingTimeInterval(-3600), isCompleted: true),
            TaskItem(title: "Ship Stackit MVP", priority: .high,
                     scheduledStart: Date().addingTimeInterval(600)),
            TaskItem(title: "Workout", priority: .low,
                     scheduledStart: Date().addingTimeInterval(3600))
        ],
        progress: DailyProgress(completedCount: 1, totalCount: 3),
        selectedDate: Date(),
        scheduleMode: .priority
    )
}

#Preview("Empty state") {
    MainDailyView(selectedDate: Date())
}
