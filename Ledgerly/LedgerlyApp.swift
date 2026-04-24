import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        NotificationService.shared.requestAuthorization { granted, _ in
            if granted { NotificationService.shared.scheduleDailyReminder() }
        }
        return true
    }
}

@main
struct LedgerlyApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(AuthService.shared)
        }
    }
}

