//
//  SettingsView.swift
//  stackit
//
//  Account and app settings; sign out (PRD FR-14).
//

import SwiftUI

/// Settings: account (email, sign out) and scheduler options.
struct SettingsView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var burstScheduler: BurstScheduler

    var body: some View {
        List {
            Section("Account") {
                if let email = authService.email {
                    LabeledContent("Email", value: email)
                }
                Button(role: .destructive) {
                    Task { try? await authService.signOut() }
                } label: {
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }

            Section {
                Picker("Scheduler", selection: $burstScheduler.schedulerMode) {
                    ForEach(BurstSchedulerMode.allCases) { mode in
                        Label(mode.displayName, systemImage: mode.systemImage).tag(mode)
                    }
                }
                .pickerStyle(.navigationLink)

                if burstScheduler.schedulerMode != .off {
                    Stepper(
                        "Burst time: \(burstScheduler.burstTimeMinutes) min",
                        value: $burstScheduler.burstTimeMinutes,
                        in: 5...120,
                        step: 5
                    )
                }
            } header: {
                Text("Scheduler")
            } footer: {
                Text(burstScheduler.schedulerMode.subtitle)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthService())
            .environmentObject(BurstScheduler())
    }
}
