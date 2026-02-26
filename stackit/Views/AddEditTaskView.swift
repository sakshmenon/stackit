//
//  AddEditTaskView.swift
//  stackit
//
//  Create or edit a task/event. Wired to ScheduleStore add/update (PRD FR-3, FR-4).
//

import SwiftUI

/// Form to add a new schedule item or edit an existing one. Uses ScheduleStore.
struct AddEditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var scheduleStore: ScheduleStore

    /// Nil = new item; non-nil = edit existing.
    let initialItem: ScheduleItem?

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var priority: TaskPriority = .medium
    @State private var scheduleDate: Date = Date()
    @State private var hasStartTime: Bool = false
    @State private var scheduledStart: Date = Date()
    @State private var hasEndTime: Bool = false
    @State private var scheduledEnd: Date = Date()
    @State private var estimatedMinutes: String = ""
    @State private var itemType: ScheduleItemType = .task
    @State private var recurrenceOption: RecurrenceOption = .none

    private var isEditing: Bool { initialItem != nil }

    private enum RecurrenceOption: String, CaseIterable {
        case none, daily, weekdays
        var displayName: String {
            switch self {
            case .none: return RecurrenceRule.none.displayName
            case .daily: return RecurrenceRule.daily.displayName
            case .weekdays: return RecurrenceRule.weekdays.displayName
            }
        }
        var toRule: RecurrenceRule {
            switch self {
            case .none: return .none
            case .daily: return .daily
            case .weekdays: return .weekdays
            }
        }
        init(from rule: RecurrenceRule) {
            switch rule {
            case .none: self = .none
            case .daily: self = .daily
            case .weekdays: self = .weekdays
            case .weekly: self = .none
            }
        }
    }

    var body: some View {
        Form {
            Section("Title") {
                TextField("Task or event title", text: $title)
            }
            Section("Notes") {
                TextField("Optional notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
            Section("Type") {
                Picker("Type", selection: $itemType) {
                    ForEach(ScheduleItemType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("Priority") {
                Picker("Priority", selection: $priority) {
                    ForEach(TaskPriority.allCases, id: \.self) { p in
                        Text(p.displayName).tag(p)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("Date") {
                DatePicker("Schedule date", selection: $scheduleDate, displayedComponents: .date)
            }
            Section("Time") {
                Toggle("Start time", isOn: $hasStartTime)
                if hasStartTime {
                    DatePicker("Start", selection: $scheduledStart, displayedComponents: .hourAndMinute)
                }
                Toggle("End time", isOn: $hasEndTime)
                if hasEndTime {
                    DatePicker("End", selection: $scheduledEnd, displayedComponents: .hourAndMinute)
                }
                TextField("Est. minutes (optional)", text: $estimatedMinutes)
                    .keyboardType(.numberPad)
            }
            Section("Recurrence") {
                Picker("Repeats", selection: $recurrenceOption) {
                    ForEach(RecurrenceOption.allCases, id: \.self) { opt in
                        Text(opt.displayName).tag(opt)
                    }
                }
            }
        }
        .navigationTitle(isEditing ? "Edit" : "New Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveAndDismiss()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear { bindFromInitialItem() }
    }

    private func bindFromInitialItem() {
        guard let item = initialItem else {
            scheduleDate = Calendar.current.startOfDay(for: Date())
            return
        }
        title = item.title
        notes = item.notes
        priority = item.priority
        scheduleDate = item.scheduleDate
        if let start = item.scheduledStart {
            hasStartTime = true
            scheduledStart = start
        }
        if let end = item.scheduledEnd {
            hasEndTime = true
            scheduledEnd = end
        }
        estimatedMinutes = item.estimatedDurationMinutes.map { String($0) } ?? ""
        itemType = item.itemType
        recurrenceOption = RecurrenceOption(from: item.recurrenceRule)
    }

    private func saveAndDismiss() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let startOfDay = Calendar.current.startOfDay(for: scheduleDate)
        var startDate: Date?
        var endDate: Date?
        if hasStartTime {
            startDate = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: scheduledStart), minute: Calendar.current.component(.minute, from: scheduledStart), second: 0, of: startOfDay)
        }
        if hasEndTime {
            endDate = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: scheduledEnd), minute: Calendar.current.component(.minute, from: scheduledEnd), second: 0, of: startOfDay)
        }
        let estMinutes = Int(estimatedMinutes.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0 > 0 ? $0 : nil }

        if let existing = initialItem {
            var updated = existing
            updated.title = trimmedTitle
            updated.notes = notes
            updated.priority = priority
            updated.scheduleDate = startOfDay
            updated.scheduledStart = startDate
            updated.scheduledEnd = endDate
            updated.estimatedDurationMinutes = estMinutes
            updated.itemType = itemType
            updated.recurrenceRule = recurrenceOption.toRule
            updated.updatedAt = Date()
            scheduleStore.update(updated)
        } else {
            let newItem = ScheduleItem(
                title: trimmedTitle,
                notes: notes,
                priority: priority,
                scheduleDate: startOfDay,
                scheduledStart: startDate,
                scheduledEnd: endDate,
                estimatedDurationMinutes: estMinutes,
                itemType: itemType,
                recurrenceRule: recurrenceOption.toRule
            )
            scheduleStore.add(newItem)
        }
        dismiss()
    }
}

#Preview("New") {
    NavigationStack {
        AddEditTaskView(initialItem: nil)
            .environmentObject(ScheduleStore(repository: InMemoryScheduleItemRepository()))
    }
}

#Preview("Edit") {
    let item = ScheduleItem(
        title: "Review PRD",
        notes: "NFR section",
        priority: .high,
        scheduleDate: Date(),
        scheduledStart: Date(),
        itemType: .task
    )
    return NavigationStack {
        AddEditTaskView(initialItem: item)
            .environmentObject(ScheduleStore(repository: InMemoryScheduleItemRepository()))
    }
}
