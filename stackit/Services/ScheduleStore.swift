//
//  ScheduleStore.swift
//  stackit
//
//  Observable store over the schedule repository. Exposes today’s items, progress, and current task (PROJECT_TIMELINE Day 2).
//

import Foundation
import SwiftUI

/// Single source of truth for schedule UI. Uses a repository (in-memory now; Supabase later) and refreshes after mutations.
final class ScheduleStore: ObservableObject {
    @Published private(set) var todayItems: [ScheduleItem] = []
    @Published private(set) var selectedDate: Date

    private let repository: ScheduleItemRepository
    private let calendar: Calendar

    var progress: DailyProgress {
        let total = todayItems.count
        let completed = todayItems.filter(\.isCompleted).count
        return DailyProgress(completedCount: completed, totalCount: total)
    }

    /// Suggested current task for the main view (priority then time). Nil when none or all done.
    var currentTask: TaskItem? {
        guard let item = CurrentTaskScheduler.currentTask(from: todayItems) else { return nil }
        return TaskItem(from: item)
    }

    init(
        repository: ScheduleItemRepository,
        selectedDate: Date = Date(),
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.selectedDate = calendar.startOfDay(for: selectedDate)
        self.calendar = calendar
        refresh()
    }

    /// Reload today’s items from the repository and notify observers.
    func refresh() {
        todayItems = repository.items(for: selectedDate)
    }

    /// Switch the selected day (e.g. for a future date picker).
    func selectDate(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
        refresh()
    }

    func add(_ item: ScheduleItem) {
        repository.add(item)
        refresh()
    }

    func update(_ item: ScheduleItem) {
        repository.update(item)
        refresh()
    }

    func delete(id: UUID) {
        repository.delete(id: id)
        refresh()
    }

    func setCompleted(id: UUID, completed: Bool) {
        repository.setCompleted(id: id, completed: completed, at: Date())
        refresh()
    }

    func item(id: UUID) -> ScheduleItem? {
        repository.item(id: id)
    }
}
