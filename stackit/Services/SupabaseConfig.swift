//
//  SupabaseConfig.swift
//  stackit
//
//  Supabase project URL and anon key. Replace with your project values from Supabase Dashboard → Settings → API.
//

import Foundation

enum SupabaseConfig {
    /// Supabase project URL.
    static let url: URL = URL(string: "https://mwpeizqdmwcaobopppxe.supabase.co")!

    /// Supabase anon (public) key. Safe to embed in the app; RLS protects data server-side.
    static let anonKey: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13cGVpenFkbXdjYW9ib3BwcHhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwODg0NjQsImV4cCI6MjA4NzY2NDQ2NH0.AfQy61G6cnITmD3DynDNdZ04qTPnUUTa72jQqtfeTho"
}
