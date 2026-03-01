//
//  ScheduleMode.swift
//  stackit
//
//  Five task-ordering strategies, matching queueing.py (PROJECT_TIMELINE Day 5).
//

import Foundation

/// How the task queue is ordered for display and scheduling (mirrors queueing.py).
enum ScheduleMode: String, CaseIterable, Identifiable, Codable {
    case priority        = "priority"
    case reversePriority = "reverse_priority"
    case fifo            = "fifo"
    case lifo            = "lifo"
    case shuffle         = "shuffle"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .priority:        return "Priority"
        case .reversePriority: return "Low First"
        case .fifo:            return "FIFO"
        case .lifo:            return "LIFO"
        case .shuffle:         return "Shuffle"
        }
    }

    var systemImage: String {
        switch self {
        case .priority:        return "arrow.up.circle"
        case .reversePriority: return "arrow.down.circle"
        case .fifo:            return "clock"
        case .lifo:            return "clock.badge.questionmark"
        case .shuffle:         return "shuffle"
        }
    }

    /// One-line description shown in the picker tooltip.
    var subtitle: String {
        switch self {
        case .priority:        return "High priority first"
        case .reversePriority: return "Low priority first"
        case .fifo:            return "Oldest task first"
        case .lifo:            return "Newest task first"
        case .shuffle:         return "Random order"
        }
    }
}
