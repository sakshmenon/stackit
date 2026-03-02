//
//  BurstTimerStatusView.swift
//  stackit
//
//  Shows the active burst-scheduler state inline on the main daily view.
//  Renders nothing when scheduler mode is .off.
//

import SwiftUI

/// Inline card showing burst-scheduler status.
/// Reads BurstScheduler and ScheduleStore from the environment.
struct BurstTimerStatusView: View {
    @EnvironmentObject private var burstScheduler: BurstScheduler
    @EnvironmentObject private var scheduleStore: ScheduleStore

    var body: some View {
        Group {
            if burstScheduler.schedulerMode == .off {
                EmptyView()
            } else if burstScheduler.isRunning {
                runningCard
            } else {
                startCard
            }
        }
    }

    // MARK: - Start prompt (mode selected but not yet running)

    @ViewBuilder private var startCard: some View {
        HStack(spacing: 12) {
            Image(systemName: burstScheduler.schedulerMode.systemImage)
                .font(.title3)
                .foregroundStyle(accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(burstScheduler.schedulerMode.displayName) Scheduling")
                    .font(.subheadline.weight(.semibold))
                Text(burstScheduler.schedulerMode.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Start") {
                burstScheduler.start(orderedItems: scheduleStore.orderedTodayItems, store: scheduleStore)
            }
            .buttonStyle(.borderedProminent)
            .tint(accentColor)
            .controlSize(.small)
        }
        .padding(14)
        .background(accentColor.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(accentColor.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Running card (preemptive: shows countdown; non-preemptive: shows Done button)

    @ViewBuilder private var runningCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header row
            HStack {
                Image(systemName: burstScheduler.schedulerMode.systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accentColor)
                Text(burstScheduler.schedulerMode.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accentColor)
                Spacer()
                Button("Stop") { burstScheduler.stop() }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
            }

            // Active task title
            if let taskId = burstScheduler.activeTaskId,
               let task = scheduleStore.item(id: taskId) {
                Text(task.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
            }

            // Preemptive: burst countdown bar
            // Non-preemptive: manual "Done" button (no timer)
            if burstScheduler.schedulerMode == .preemptive {
                HStack(spacing: 8) {
                    ProgressView(
                        value: Double(burstScheduler.timeRemainingSeconds),
                        total: Double(burstScheduler.burstTimeMinutes * 60)
                    )
                    .tint(accentColor)
                    .animation(.linear(duration: 1), value: burstScheduler.timeRemainingSeconds)

                    Text(formattedTime(burstScheduler.timeRemainingSeconds))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 44, alignment: .trailing)
                }
            } else {
                Button("Done ✓") {
                    burstScheduler.advance(completed: true, store: scheduleStore)
                }
                .buttonStyle(.borderedProminent)
                .tint(accentColor)
                .controlSize(.small)
            }
        }
        .padding(14)
        .background(accentColor.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(accentColor.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private var accentColor: Color {
        burstScheduler.schedulerMode == .preemptive ? .orange : .purple
    }

    private func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Previews

#Preview("Running") {
    let scheduler = BurstScheduler()
    let store = ScheduleStore(repository: InMemoryScheduleItemRepository())
    return BurstTimerStatusView()
        .environmentObject(scheduler)
        .environmentObject(store)
        .padding()
}
