//
//  ContentView.swift
//  stackit
//
//  Root auth gate: shows LoginView when signed out, main app with Supabase-backed
//  ScheduleStore when signed in.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService()

    var body: some View {
        Group {
            switch authService.state {
            case .signedOut:
                LoginView()
                    .environmentObject(authService)

            case .signedIn(let userId):
                AuthenticatedRootView(userId: userId)
                    .environmentObject(authService)
            }
        }
        .onAppear {
            Task { await authService.restoreSession() }
        }
    }
}

// MARK: - Authenticated root

/// Created fresh whenever the signed-in userId changes, ensuring the ScheduleStore
/// is always backed by the correct Supabase user's repository.
private struct AuthenticatedRootView: View {
    let userId: UUID

    @StateObject private var scheduleStore: ScheduleStore

    init(userId: UUID) {
        self.userId = userId
        let repo = SupabaseScheduleItemRepository(userId: userId)
        _scheduleStore = StateObject(wrappedValue: ScheduleStore(repository: repo))
    }

    var body: some View {
        RootContainerView()
            .environmentObject(scheduleStore)
    }
}

#Preview {
    ContentView()
}
