//
//  SettingsView.swift
//  stackit
//
//  Placeholder for account and app settings (PRD FR-14). To be expanded with logout, notifications, privacy.
//

import SwiftUI

/// Settings and account screen. Scaffolding only; full implementation in later sprint.
struct SettingsView: View {
    var body: some View {
        List {
            Section("Account") {
                Text("Sign in / Account")
                    .foregroundStyle(.secondary)
            }
            Section("App") {
                Text("Notifications")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
