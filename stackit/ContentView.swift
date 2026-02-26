//
//  ContentView.swift
//  stackit
//
//  Root content: injects schedule store and shows main navigation container.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var scheduleStore: ScheduleStore = {
        let repo = InMemoryScheduleItemRepository()
        return ScheduleStore(repository: repo)
    }()

    var body: some View {
        RootContainerView()
            .environmentObject(scheduleStore)
    }
}

#Preview {
    ContentView()
}
