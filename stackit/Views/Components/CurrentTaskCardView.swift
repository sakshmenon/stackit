//
//  CurrentTaskCardView.swift
//  Dispatch
//
//  Displays the current task plus inline scheduler controls (PRD FR-12).
//  Merges the former BurstTimerStatusView to keep the UI compact.
//

import SwiftUI

/// Card showing the active task together with burst-scheduler controls.
/// When no task exists a placeholder is shown instead.
struct CurrentTaskCardView: View {
    let task: TaskItem?
    /// Called when the user taps the card body (only when `task` is non-nil).
    var onTap: (() -> Void)?
    /// Called when the user taps Complete outside of scheduler mode.
    var onComplete: (() -> Void)?

    @EnvironmentObject private var burstScheduler: BurstScheduler
    @EnvironmentObject private var scheduleStore: ScheduleStore

    // MARK: - Body

    var body: some View {
        Group {
            if let task {
                taskCard(task)
            } else {
                emptyCard
            }
        }
    }

    // MARK: - Task card

    @ViewBuilder
    private func taskCard(_ task: TaskItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header row: "Now" label + mode badge + Stop/Complete action
            HStack(spacing: 8) {
                Text("Now")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                if burstScheduler.isRunning {
                    Label(burstScheduler.schedulerMode.displayName,
                          systemImage: burstScheduler.schedulerMode.systemImage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(schedulerColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(schedulerColor.opacity(0.12))
                        .clipShape(Capsule())
                }

                Spacer()

                if burstScheduler.isRunning {
                    Button("Stop") { burstScheduler.stop() }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .buttonStyle(.plain)
                } else if !task.isCompleted, onComplete != nil {
                    Button {
                        onComplete?()
                    } label: {
                        Text("Complete")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .controlSize(.small)
                }
            }

            // Task title
            Text(task.title)
                .font(.headline)
                .foregroundStyle(.primary)

            // Metadata: priority + scheduled time
            HStack(spacing: 12) {
                Label(task.priority.displayName, systemImage: "flag.fill")
                    .font(.caption)
                    .foregroundStyle(priorityColor(task.priority))

                if let start = task.scheduledStart {
                    Label(Self.timeFormatter.string(from: start), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Optional notes
            if !task.notes.isEmpty {
                Text(task.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .padding(.vertical, 2)

            // Scheduler section — either running controls or a compact start prompt
            if burstScheduler.isRunning {
                schedulerRunningRow
            } else {
                schedulerStartRow
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }

    // MARK: - Scheduler: running state

    /// Preemptive → countdown progress bar.
    /// Non-preemptive → manual Done button.
    @ViewBuilder
    private var schedulerRunningRow: some View {
        if burstScheduler.schedulerMode == .preemptive {
            // TimelineView redraws at display refresh rate (≤60/120 fps)
            // so the bar moves continuously rather than jumping in 1-second steps.
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { context in
                let total = Double(burstScheduler.burstTimeMinutes * 60)
                let remaining: Double = {
                    if let end = burstScheduler.countdownEndDate {
                        return max(0, end.timeIntervalSince(context.date))
                    }
                    return Double(burstScheduler.timeRemainingSeconds)
                }()
                HStack(spacing: 8) {
                    ProgressView(value: remaining, total: total)
                        .tint(schedulerColor)

                    Text(formattedTime(Int(ceil(remaining))))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 44, alignment: .trailing)
                }
            }
        } else {
            HStack {
                Text(burstScheduler.schedulerMode.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Done ✓") {
                    burstScheduler.advance(completed: true, store: scheduleStore)
                }
                .buttonStyle(.borderedProminent)
                .tint(schedulerColor)
                .controlSize(.small)
            }
        }
    }

    // MARK: - Scheduler: idle start prompt

    @ViewBuilder
    private var schedulerStartRow: some View {
        HStack(spacing: 8) {
            Image(systemName: burstScheduler.schedulerMode.systemImage)
                .font(.caption)
                .foregroundStyle(schedulerColor)
            Text(burstScheduler.schedulerMode.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Start") {
                burstScheduler.start(
                    orderedItems: scheduleStore.orderedTodayItems,
                    store: scheduleStore
                )
            }
            .buttonStyle(.borderedProminent)
            .tint(schedulerColor)
            .controlSize(.small)
        }
    }

    // MARK: - Empty state

    @ViewBuilder
    private var emptyCard: some View {
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
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    /// Accent colour for scheduler controls.
    /// Preemptive uses orange (urgency); non-preemptive uses the app accent (green).
    private var schedulerColor: Color {
        burstScheduler.schedulerMode == .preemptive ? .orange : .accentColor
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .high:   return .red
        case .medium: return .orange
        case .low:    return .accentColor
        }
    }

    private func formattedTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Previews

#Preview("With task — idle") {
    CurrentTaskCardView(
        task: TaskItem(title: "Review PRD", priority: .high, scheduledStart: Date()),
        onTap: nil,
        onComplete: {}
    )
    .environmentObject(BurstScheduler())
    .environmentObject(ScheduleStore(repository: InMemoryScheduleItemRepository()))
    .padding()
}

#Preview("Empty") {
    CurrentTaskCardView(task: nil)
        .environmentObject(BurstScheduler())
        .environmentObject(ScheduleStore(repository: InMemoryScheduleItemRepository()))
        .padding()
}
