//
//  BurstScheduler.swift
//  stackit
//
//  Swift port of driver.py:29-60 (preemptive and non_preemptive schedulers).
//
//  Mapping to Python:
//    queue             → self.queue ([UUID], not including the active task)
//    current_task      → self.activeTaskId
//    burst_time        → burstTimeMinutes * 60 (seconds)
//    input("y/n")      → SwiftUI alert (showBurstAlert → advance(completed:store:))
//    queue.pop(0)      → queue.removeFirst()
//    queue.append(...)  → queue.append(...)
//    pass              → beginCountdown() on same activeTaskId
//

import Foundation

@MainActor
final class BurstScheduler: ObservableObject {

    // MARK: - Settings (UserDefaults-persisted)

    @Published var schedulerMode: BurstSchedulerMode {
        didSet { UserDefaults.standard.set(schedulerMode.rawValue, forKey: Keys.mode) }
    }

    @Published var burstTimeMinutes: Int {
        didSet { UserDefaults.standard.set(burstTimeMinutes, forKey: Keys.burst) }
    }

    // MARK: - Runtime state

    @Published private(set) var isRunning: Bool = false
    @Published private(set) var timeRemainingSeconds: Int = 0
    @Published private(set) var activeTaskId: UUID? = nil

    /// Set to true when the burst timer fires; cleared by advance(completed:store:).
    @Published var showBurstAlert: Bool = false

    // MARK: - Private queue (mirrors driver.py `queue` list)

    /// Remaining task IDs in order, excluding the currently active task.
    private var queue: [UUID] = []
    private var timerTask: Task<Void, Never>?

    // MARK: - Init

    init() {
        let raw   = UserDefaults.standard.string(forKey: Keys.mode) ?? ""
        let saved = UserDefaults.standard.integer(forKey: Keys.burst)
        self.schedulerMode   = BurstSchedulerMode(rawValue: raw) ?? .off
        self.burstTimeMinutes = saved > 0 ? saved : 30
    }

    // MARK: - Control

    /// Start the scheduler with a pre-ordered list of items (mirrors: current_task = queue.pop(0)).
    /// Only incomplete tasks are enqueued; events are ignored.
    func start(orderedItems: [ScheduleItem]) {
        guard schedulerMode != .off else { return }
        stop()
        queue = orderedItems
            .filter { !$0.isCompleted && $0.itemType == .task }
            .map(\.id)
        guard !queue.isEmpty else { return }
        // current_task = queue.pop(0)
        activeTaskId = queue.removeFirst()
        isRunning = true
        beginCountdown()
    }

    /// Stop the scheduler and reset all state.
    func stop() {
        timerTask?.cancel()
        timerTask    = nil
        isRunning    = false
        timeRemainingSeconds = 0
        activeTaskId = nil
        queue        = []
        showBurstAlert = false
    }

    /// Called when the user answers the burst-time alert.
    ///
    /// Preemptive (driver.py lines 37-44):
    ///   - completed → mark done, pop next
    ///   - not completed → queue.append(current_task); current_task = queue.pop(0)
    ///
    /// Non-preemptive (driver.py lines 53-59):
    ///   - completed → current_task = queue.pop(0)
    ///   - not completed → pass  (same task, timer resets)
    func advance(completed: Bool, store: ScheduleStore) {
        showBurstAlert = false
        timerTask?.cancel()
        timerTask = nil

        guard let taskId = activeTaskId else { stop(); return }

        if completed {
            store.setCompleted(id: taskId, completed: true)
            popNext()
        } else if schedulerMode == .preemptive {
            // queue.append(current_task); current_task = queue.pop(0)
            queue.append(taskId)
            popNext()
        } else {
            // Non-preemptive: pass — stay on same task, reset burst timer
            beginCountdown()
        }
    }

    // MARK: - Private helpers

    /// Pop the next task from the queue and start its countdown, or stop if none remain.
    private func popNext() {
        guard !queue.isEmpty else {
            stop()
            return
        }
        // current_task = queue.pop(0)
        activeTaskId = queue.removeFirst()
        beginCountdown()
    }

    /// Start a per-second countdown for `burstTimeMinutes`. Fires `showBurstAlert` at zero.
    private func beginCountdown() {
        timerTask?.cancel()
        let totalSeconds = burstTimeMinutes * 60
        timeRemainingSeconds = totalSeconds

        timerTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for _ in 0..<totalSeconds {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    return  // Task cancelled — stop() was called
                }
                self.timeRemainingSeconds -= 1
            }
            self.showBurstAlert = true
        }
    }

    // MARK: - UserDefaults keys

    private enum Keys {
        static let mode  = "burstSchedulerMode"
        static let burst = "burstTimeMinutes"
    }
}
