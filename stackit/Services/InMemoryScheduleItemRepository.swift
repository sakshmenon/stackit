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
        let startOfDay = Calendar.current.startOfDay(for: date)
        return queue.sync {
            storage.values
                .filter { Calendar.current.isDate($0.scheduleDate, inSameDayAs: startOfDay) }
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
