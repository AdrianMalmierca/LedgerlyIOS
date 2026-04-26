import Foundation
import FirebaseAuth
import Combine

@MainActor
final class AuthService{
    
    static let shared = AuthService()
    
    @Published private(set) var currentUser: User? = nil
    
    func signIn(email: String, password: String) async throws -> User{
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }
    
    func signUp(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
