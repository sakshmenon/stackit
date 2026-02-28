//
//  SupabaseScheduleItemRepository.swift
//  stackit
//
//  Supabase-backed implementation of ScheduleItemRepository.
//  Sync protocol methods operate on an in-memory cache (optimistic).
//  Call fetchItems(for:) async to populate the cache from the server.
//

import Foundation
import Supabase

// MARK: - Remote protocol

/// Optional async extension for repositories that can sync from a remote source.
protocol RemoteScheduleItemRepository: ScheduleItemRepository {
    func fetchItems(for date: Date) async throws
}

// MARK: - Row DTO (database ↔ app model)

private struct ScheduleItemRow: Decodable {
    let id: UUID
    let userId: UUID
    let title: String
    let notes: String
    let priority: Int
    let scheduleDate: String         // DATE as "yyyy-MM-dd"
    let scheduledStart: Date?
    let scheduledEnd: Date?
    let estimatedDurationMinutes: Int?
    let itemType: String
    let recurrenceKind: String
    let recurrenceWeekdays: [Int]?
    let isCompleted: Bool
    let completedAt: Date?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, notes, priority
        case userId = "user_id"
        case scheduleDate = "schedule_date"
        case scheduledStart = "scheduled_start"
        case scheduledEnd = "scheduled_end"
        case estimatedDurationMinutes = "estimated_duration_minutes"
        case itemType = "item_type"
        case recurrenceKind = "recurrence_kind"
        case recurrenceWeekdays = "recurrence_weekdays"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    func toScheduleItem() -> ScheduleItem? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(identifier: "UTC")
        guard let schedDate = df.date(from: scheduleDate) else { return nil }

        let rule: RecurrenceRule
        switch recurrenceKind {
        case "daily":    rule = .daily
        case "weekdays": rule = .weekdays
        case "weekly":   rule = .weekly(weekdays: Set(recurrenceWeekdays ?? []))
        default:         rule = .none
        }

        return ScheduleItem(
            id: id,
            userId: userId,
            title: title,
            notes: notes,
            priority: TaskPriority(rawValue: priority) ?? .medium,
            scheduleDate: schedDate,
            scheduledStart: scheduledStart,
            scheduledEnd: scheduledEnd,
            estimatedDurationMinutes: estimatedDurationMinutes,
            itemType: ScheduleItemType(rawValue: itemType) ?? .task,
            recurrenceRule: rule,
            isCompleted: isCompleted,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

private struct ScheduleItemInsert: Encodable {
    let id: UUID
    let userId: UUID
    let title: String
    let notes: String
    let priority: Int
    let scheduleDate: String
    let scheduledStart: Date?
    let scheduledEnd: Date?
    let estimatedDurationMinutes: Int?
    let itemType: String
    let recurrenceKind: String
    let recurrenceWeekdays: [Int]?
    let isCompleted: Bool
    let completedAt: Date?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, notes, priority
        case userId = "user_id"
        case scheduleDate = "schedule_date"
        case scheduledStart = "scheduled_start"
        case scheduledEnd = "scheduled_end"
        case estimatedDurationMinutes = "estimated_duration_minutes"
        case itemType = "item_type"
        case recurrenceKind = "recurrence_kind"
        case recurrenceWeekdays = "recurrence_weekdays"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(from item: ScheduleItem) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(identifier: "UTC")

        id = item.id
        userId = item.userId ?? UUID()
        title = item.title
        notes = item.notes
        priority = item.priority.rawValue
        scheduleDate = df.string(from: item.scheduleDate)
        scheduledStart = item.scheduledStart
        scheduledEnd = item.scheduledEnd
        estimatedDurationMinutes = item.estimatedDurationMinutes
        itemType = item.itemType.rawValue
        isCompleted = item.isCompleted
        completedAt = item.completedAt
        createdAt = item.createdAt
        updatedAt = item.updatedAt

        switch item.recurrenceRule {
        case .none:               recurrenceKind = "none";     recurrenceWeekdays = nil
        case .daily:              recurrenceKind = "daily";    recurrenceWeekdays = nil
        case .weekdays:           recurrenceKind = "weekdays"; recurrenceWeekdays = nil
        case .weekly(let days):   recurrenceKind = "weekly";   recurrenceWeekdays = Array(days)
        }
    }
}

// MARK: - Repository

final class SupabaseScheduleItemRepository: RemoteScheduleItemRepository {
    private let userId: UUID
    private var cache: [UUID: ScheduleItem] = [:]
    private let lock = NSLock()

