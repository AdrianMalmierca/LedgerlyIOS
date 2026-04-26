import Foundation
import Combine
import FirebaseAuth

class AuthViewModel: ObservableObject {
    
    @Published var user: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
            }
        }
    }
    
    var userId: String? { user?.uid }
    
    // MARK: - Email/Password
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let user = try await AuthService.shared.signIn(email: email, password: password)
                await MainActor.run {
                    self.user = user
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func signUp(email: String, password: String, confirmPassword: String) {
        guard password == confirmPassword else {
            errorMessage = "The passwords don't match"
            return
        }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let user = try await AuthService.shared.signUp(email: email, password: password)
                await MainActor.run {
                    self.user = user
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        try? AuthService.shared.signOut()
        user = nil
    }
}
