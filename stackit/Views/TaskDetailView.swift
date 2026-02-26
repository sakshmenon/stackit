//
//  TaskDetailView.swift
//  stackit
//
//  Task/event detail with complete, edit, and delete (PRD FR-13). Wired to ScheduleStore.
//

import SwiftUI

/// Task detail and actions: mark complete, edit, delete.
struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var scheduleStore: ScheduleStore

    let task: TaskItem
    /// Called with the full schedule item when user taps Edit.
    var onEdit: ((ScheduleItem) -> Void)?

    var body: some View {
        List {
            Section("Task") {
                LabeledContent("Title", value: task.title)
                LabeledContent("Priority", value: task.priority.displayName)
                if let start = task.scheduledStart {
                    LabeledContent("Start", value: start.formatted(date: .omitted, time: .shortened))
                }
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .foregroundStyle(.secondary)
                }
            }
            Section {
                if !task.isCompleted {
                    Button {
                        scheduleStore.setCompleted(id: task.id, completed: true)
                    } label: {
                        Label("Mark complete", systemImage: "checkmark.circle")
                    }
                }
                if let item = scheduleStore.item(id: task.id), onEdit != nil {
                    Button {
                        onEdit?(item)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
                Button(role: .destructive) {
                    scheduleStore.delete(id: task.id)
                    dismiss()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .navigationTitle(task.title)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(
            task: TaskItem(
                title: "Review PRD",
                notes: "Check NFR section",
                priority: .high,
                scheduledStart: Date()
            ),
            onEdit: nil
        )
        .environmentObject(ScheduleStore(repository: InMemoryScheduleItemRepository()))
    }
}
