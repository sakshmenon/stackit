//
//  SupabaseClient+Shared.swift
//  stackit
//
//  Shared Supabase client for auth and database. Uses SupabaseConfig.
//

import Foundation
import Supabase

extension SupabaseClient {
    private static let _shared: SupabaseClient = {
        SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }()

    static var shared: SupabaseClient { _shared }
}
