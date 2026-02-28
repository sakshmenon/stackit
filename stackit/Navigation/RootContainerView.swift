//
//  RootContainerView.swift
//  stackit
//
//  Root navigation container: NavigationStack with main daily view and destination routing.
//

import SwiftUI

struct RootContainerView: View {
    @EnvironmentObject private var scheduleStore: ScheduleStore
    @State private var navigationPath = [AppRoute]()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            MainDailyView(
                currentTask: scheduleStore.currentTask,
                todayTasks: scheduleStore.todayItems.map(TaskItem.init(from:)),
                progress: scheduleStore.progress,
                selectedDate: scheduleStore.selectedDate,
                onOpenSettings: { navigationPath.append(.settings) },
                onOpenTask: { navigationPath.append(.taskDetail($0)) },
                onAddTask: { type in navigationPath.append(.addTask(type)) },
                onSelectDate: { scheduleStore.selectDate($0) },
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
        case .addTask(let type):
            AddEditTaskView(initialItem: nil, initialType: type)
        case .editTask(let item):
            AddEditTaskView(initialItem: item)
        }
    }
}

#Preview {
    RootContainerView()
        .environmentObject(ScheduleStore(repository: InMemoryScheduleItemRepository()))
}
