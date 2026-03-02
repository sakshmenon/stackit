//
//  Supabase.swift
//  Dispatch
//
//  Shared Supabase client instance. Referenced throughout the app via SupabaseClient.shared.
//

import Supabase

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.anonKey
)
