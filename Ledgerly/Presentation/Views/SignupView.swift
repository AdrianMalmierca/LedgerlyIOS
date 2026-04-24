//
//  SignupView.swift
//  Ledgerly
//
//  Created by Adrián on 23/4/26.
//

import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject private var auth: AuthService
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("signup_title")
                    .font(.largeTitle.weight(.semibold))
                    .padding(.top, 40)
                Text("signup_subtitle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 40)
            
            VStack(spacing: 14) {
                TextField("field_email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                SecureField("field_password", text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                SecureField("field_confirm_password", text: $confirmPassword)
                    .textContentType(.newPassword)
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
                    Task { await signUp() }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("signup_button").font(.headline)
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
        }
        .navigationBarBackButtonHidden(false)
    }
    
    private var canSubmit: Bool {
        !email.isEmpty && password.count >= 6 && password == confirmPassword
    }
    
    private func signUp() async {
        isLoading = true
        errorMessage = nil
        do {
            try await auth.signUp(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
