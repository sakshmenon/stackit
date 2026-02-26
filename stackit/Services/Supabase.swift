//
//  SupabaseConfig.swift
//  stackit
//
//  Supabase project URL and anon key. Replace with your project values from Supabase Dashboard → Settings → API.
//

import Foundation

enum SupabaseConfig {
    /// Supabase project URL (e.g. https://xxxx.supabase.co)
    static var url: URL {
        guard let s = ProcessInfo.processInfo.environment["SUPABASE_URL"], !s.isEmpty,
              let u = URL(string: s) else {
            return URL(string: "https://placeholder.supabase.co")!
        }
        return u
    }

    /// Supabase anon (public) key. Safe to use in the app; RLS protects data.
    static var anonKey: String {
        ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "placeholder-anon-key"
    }
}
