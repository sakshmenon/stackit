//
//  LoginView.swift
//  Dispatch
//
//  Sign-in and sign-up with email/password via Supabase (PRD FR-1).
//  Full-screen background image fades from prominent at top to clear at bottom,
//  with the auth form anchored to the centre-bottom of the screen.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authService: AuthService
    var onWatchDemo: (() -> Void)? = nil

    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage: String?
    @State private var confirmationMessage: String?
    @State private var isLoading = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {

                // MARK: Background image — fades from full at top to clear at bottom
                Image("LoginBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            stops: [
                                .init(color: .clear,                                    location: 0.00),
                                .init(color: .clear,                                    location: 0.38),
                                .init(color: Color(.systemBackground).opacity(0.55),    location: 0.54),
                                .init(color: Color(.systemBackground).opacity(0.85),    location: 0.62),
                                .init(color: Color(.systemBackground),                  location: 0.72)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()

                // MARK: Auth form — anchored to the bottom, fades in from the top
                ScrollView {
                    VStack(spacing: 22) {
                        // App name — sits below the fade zone
                        Text("Dispatch")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Input fields
                        VStack(spacing: 12) {
                            OutlinedInputField {
                                TextField("Email", text: $email)
                                    .textContentType(.emailAddress)
                                    #if os(iOS)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    #endif
                            }

                            OutlinedInputField {
                                SecureField("Password", text: $password)
                                    .textContentType(isSignUp ? .newPassword : .password)
                            }
                        }

                        // Confirmation banner
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

                        // Error message
                        if let msg = errorMessage {
                            Text(msg)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }

                        // Submit button
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

                        // Toggle sign-in / sign-up
                        Button {
                            isSignUp.toggle()
                            errorMessage = nil
                            confirmationMessage = nil
                        } label: {
                            Text(isSignUp ? "Already have an account? Sign in" : "Need an account? Sign up")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Demo entry point
                        if let onWatchDemo {
                            Button {
                                onWatchDemo()
                            } label: {
                                Label("Watch Demo", systemImage: "play.circle")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.accentColor)
                            }
                            .padding(.top, 4)
                        }
                    }
                    // Extra top padding pushes content below the transparent fade zone
                    .padding(.horizontal, 28)
                    .padding(.top, 72)
                    .padding(.bottom, 40)
                }
                // Form panel occupies the lower 48 % of the screen (lower than before)
                .frame(height: geo.size.height * 0.48)
                .background(Color(.systemBackground))
                // Gradient mask: transparent at top → fully opaque ~22 % down.
                // This dissolves the hard card edge into the image fade above it.
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.00),
                            .init(color: .black.opacity(0.4), location: 0.10),
                            .init(color: .black, location: 0.22)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .ignoresSafeArea()
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

// MARK: - Outlined input field wrapper

private struct OutlinedInputField<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService())
}
