//
//  ContentView.swift
//  stackit
//
//  Root content: auth gate, schedule store, and main navigation (PRD FR-1).
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()
    @StateObject private var scheduleStore: ScheduleStore = {
        let repo = InMemoryScheduleItemRepository()
        return ScheduleStore(repository: repo)
    }()

    var body: some View {
        Group {
            switch authService.state {
            case .signedOut:
                LoginView()
            case .signedIn:
                RootContainerView()
            }
        }
        .environmentObject(authService)
        .environmentObject(scheduleStore)
        .task {
            await authService.restoreSession()
        }
    }
}

#Preview {
    ContentView()
}
