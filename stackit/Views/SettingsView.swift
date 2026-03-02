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

    /// Available burst-time presets in minutes. Includes 1 min for quick testing.
    static let burstTimePresets = [1, 5, 10, 15, 20, 25, 30, 45, 60, 90, 120]

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

                // Burst time is only relevant for preemptive mode (non-preemptive has no timer).
                if burstScheduler.schedulerMode == .preemptive {
                    Picker("Burst time", selection: $burstScheduler.burstTimeMinutes) {
                        ForEach(Self.burstTimePresets, id: \.self) { min in
                            Text("\(min) min").tag(min)
                        }
                    }
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
