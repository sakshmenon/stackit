//
//  DemoCoordinator.swift
//  Dispatch
//
//  Timed demo script: seeds tasks, cycles queue modes, runs both scheduler types,
//  then fires confetti when all tasks are done.
//

import SwiftUI

// MARK: - Demo Coordinator

@MainActor
final class DemoCoordinator: ObservableObject {

    @Published private(set) var isRunning = false
    @Published var showConfetti = false
    /// Overlay annotation shown during the demo (e.g. "Switching to FIFO mode…")
    @Published private(set) var caption: String = ""

    private weak var store: ScheduleStore?
    private weak var scheduler: BurstScheduler?
    private var demoTask: Task<Void, Never>?

    // MARK: - Entry points

    func start(store: ScheduleStore, scheduler: BurstScheduler) {
        stop()
        self.store = store
        self.scheduler = scheduler
        isRunning = true
        showConfetti = false
        caption = ""
        seedTasks()
        demoTask = Task { await runScript() }
    }

    func stop() {
        demoTask?.cancel()
        demoTask = nil
        isRunning = false
        showConfetti = false
        caption = ""
        scheduler?.stop()
    }

    // MARK: - Task seeding

    /// Populates the in-memory store with 6 varied tasks for today.
    private func seedTasks() {
        guard let store else { return }
        let today = Calendar.current.startOfDay(for: Date())
        // createdAt offsets drive FIFO/LIFO ordering (oldest → high priority context)
        let tasks: [ScheduleItem] = [
            .init(title: "Deep focus: API design",     priority: .high,
                  scheduleDate: today,
                  scheduledStart: today.addingTimeInterval(3_600),
                  createdAt: today.addingTimeInterval(-7_200)),
            .init(title: "Review pull requests",       priority: .high,
                  scheduleDate: today,
                  scheduledStart: today.addingTimeInterval(7_200),
                  createdAt: today.addingTimeInterval(-5_400)),
            .init(title: "Write release notes",        priority: .medium,
                  scheduleDate: today,
                  createdAt: today.addingTimeInterval(-3_600)),
            .init(title: "Update project timeline",    priority: .medium,
                  scheduleDate: today,
                  createdAt: today.addingTimeInterval(-1_800)),
            .init(title: "Send team standup",          priority: .low,
                  scheduleDate: today,
                  createdAt: today.addingTimeInterval(-900)),
            .init(title: "Inbox zero",                 priority: .low,
                  scheduleDate: today,
                  createdAt: today.addingTimeInterval(-300)),
        ]
        tasks.forEach { store.add($0) }
    }

    // MARK: - Demo script

    private func runScript() async {
        guard let store, let scheduler else { return }

        // ── 1. Queue mode showcase ──────────────────────────────────────────
        await pause(2.5)

        await setMode(.reversePriority, label: "Ramp up — low priority first", store: store)
        await pause(1.8)

        await setMode(.fifo, label: "FIFO — oldest task first", store: store)
        await pause(1.8)

        await setMode(.lifo, label: "LIFO — newest task first", store: store)
        await pause(1.8)

        await setMode(.shuffle, label: "Shuffle — random order", store: store)
        await pause(1.8)

        await setMode(.priority, label: "Priority — high priority first", store: store)
        await pause(2.0)

        // ── 2. Non-preemptive scheduler ─────────────────────────────────────
        showCaption("Non-Preemptive: work until you're done")
        scheduler.schedulerMode = .nonPreemptive
        await pause(1.2)

        scheduler.start(orderedItems: store.orderedTodayItems, store: store)
        await pause(3.0)

        // Complete task 1 via Done ✓
        showCaption("Done ✓  —  task 1 complete")
        scheduler.advance(completed: true, store: store)
        await pause(3.0)

        // Complete task 2 via Done ✓
        showCaption("Done ✓  —  task 2 complete")
        scheduler.advance(completed: true, store: store)
        await pause(2.5)

        scheduler.stop()
        await pause(1.5)

        // ── 3. Preemptive scheduler ─────────────────────────────────────────
        showCaption("Preemptive: burst timer — let it run out")
        scheduler.schedulerMode = .preemptive
        scheduler.burstTimeMinutes = 1    // 1-minute burst so the timer visibly counts down
        await pause(1.2)

        scheduler.start(orderedItems: store.orderedTodayItems, store: store)

        // Let the burst timer expire naturally so the user sees the task pushed back
        await waitForBurstAlert()
        showCaption("Time's up  —  task pushed back to queue")
        scheduler.advance(completed: false, store: store)
        await pause(2.5)

        // Complete the now-active task
        showCaption("Done ✓  —  task complete")
        scheduler.advance(completed: true, store: store)
        await pause(2.5)

        // Complete the next task
        showCaption("Done ✓  —  task complete")
        scheduler.advance(completed: true, store: store)
        await pause(2.5)

        // Stop scheduler; complete remaining tasks directly to show completion animations
        scheduler.stop()
        await pause(1.0)

        // ── 4. Sweep remaining tasks ────────────────────────────────────────
        let remaining = store.orderedTodayItems.filter { !$0.isCompleted }
        for (index, task) in remaining.enumerated() {
            let isLast = index == remaining.count - 1
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                store.setCompleted(id: task.id, completed: true)
            }
            if isLast {
                // Fire confetti the instant the last task is checked off
                showCaption("All tasks complete! 🎉")
                showConfetti = true
            } else {
                showCaption("Complete")
                await pause(1.1)
            }
        }

        // ── 5. Hold confetti then clear ─────────────────────────────────────
        await pause(4.0)
        showCaption("")
    }

    // MARK: - Helpers

    private func setMode(_ mode: ScheduleMode, label: String, store: ScheduleStore) async {
        showCaption(label)
        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
            store.scheduleMode = mode
        }
    }

    private func showCaption(_ text: String) {
        withAnimation(.easeInOut(duration: 0.25)) { caption = text }
    }

    /// Awaits `seconds` with cooperative cancellation support.
    private func pause(_ seconds: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    /// Polls until the burst timer fires naturally (`showBurstAlert` becomes true) or the
    /// scheduler stops (e.g. task was already cancelled). Checks every 250 ms.
    private func waitForBurstAlert() async {
        guard let scheduler else { return }
        while !scheduler.showBurstAlert {
            guard scheduler.isRunning else { return }
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
    }
}
