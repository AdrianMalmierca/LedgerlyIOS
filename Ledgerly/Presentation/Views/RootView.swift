//
//  RootView.swift
//  Ledgerly
//
//  Created by Adrián on 24/4/26.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject private var auth: AuthService
    
    var body: some View {
        if auth.isLoading {
            ProgressView()
        } else if auth.isLoggedIn {
            LedgerlyTabView()
        } else {
            LoginView()
        }
    }
}
