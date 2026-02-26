//
//  TaskDetailView.swift
//  stackit
//
//  Placeholder for task/event detail and edit (PRD FR-13). To be expanded with full fields and actions.
//

import SwiftUI

/// Task detail and edit screen. Scaffolding only; full CRUD in later sprint.
struct TaskDetailView: View {
    let task: TaskItem

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
        }
        .navigationTitle(task.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(task: TaskItem(
            title: "Review PRD",
            notes: "Check NFR section",
            priority: .high,
            scheduledStart: Date()
        ))
    }
}
