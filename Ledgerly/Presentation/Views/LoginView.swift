//
//  LoginView.swift
//  Ledgerly
//
//  Created by Adrián on 23/4/26.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject private var auth: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                //Header
                VStack(spacing: 8) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)
                    Text("Ledgerly")
                        .font(.largeTitle.weight(.semibold))
                    Text("login_subtitle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                //Form
                VStack(spacing: 14) {
                    TextField("field_email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    SecureField("field_password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                    
                    Button {
                        Task { await login() }
                    } label: {
                        Group {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("login_button")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(canSubmit ? Color.blue : Color.gray.opacity(0.4))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!canSubmit || isLoading)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                //Sign up link
                HStack(spacing: 4) {
                    Text("no_account_label")
                        .foregroundStyle(.secondary)
                    Button("signup_link") {
                        showSignUp = true
                    }
                }
                .font(.subheadline)
                .padding(.bottom, 32)
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
    
    private var canSubmit: Bool {
        !email.isEmpty && password.count >= 6
    }
    
    private func login() async {
        isLoading = true
        errorMessage = nil
        do {
            try await auth.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
