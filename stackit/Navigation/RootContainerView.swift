//
//  RootContainerView.swift
//  stackit
//
//  Root navigation container: NavigationStack with main daily view and destination routing (Day 1 scaffolding).
//

import SwiftUI

/// Holds the main navigation stack and routes to Settings, Task Detail, and Add Task.
struct RootContainerView: View {
    @EnvironmentObject private var scheduleStore: ScheduleStore
    @State private var navigationPath = [AppRoute]()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            MainDailyView(
                currentTask: scheduleStore.currentTask,
                todayTasks: scheduleStore.todayItems.map(TaskItem.init(from:)),
                progress: scheduleStore.progress,
                onOpenSettings: { navigationPath.append(.settings) },
                onOpenTask: { navigationPath.append(.taskDetail($0)) },
                onAddTask: { navigationPath.append(.addTask) },
                onCompleteCurrentTask: {
                    guard let t = scheduleStore.currentTask else { return }
                    scheduleStore.setCompleted(id: t.id, completed: true)
                }
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
            TaskDetailView(task: task) { item in
                navigationPath.append(.editTask(item))
            }
        case .addTask:
            AddEditTaskView(initialItem: nil)
        case .editTask(let item):
            AddEditTaskView(initialItem: item)
        }
    }
}

#Preview {
    RootContainerView()
        .environmentObject(ScheduleStore(repository: InMemoryScheduleItemRepository()))
}
