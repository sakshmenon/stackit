//
//  ContentView.swift
//  Dispatch
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
    @StateObject private var burstScheduler = BurstScheduler()

    @State private var isDemoMode = false

    var body: some View {
        ZStack {
            if isDemoMode {
                DemoRootView {
                    withAnimation(.easeInOut(duration: 0.35)) { isDemoMode = false }
                }
                .transition(.opacity)
                .zIndex(1)
            } else {
                Group {
                    switch authService.state {
                    case .signedOut:
                        LoginView(onWatchDemo: {
                            withAnimation(.easeInOut(duration: 0.35)) { isDemoMode = true }
                        })
                    case .signedIn:
                        RootContainerView()
                    }
                }
                .environmentObject(authService)
                .environmentObject(scheduleStore)
                .environmentObject(burstScheduler)
                .transition(.opacity)
                .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: isDemoMode)
        .task {
            await authService.restoreSession()
        }
    }
}

#Preview {
    ContentView()
}
