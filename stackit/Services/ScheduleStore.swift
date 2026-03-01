//
//  ScheduleStore.swift
//  stackit
//
//  Observable store over the schedule repository. Exposes today's items, progress, and current task (PROJECT_TIMELINE Day 2).
//

import Foundation
import SwiftUI

/// Single source of truth for schedule UI. Uses a repository (in-memory or Supabase) and refreshes after mutations.
@MainActor
final class ScheduleStore: ObservableObject {
    @Published private(set) var todayItems: [ScheduleItem] = []
    @Published private(set) var orderedTodayItems: [ScheduleItem] = []
    @Published private(set) var selectedDate: Date
    @Published private(set) var isLoading: Bool = false

    /// Active scheduling mode (persisted so the picker survives foreground/background cycles).
    @Published var scheduleMode: ScheduleMode = .priority {
        didSet { applyMode() }
    }

    private let repository: ScheduleItemRepository
    private let calendar: Calendar

    var progress: DailyProgress {
        let total = todayItems.count
        let completed = todayItems.filter(\.isCompleted).count
        return DailyProgress(completedCount: completed, totalCount: total)
    }

    /// Current task derived from the active schedule mode's ordering.
    var currentTask: TaskItem? {
        guard let item = TaskScheduler.currentTask(from: orderedTodayItems) else { return nil }
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
        Task { await loadRemote(for: self.selectedDate) }
    }

    /// Reload items from the local cache, then apply the current scheduling mode.
    func refresh() {
        todayItems = repository.items(for: selectedDate)
        applyMode()
    }

    /// Reorder `orderedTodayItems`: completed items first (visual progress),
    /// then incomplete items sorted by the active `ScheduleMode`.
    private func applyMode() {
        let completed = todayItems.filter(\.isCompleted)
        let incomplete = todayItems.filter { !$0.isCompleted }
        let orderedIncomplete = TaskScheduler.apply(mode: scheduleMode, to: incomplete)
        orderedTodayItems = completed + orderedIncomplete
    }

    /// Switch the selected day and reload items.
    func selectDate(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
        refresh()
        Task { await loadRemote(for: selectedDate) }
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

    // MARK: - Remote sync

    /// Fetches from remote (if the repository supports it) then refreshes the local view.
    private func loadRemote(for date: Date) async {
        guard let remote = repository as? RemoteScheduleItemRepository else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await remote.fetchItems(for: date)
            // Only update if the date is still selected (user may have navigated away)
            if calendar.isDate(date, inSameDayAs: selectedDate) {
                refresh()
            }
        } catch {
            // Use cached data silently on network failure
        }
    }
}
