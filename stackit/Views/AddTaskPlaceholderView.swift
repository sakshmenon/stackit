//
//  AddTaskPlaceholderView.swift
//  stackit
//
//  Placeholder for add-task flow (PRD FR-3). Full form in Day 2.
//

import SwiftUI

/// Add-task screen placeholder. Scaffolding only.
struct AddTaskPlaceholderView: View {
    var body: some View {
        ContentUnavailableView(
            "Add Task",
            systemImage: "plus.circle",
            description: Text("Task creation form will be added in the next sprint.")
        )
        .navigationTitle("New Task")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    NavigationStack {
        AddTaskPlaceholderView()
    }
}
