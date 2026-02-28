//
//  InMemoryScheduleItemRepository.swift
//  stackit
//
//  In-memory implementation of ScheduleItemRepository. Replace with Supabase-backed impl when persisting (NFR-2).
//

import Foundation

/// Thread-safe in-memory store for schedule items. Uses a serial queue so sync reads/writes are safe.
final class InMemoryScheduleItemRepository: ScheduleItemRepository {
    private var storage: [UUID: ScheduleItem] = [:]
    private let queue = DispatchQueue(label: "stackit.inmemory.repo")

    init(initialItems: [ScheduleItem] = []) {
        for item in initialItems {
            storage[item.id] = item
        }
    }

    func items(for date: Date) -> [ScheduleItem] {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: date)
        return queue.sync {
            storage.values
                .filter { item in
                    // Exact day match
                    if cal.isDate(item.scheduleDate, inSameDayAs: startOfDay) { return true }
                    // Recurring: only expand if the item started on or before the requested date
                    if item.scheduleDate > startOfDay { return false }
                    return item.recurrenceRule.applies(to: date)
                }
                .sorted { ($0.scheduledStart ?? .distantPast) < ($1.scheduledStart ?? .distantPast) }
        }
    }

    func item(id: UUID) -> ScheduleItem? {
        queue.sync { storage[id] }
    }

    func add(_ item: ScheduleItem) {
        queue.sync { [weak self] in
            self?.storage[item.id] = item
        }
    }

    func update(_ item: ScheduleItem) {
        queue.sync { [weak self] in
            self?.storage[item.id] = item
        }
    }

    func delete(id: UUID) {
        queue.sync { [weak self] in
            self?.storage.removeValue(forKey: id)
        }
    }

    func setCompleted(id: UUID, completed: Bool, at date: Date) {
        queue.sync { [weak self] in
            guard var item = self?.storage[id] else { return }
            item.isCompleted = completed
            item.completedAt = completed ? date : nil
            item.updatedAt = date
            self?.storage[id] = item
        }
    }
}
