//
//  LoginView.swift
//  stackit
//
//  Sign-in and sign-up with email/password via Supabase (PRD FR-1).
//

import SwiftUI
import Supabase

struct LoginView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Stackit")
                    .font(.largeTitle.weight(.bold))
                Text("Sign in or create an account")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif

                SecureField("Password", text: $password)
                    .textContentType(isSignUp ? .newPassword : .password)

                if let msg = errorMessage {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await submit() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text(isSignUp ? "Sign up" : "Sign in")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(email.isEmpty || password.isEmpty || isLoading)

                Button {
                    isSignUp.toggle()
                    errorMessage = nil
                } label: {
                    Text(isSignUp ? "Already have an account? Sign in" : "Need an account? Sign up")
                        .font(.caption)
                }
            }
            .padding(32)
        }
        .onOpenURL { url in
            Task { _ = try? await SupabaseClient.shared.auth.handle(url) }
        }
    }

    private func submit() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            if isSignUp {
                try await authService.signUp(email: email, password: password)
            } else {
                try await authService.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}
