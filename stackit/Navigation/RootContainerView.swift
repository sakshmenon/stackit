//
//  RootContainerView.swift
//  stackit
//
//  Root navigation container: NavigationStack with main daily view and destination routing (Day 1 scaffolding).
//

import SwiftUI

/// Holds the main navigation stack and routes to Settings, Task Detail, and Add Task.
struct RootContainerView: View {
    @State private var navigationPath = [AppRoute]()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            MainDailyView(
                currentTask: nil,
                progress: .empty,
                onOpenSettings: { navigationPath.append(.settings) },
                onOpenTask: { navigationPath.append(.taskDetail($0)) },
                onAddTask: { navigationPath.append(.addTask) }
            )
            .navigationDestination(for: AppRoute.self) { route in
                destinationView(for: route)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .settings:
            SettingsView()
        case .taskDetail(let task):
            TaskDetailView(task: task)
        case .addTask:
            AddTaskPlaceholderView()
        }
    }
}

#Preview {
    RootContainerView()
}
