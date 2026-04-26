import SwiftUI

struct SignUpView: View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                VStack(spacing: 8) {
                    Image("LedgerlyIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                    
                    if let error = auth.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                    
                    Button {
                        auth.signUp(email: email, password: password, confirmPassword: confirmPassword)
                    } label: {
                        Group {
                            if auth.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("signup_button").font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background((email.isEmpty || password.isEmpty || confirmPassword.isEmpty) ? Color.gray.opacity(0.4) : Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .onAppear {
                auth.errorMessage = nil
            }
            .navigationBarBackButtonHidden(false)
        }
    }
}
