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

    let initialItem: ScheduleItem?
    let initialType: ScheduleItemType

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var priority: TaskPriority = .medium
    @State private var scheduleDate: Date = Date()
    @State private var scheduledStart: Date = Date()
    @State private var hasStartTime: Bool = false
    @State private var scheduledEnd: Date = Date()
    @State private var hasEndTime: Bool = false
    @State private var estimatedMinutes: String = ""
    @State private var itemType: ScheduleItemType = .task
    @State private var recurrenceOption: RecurrenceOption = .none
    @State private var selectedWeekdays: Set<Int> = []

    private var isEditing: Bool { initialItem != nil }

    // Weekday data: (Calendar weekday number, short label), starting Monday
    private let weekdays: [(Int, String)] = [
        (2, "Mo"), (3, "Tu"), (4, "We"), (5, "Th"), (6, "Fr"), (7, "Sa"), (1, "Su")
    ]

    private enum RecurrenceOption: String, CaseIterable {
        case none, daily, weekdays, custom
        var displayName: String {
            switch self {
            case .none:     return "None"
            case .daily:    return "Daily"
            case .weekdays: return "Weekdays"
            case .custom:   return "Custom days"
            }
        }
        var toRule: RecurrenceRule {
            switch self {
            case .none:     return .none
            case .daily:    return .daily
            case .weekdays: return .weekdays
            case .custom:   return .weekly(weekdays: []) // weekdays filled from selectedWeekdays
            }
        }
        init(from rule: RecurrenceRule) {
            switch rule {
            case .none:    self = .none
            case .daily:   self = .daily
            case .weekdays: self = .weekdays
            case .weekly:  self = .custom
            }
        }
    }

    init(initialItem: ScheduleItem?, initialType: ScheduleItemType = .task) {
        self.initialItem = initialItem
        self.initialType = initialType
    }

    var body: some View {
        Form {
            titleSection

            if itemType == .task {
                prioritySection
                notesSection
            } else {
                eventScheduleSection
                repeatSection
                optionalNotesSection
            }
        }
        .navigationTitle(isEditing ? "Edit" : (itemType == .task ? "New Task" : "New Event"))
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveAndDismiss() }
                    .disabled(saveDisabled)
            }
        }
        .onAppear { bindFromInitialItem() }
        .onChange(of: itemType) { _, newType in
            // Events always require a start time
            if newType == .event { hasStartTime = true }
        }
    }

    // MARK: - Shared sections

    private var titleSection: some View {
        Section {
            TextField(itemType == .task ? "Task title" : "Event title", text: $title)
        } header: {
            Text("Title")
        }
    }

    private var repeatSection: some View {
        Section {
            Picker("Repeats", selection: $recurrenceOption) {
                ForEach(RecurrenceOption.allCases, id: \.self) { opt in
                    Text(opt.displayName).tag(opt)
                }
            }
            if recurrenceOption == .custom {
                weekdayPickerRow
            }
        } header: {
            Text("Repeat")
        }
    }

    // MARK: - Task-specific sections

    private var prioritySection: some View {
        Section {
            Picker("Priority", selection: $priority) {
                ForEach(TaskPriority.allCases, id: \.self) { p in
                    Text(p.displayName).tag(p)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Priority")
        } footer: {
            Text("Higher priority tasks are scheduled first.")
                .font(.caption)
        }
    }

    private var notesSection: some View {
        Section {
#if os(iOS)
            TextField("Add notes, context, or sub-tasks…", text: $notes, axis: .vertical)
                .lineLimit(4...8)
#else
            TextField("Add notes, context, or sub-tasks…", text: $notes)
#endif
        } header: {
            Text("Notes")
        }
    }

    // MARK: - Event-specific sections

    private var eventScheduleSection: some View {
        Section {
            DatePicker("Date", selection: $scheduleDate, displayedComponents: .date)
            // Start time is required for events
            DatePicker("Start time", selection: $scheduledStart, displayedComponents: .hourAndMinute)
            Toggle("End time", isOn: $hasEndTime)
            if hasEndTime {
                DatePicker("End time", selection: $scheduledEnd, displayedComponents: .hourAndMinute)
            }
        } header: {
            Text("When")
        } footer: {
            Text("Start time is required for events.")
                .font(.caption)
        }
    }

    private var optionalNotesSection: some View {
        Section {
#if os(iOS)
            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .lineLimit(3...6)
#else
            TextField("Notes (optional)", text: $notes)
#endif
        } header: {
            Text("Notes")
        }
    }

    // MARK: - Weekday picker

    private var weekdayPickerRow: some View {
        HStack(spacing: 6) {
            ForEach(weekdays, id: \.0) { day, label in
                let isOn = selectedWeekdays.contains(day)
                Button(label) {
                    if isOn { selectedWeekdays.remove(day) }
                    else { selectedWeekdays.insert(day) }
                }
                .font(.caption.weight(.semibold))
                .frame(width: 36, height: 36)
                .background(isOn ? Color.accentColor : Color.secondary.opacity(0.15))
                .foregroundStyle(isOn ? .white : .primary)
                .clipShape(Circle())
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Validation

    private var saveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Data binding

    private func bindFromInitialItem() {
        guard let item = initialItem else {
            scheduleDate = Calendar.current.startOfDay(for: Date())
            itemType = initialType
            if initialType == .event {
                hasStartTime = true
            }
            return
        }
        title = item.title
        notes = item.notes
        priority = item.priority
        scheduleDate = item.scheduleDate
        itemType = item.itemType
        if let start = item.scheduledStart {
            hasStartTime = true
            scheduledStart = start
        }
        if let end = item.scheduledEnd {
            hasEndTime = true
            scheduledEnd = end
        }
        estimatedMinutes = item.estimatedDurationMinutes.map { String($0) } ?? ""
        recurrenceOption = RecurrenceOption(from: item.recurrenceRule)
        if case .weekly(let days) = item.recurrenceRule {
            selectedWeekdays = days
        }
    }

    // MARK: - Save

    private func saveAndDismiss() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let startOfDay = Calendar.current.startOfDay(for: scheduleDate)

        // Events always have a start time; tasks only when toggled on
        let startDate: Date? = (itemType == .event || hasStartTime)
            ? combinedDate(time: scheduledStart, on: startOfDay)
            : nil
        let endDate: Date? = hasEndTime
            ? combinedDate(time: scheduledEnd, on: startOfDay)
            : nil

        let estMinutes = Int(estimatedMinutes.trimmingCharacters(in: .whitespacesAndNewlines))
            .flatMap { $0 > 0 ? $0 : nil }

        let rule: RecurrenceRule = recurrenceOption == .custom
            ? .weekly(weekdays: selectedWeekdays)
            : recurrenceOption.toRule

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
            updated.recurrenceRule = rule
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
                recurrenceRule: rule
            )
            scheduleStore.add(newItem)
        }
        dismiss()
    }

    private func combinedDate(time: Date, on day: Date) -> Date {
        let cal = Calendar.current
        return cal.date(
            bySettingHour: cal.component(.hour, from: time),
            minute: cal.component(.minute, from: time),
            second: 0,
            of: day
        ) ?? day
    }
}

// MARK: - Previews

#Preview("New Task") {
    NavigationStack {
        AddEditTaskView(initialItem: nil, initialType: .task)
            .environmentObject(ScheduleStore(repository: InMemoryScheduleItemRepository()))
    }
}

#Preview("New Event") {
    NavigationStack {
        AddEditTaskView(initialItem: nil, initialType: .event)
            .environmentObject(ScheduleStore(repository: InMemoryScheduleItemRepository()))
    }
}

#Preview("Edit Task") {
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
