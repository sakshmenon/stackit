//
//  TaskScheduler.swift
//  stackit
//
//  Swift port of schedulers/queueing.py — five task-ordering strategies (PRD FR-6).
//  Each static function mirrors its Python counterpart 1-to-1.
//

import Foundation

/// Pure scheduling functions. All operate on an array of ScheduleItem (the queue)
/// and return a reordered copy — no side effects (mirrors queueing.py).
enum TaskScheduler {

    // MARK: - Queue ordering (queueing.py)

    /// `priority_mode`: sort queue by priority, high urgency first.
    /// Python sorts ascending on a 1-3 integer where 1 = highest; our enum
    /// uses `high = 2`, so descending raw-value gives the same "most urgent first" semantics.
    static func priorityMode(_ queue: [ScheduleItem]) -> [ScheduleItem] {
        queue.sorted { $0.priority.rawValue > $1.priority.rawValue }
    }

    /// `rev_priority_mode`: sort queue by priority, low urgency first (reverse of priorityMode).
    static func reversePriorityMode(_ queue: [ScheduleItem]) -> [ScheduleItem] {
        queue.sorted { $0.priority.rawValue < $1.priority.rawValue }
    }

    /// `fifo_mode`: preserve original insertion order (oldest-created first).
    static func fifoMode(_ queue: [ScheduleItem]) -> [ScheduleItem] {
        queue.sorted { $0.createdAt < $1.createdAt }
    }

    /// `lifo_mode`: reverse insertion order (most recently created first).
    static func lifoMode(_ queue: [ScheduleItem]) -> [ScheduleItem] {
        queue.sorted { $0.createdAt > $1.createdAt }
    }

    /// `shuffle_mode`: randomise queue order.
    static func shuffleMode(_ queue: [ScheduleItem]) -> [ScheduleItem] {
        queue.shuffled()
    }

    // MARK: - Mode dispatch

    /// Apply a `ScheduleMode` to a queue of items and return the reordered result.
    static func apply(mode: ScheduleMode, to queue: [ScheduleItem]) -> [ScheduleItem] {
        switch mode {
        case .priority:        return priorityMode(queue)
        case .reversePriority: return reversePriorityMode(queue)
        case .fifo:            return fifoMode(queue)
        case .lifo:            return lifoMode(queue)
        case .shuffle:         return shuffleMode(queue)
        }
    }

    // MARK: - Current-task resolution

    /// The suggested "current" task: the first incomplete task in the ordered queue.
    /// Events are excluded — they are shown in the timeline but do not block scheduling.
    static func currentTask(from orderedQueue: [ScheduleItem]) -> ScheduleItem? {
        orderedQueue.first { !$0.isCompleted && $0.itemType == .task }
    }
}
