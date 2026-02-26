//
//  ScheduleItem.swift
//  stackit
//
//  Full data model for schedule tasks and events (PROJECT_TIMELINE Day 2, PRD data model).
//

import Foundation

// MARK: - Schedule Item Type

/// Distinguishes a flexible task from a fixed-time event. Events have required start/end and are not moved by the scheduler.
enum ScheduleItemType: String, Codable, CaseIterable {
    case task
    case event

    var displayName: String {
        switch self {
        case .task: return "Task"
        case .event: return "Event"
        }
    }
}

// MARK: - Recurrence Rule

/// Recurrence for tasks/events. Aligns with PRD FR-3/FR-4 (recurring events).
enum RecurrenceRule: Codable, Equatable {
    case none
    case daily
    case weekly(weekdays: Set<Int>) // 1 = Sunday … 7 = Saturday (Calendar.Component.weekday)
    case weekdays // Mon–Fri

    static var weekdaysSet: Set<Int> { [2, 3, 4, 5, 6] }

    var displayName: String {
        switch self {
        case .none: return "None"
        case .daily: return "Daily"
        case .weekly(let days): return days.count == 7 ? "Every day" : "Weekly (\(days.sorted().count) days)"
        case .weekdays: return "Weekdays"
        }
    }

    private enum CodingKeys: String, CodingKey { case kind, weekdays }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(String.self, forKey: .kind)
        switch kind {
        case "none": self = .none
        case "daily": self = .daily
        case "weekdays": self = .weekdays
        case "weekly":
            let array = try c.decode([Int].self, forKey: .weekdays)
            self = .weekly(weekdays: Set(array))
        default: self = .none
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .none: try c.encode("none", forKey: .kind)
        case .daily: try c.encode("daily", forKey: .kind)
        case .weekdays: try c.encode("weekdays", forKey: .kind)
        case .weekly(let days): try c.encode("weekly", forKey: .kind); try c.encode(Array(days), forKey: .weekdays)
        }
    }
}

// MARK: - Schedule Item

/// Full in-app representation of a task or event. Holds all fields required for scheduling, display, and future persistence (PRD Task model).
struct ScheduleItem: Identifiable, Equatable, Hashable, Codable {
    var id: UUID
    var userId: UUID?
    var title: String
    var notes: String
    var priority: TaskPriority
    /// Calendar day this item is scheduled (start of day in local timezone). Used for “today’s” list and recurrence.
    var scheduleDate: Date
    /// Start date and time. Required for events; optional for tasks.
    var scheduledStart: Date?
    /// End date and time. Optional; when set with scheduledStart defines a fixed block (e.g. event).
    var scheduledEnd: Date?
    /// Estimated duration in minutes. Optional; used by scheduler when no end time.
    var estimatedDurationMinutes: Int?
    var itemType: ScheduleItemType
    var recurrenceRule: RecurrenceRule
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        userId: UUID? = nil,
        title: String,
        notes: String = "",
        priority: TaskPriority = .medium,
        scheduleDate: Date,
        scheduledStart: Date? = nil,
        scheduledEnd: Date? = nil,
        estimatedDurationMinutes: Int? = nil,
        itemType: ScheduleItemType = .task,
        recurrenceRule: RecurrenceRule = .none,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.notes = notes
        self.priority = priority
        self.scheduleDate = scheduleDate
        self.scheduledStart = scheduledStart
        self.scheduledEnd = scheduledEnd
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.itemType = itemType
        self.recurrenceRule = recurrenceRule
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Helpers

extension ScheduleItem {
    /// Duration in minutes from end − start when both set; otherwise from estimatedDurationMinutes.
    var effectiveDurationMinutes: Int? {
        if let start = scheduledStart, let end = scheduledEnd, end > start {
            return Int(end.timeIntervalSince(start) / 60)
        }
        return estimatedDurationMinutes
    }

    /// Whether this item is an event (fixed time block). Used by scheduler to avoid moving it.
    var isEvent: Bool { itemType == .event }
}
