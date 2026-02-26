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
        guard let s = ProcessInfo.processInfo.environment["https://mwpeizqdmwcaobopppxe.supabase.co"], !s.isEmpty,
              let u = URL(string: s) else {
            return URL(string: "https://placeholder.supabase.co")!
        }
        return u
    }

    /// Supabase anon (public) key. Safe to use in the app; RLS protects data.
    static var anonKey: String {
        ProcessInfo.processInfo.environment["eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13cGVpenFkbXdjYW9ib3BwcHhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwODg0NjQsImV4cCI6MjA4NzY2NDQ2NH0.AfQy61G6cnITmD3DynDNdZ04qTPnUUTa72jQqtfeTho"] ?? "placeholder-anon-key"
    }
}
