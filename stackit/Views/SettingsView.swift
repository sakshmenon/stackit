//
//  SettingsView.swift
//  stackit
//
//  Account and app settings; sign out (PRD FR-14).
//

import SwiftUI

/// Settings: account (email, sign out) and app options.
struct SettingsView: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        List {
            Section("Account") {
                if let email = authService.email {
                    LabeledContent("Email", value: email)
                }
                Button(role: .destructive) {
                    Task {
                        try? await authService.signOut()
                    }
                } label: {
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
            Section("App") {
                Text("Notifications")
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
    }
}
