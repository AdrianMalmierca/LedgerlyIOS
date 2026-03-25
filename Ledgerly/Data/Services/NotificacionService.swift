import Foundation
import UserNotifications

final class NotificationService {
    
    static let shared = NotificationService()
    
    //Ask for permission
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    completion(granted, error)
                }
            }
    }
    
    //Schedule daily reminder
    func scheduleDailyReminder(at hour: Int = 20) {
        let content = UNMutableNotificationContent()
        content.title = "Don't forget your expenses"
        content.body = "Record your daily expenses to keep your budget up to date."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "dailyExpenseReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