    init(userId: UUID) {
        self.userId = userId
    }

    // MARK: - Sync (cache-based, for ScheduleStore.refresh())

    func items(for date: Date) -> [ScheduleItem] {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: date)
        lock.lock(); defer { lock.unlock() }
        return cache.values
            .filter { item in
                if cal.isDate(item.scheduleDate, inSameDayAs: startOfDay) { return true }
                if item.scheduleDate > startOfDay { return false }
                return item.recurrenceRule.applies(to: date)
            }
            .sorted { ($0.scheduledStart ?? .distantPast) < ($1.scheduledStart ?? .distantPast) }
    }

    func item(id: UUID) -> ScheduleItem? {
        lock.lock(); defer { lock.unlock() }
        return cache[id]
    }

    func add(_ item: ScheduleItem) {
        var owned = item
        owned.userId = userId
        lock.lock(); cache[owned.id] = owned; lock.unlock()
        Task { try? await insertToSupabase(owned) }
    }

    func update(_ item: ScheduleItem) {
        lock.lock(); cache[item.id] = item; lock.unlock()
        Task { try? await upsertToSupabase(item) }
    }

    func delete(id: UUID) {
        lock.lock(); cache.removeValue(forKey: id); lock.unlock()
        Task {
            try? await supabase.from("schedule_items")
                .delete()
                .eq("id", value: id)
                .eq("user_id", value: userId)
                .execute()
        }
    }

    func setCompleted(id: UUID, completed: Bool, at date: Date) {
        lock.lock()
        if var item = cache[id] {
            item.isCompleted = completed
            item.completedAt = completed ? date : nil
            item.updatedAt = date
            cache[id] = item
        }
        lock.unlock()
        Task {
            try? await supabase.from("schedule_items")
                .update([
                    "is_completed": AnyJSON(completed),
                    "updated_at": AnyJSON(date.iso8601String)
                ])
                .eq("id", value: id)
                .eq("user_id", value: userId)
                .execute()
        }
    }

    // MARK: - Async remote fetch

    /// Loads items for the given date (including recurring items) from Supabase into the cache.
    func fetchItems(for date: Date) async throws {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(identifier: "UTC")
        let dateStr = df.string(from: date)

        // Fetch exact-day items AND any recurring items that started on or before this date
        let rows: [ScheduleItemRow] = try await supabase
            .from("schedule_items")
            .select()
            .eq("user_id", value: userId)
            .or("schedule_date.eq.\(dateStr),and(recurrence_kind.neq.none,schedule_date.lte.\(dateStr))")
            .execute()
            .value

        lock.lock()
        for row in rows {
            if let item = row.toScheduleItem() {
                cache[item.id] = item
            }
        }
        lock.unlock()
    }

    // MARK: - Private Supabase helpers

    private func insertToSupabase(_ item: ScheduleItem) async throws {
        let insert = ScheduleItemInsert(from: item)
        try await supabase.from("schedule_items").insert(insert).execute()
    }

    private func upsertToSupabase(_ item: ScheduleItem) async throws {
        let insert = ScheduleItemInsert(from: item)
        try await supabase.from("schedule_items").upsert(insert).execute()
    }
}

// MARK: - Date helpers

private extension Date {
    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }
}
