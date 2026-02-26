//
//  CurrentTaskScheduler.swift
//  stackit
//
//  Picks the suggested “current” task from today’s items (PRD FR-6). Runs on device; full scheduler later.
//

import Foundation

/// Lightweight scheduler: given today’s items, returns the suggested current task (or nil).
enum CurrentTaskScheduler {
    /// Suggested task to do next: highest priority, then earliest start. Excludes completed and fixed events (events are shown in list only).
    static func currentTask(from items: [ScheduleItem], now: Date = Date()) -> ScheduleItem? {
        let incomplete = items.filter { !$0.isCompleted }
        let tasks = incomplete.filter { $0.itemType == .task }
        guard !tasks.isEmpty else { return nil }
        return tasks
            .sorted { a, b in
                if a.priority.rawValue != b.priority.rawValue {
                    return a.priority.rawValue > b.priority.rawValue
                }
                let aStart = a.scheduledStart ?? .distantPast
                let bStart = b.scheduledStart ?? .distantPast
                return aStart < bStart
            }
            .first
    }
}
