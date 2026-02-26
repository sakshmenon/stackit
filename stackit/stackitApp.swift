//
//  stackitApp.swift
//  stackit
//
//  Created by saksh menon on 2/25/26.
//

import SwiftUI
import Supabase

@main
struct stackitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Task { _ = try? await SupabaseClient.shared.auth.handle(url) }
                }
        }
    }
}
