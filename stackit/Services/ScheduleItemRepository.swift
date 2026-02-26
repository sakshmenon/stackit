//
//  ScheduleItemRepository.swift
//  stackit
//
//  Abstraction for task/event persistence. In-memory impl now; Supabase impl in a later iteration (PROJECT_TIMELINE Day 2–3).
//

import Foundation

/// Contract for loading and saving schedule items. Implementations can be in-memory (now) or remote (e.g. Supabase).
protocol ScheduleItemRepository {
    /// All items for a given calendar day (scheduleDate normalized to start of day).
    func items(for date: Date) -> [ScheduleItem]

    /// Fetch a single item by id, if present.
    func item(id: UUID) -> ScheduleItem?

    /// Persist a new item. Caller provides an id or the repo can assign one.
    func add(_ item: ScheduleItem)

    /// Update an existing item by id. No-op if id not found.
    func update(_ item: ScheduleItem)

    /// Remove an item by id. No-op if id not found.
    func delete(id: UUID)

    /// Mark item as completed (or uncompleted) and set completedAt.
    func setCompleted(id: UUID, completed: Bool, at date: Date)
}
