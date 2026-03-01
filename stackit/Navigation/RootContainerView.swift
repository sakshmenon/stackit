//
//  RootContainerView.swift
//  stackit
//
//  Root navigation container: NavigationStack with main daily view and destination routing.
//

import SwiftUI

struct RootContainerView: View {
    @EnvironmentObject private var scheduleStore: ScheduleStore
    @EnvironmentObject private var burstScheduler: BurstScheduler
    @State private var navigationPath = [AppRoute]()

    /// Title of the currently active burst task, used in the alert message.
    private var activeTaskTitle: String {
        guard let id = burstScheduler.activeTaskId,
              let item = scheduleStore.item(id: id) else { return "the current task" }
        return "\(item.title)"
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            MainDailyView(
                currentTask: scheduleStore.currentTask,
                todayTasks: scheduleStore.orderedTodayItems.map(TaskItem.init(from:)),
                progress: scheduleStore.progress,
                selectedDate: scheduleStore.selectedDate,
                scheduleMode: scheduleStore.scheduleMode,
                onOpenSettings: { navigationPath.append(.settings) },
                onOpenTask: { navigationPath.append(.taskDetail($0)) },
                onAddTask: { type in navigationPath.append(.addTask(type)) },
                onSelectDate: { scheduleStore.selectDate($0) },
                onCompleteCurrentTask: {
                    guard let t = scheduleStore.currentTask else { return }
                    scheduleStore.setCompleted(id: t.id, completed: true)
                },
                onChangeMode: { scheduleStore.scheduleMode = $0 }
            )
            .navigationDestination(for: AppRoute.self) { route in
                destinationView(for: route)
            }
        }
        // Burst-time alert — mirrors driver.py input("Task X completed? (y/n)")
        .alert("Time's up!", isPresented: $burstScheduler.showBurstAlert) {
            Button("Done ✓") {
                burstScheduler.advance(completed: true, store: scheduleStore)
            }
            Button("Not yet") {
                burstScheduler.advance(completed: false, store: scheduleStore)
            }
        } message: {
            Text("Did you finish \(activeTaskTitle)?")
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
        .environmentObject(BurstScheduler())
}
