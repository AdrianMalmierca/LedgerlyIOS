//
//  AuthService.swift
//  Ledgerly
//
//  Created by Adrián on 23/4/26.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class AuthService: ObservableObject {
    
    static let shared = AuthService()
    
    @Published private(set) var currentUser: User? = nil
    @Published private(set) var isLoading: Bool = true
    
    private var stateListener: AuthStateDidChangeListenerHandle?
    
    private init() {
        stateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user //recover the user from the authentication state, to go to the correct screen
                self?.isLoading = false
            }
        }
    }
    
    var isLoggedIn: Bool { currentUser != nil }
    var userId: String? { currentUser?.uid }
    
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
