import SwiftUI
import FirebaseCore
import FirebaseAuth

import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {}

@main
struct LedgerlyApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var expenseVM: ExpenseListViewModel
    
    init() {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        NotificationService.shared.requestAuthorization { granted, _ in
            if granted {
                NotificationService.shared.scheduleDailyReminder()
            }
            NotificationService.shared.scheduleOnLaunchReminder()
        }
        
        let auth = AuthViewModel()
        _authViewModel = StateObject(wrappedValue: auth)
        _expenseVM = StateObject(wrappedValue: ExpenseListViewModel(auth: auth))
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.user != nil {
                LedgerlyTabView()
                    .environmentObject(expenseVM)
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
