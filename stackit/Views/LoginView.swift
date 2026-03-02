//
//  LoginView.swift
//  stackit
//
//  Sign-in and sign-up with email/password via Supabase (PRD FR-1).
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage: String?
    @State private var confirmationMessage: String?
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Stackit")
                    .font(.largeTitle.weight(.bold))
                    .padding(.bottom, 8)

                VStack(spacing: 14) {
                    OutlinedField {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            #if os(iOS)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            #endif
                    }

                    OutlinedField {
                        SecureField("Password", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                    }
                }

                if let msg = confirmationMessage {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "envelope.badge.checkmark")
                            .foregroundStyle(Color.accentColor)
                        Text(msg)
                            .font(.caption)
                            .foregroundStyle(Color.accentColor)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if let msg = errorMessage {
                    Text(msg)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await submit() }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text(isSignUp ? "Sign up" : "Sign in")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(email.isEmpty || password.isEmpty || isLoading)

                Button {
                    isSignUp.toggle()
                    errorMessage = nil
                    confirmationMessage = nil
                } label: {
                    Text(isSignUp ? "Already have an account? Sign in" : "Need an account? Sign up")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(32)
        }
        .onOpenURL { url in
            Task { _ = try? await supabase.auth.handle(url) }
        }
    }

    private func submit() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            if isSignUp {
                try await authService.signUp(email: email, password: password)
                confirmationMessage = "Check your inbox — we sent a confirmation link to \(email). Confirm your email to activate your account."
                isSignUp = false
                password = ""
            } else {
                try await authService.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Outlined Field Wrapper

/// A simple outlined container for text inputs.
private struct OutlinedField<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.35), lineWidth: 1)
            }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}
