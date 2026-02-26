//
//  AuthService.swift
//  stackit
//
//  Supabase Auth: sign-in, sign-up, sign-out, session. PRD FR-1.
//

import Foundation
import Supabase

/// Auth state for the app: signed out or signed in with a user id.
enum AuthState: Equatable {
    case signedOut
    case signedIn(userId: UUID)
}

/// Handles Supabase authentication. Use SupabaseClient.shared and listen to auth state changes.
@MainActor
final class AuthService: ObservableObject {
    @Published private(set) var state: AuthState = .signedOut
    @Published private(set) var email: String?

    private let client = SupabaseClient.shared
    private var authStateTask: Task<Void, Never>?

    init() {
        authStateTask = Task { await observeAuthState() }
    }

    deinit {
        authStateTask?.cancel()
    }

    /// Start observing auth state (session changes).
    private func observeAuthState() async {
        for await (_, session) in await client.auth.authStateChanges {
            await updateState(session: session)
        }
    }

    private func updateState(session: Session?) async {
        if let session = session {
            state = .signedIn(userId: session.user.id)
            email = session.user.email
        } else {
            state = .signedOut
            email = nil
        }
    }

    /// Sign up with email and password.
    func signUp(email: String, password: String) async throws {
        _ = try await client.auth.signUp(email: email, password: password)
        // Session may be nil if email confirmation is required; state will update on next auth event.
        if let session = try? await client.auth.session {
            await updateState(session: session)
        }
    }

    /// Sign in with email and password.
    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
        let session = try await client.auth.session
        await updateState(session: session)
    }

    /// Sign out.
    func signOut() async throws {
        try await client.auth.signOut()
        await updateState(session: nil)
    }

    /// Restore session from storage (e.g. on launch).
    func restoreSession() async {
        if let session = try? await client.auth.session {
            await updateState(session: session)
        } else {
            await updateState(session: nil)
        }
    }

    /// Current user id when signed in; nil otherwise.
    var currentUserId: UUID? {
        switch state {
        case .signedOut: return nil
        case .signedIn(let userId): return userId
        }
    }
}
