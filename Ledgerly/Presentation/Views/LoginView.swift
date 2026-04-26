import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject private var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                //Header
                VStack(spacing: 8) {
                    Image("LedgerlyIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                    
                    if let error = auth.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                    
                    Button {
                        auth.signIn(email: email, password: password)
                    } label: {
                        Group {
                            if auth.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("login_button")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background((email.isEmpty || password.isEmpty) ? Color.gray.opacity(0.4) : Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(email.isEmpty || password.isEmpty)
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
            .onAppear {
                auth.errorMessage = nil
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}
