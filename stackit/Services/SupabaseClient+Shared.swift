//
//  SupabaseClient+Shared.swift
//  Dispatch
//
//  Convenience accessor so call sites can use SupabaseClient.shared.
//

import Supabase

extension SupabaseClient {
    static var shared: SupabaseClient { supabase }
}
