//
//  TaskItem.swift
//  stackit
//
//  Minimal model for main-screen display. Full task/event model to be extended in data layer.
//

import Foundation

/// Priority for scheduling (higher = more urgent). Aligns with PRD FR-3.
enum TaskPriority: Int, CaseIterable, Codable {
    case low = 0
    case medium = 1
    case high = 2

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

/// Lightweight task representation for the daily view. Supports offline-first (NFR-2).
struct TaskItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var notes: String
    var priority: TaskPriority
    var scheduledStart: Date?
    var scheduledEnd: Date?
    var isCompleted: Bool
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        priority: TaskPriority = .medium,
        scheduledStart: Date? = nil,
        scheduledEnd: Date? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.priority = priority
        self.scheduledStart = scheduledStart
        self.scheduledEnd = scheduledEnd
        self.isCompleted = isCompleted
        self.completedAt = completedAt
    }
}

/// Daily progress for the main screen. Used for completion rate and progress UI (FR-10).
struct DailyProgress: Equatable {
    var completedCount: Int
    var totalCount: Int

    var completionRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    static let empty = DailyProgress(completedCount: 0, totalCount: 0)
}
