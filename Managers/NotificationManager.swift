//
//  NotificationManager.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-20.
//  Updated: 2025-08-20 11:38:09 UTC
//

import Foundation
import UserNotifications
import SwiftUI
import UIKit

// MARK: - Notification Types
enum NotificationType: String, CaseIterable {
    case bookingConfirmed = "booking_confirmed"
    case bookingReminder = "booking_reminder"
    case bookingStatusUpdate = "booking_status_update"
    case servicerAssigned = "servicer_assigned"
    case serviceCompleted = "service_completed"
    case paymentReminder = "payment_reminder"
    
    var title: String {
        switch self {
        case .bookingConfirmed:
            return "Booking Confirmed! 🎉"
        case .bookingReminder:
            return "Service Reminder 📅"
        case .bookingStatusUpdate:
            return "Booking Update 📋"
        case .servicerAssigned:
            return "Servicer Assigned 👨‍🔧"
        case .serviceCompleted:
            return "Service Completed ✅"
        case .paymentReminder:
            return "Payment Due 💳"
        }
    }
    
    var sound: UNNotificationSound {
        switch self {
        case .bookingConfirmed, .serviceCompleted:
            return UNNotificationSound.default
        case .bookingReminder, .paymentReminder:
            return UNNotificationSound.defaultCritical
        case .bookingStatusUpdate, .servicerAssigned:
            return UNNotificationSound.default
        }
    }
}

// MARK: - Notification Manager
class NotificationManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var notificationSettings: UNNotificationSettings?
    
    static let shared = NotificationManager()
    
    // UI Testing detection
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING") ||
        ProcessInfo.processInfo.arguments.contains("UI-TESTING") ||
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
        UserDefaults.standard.bool(forKey: "UI_TESTING_MODE")
    }
    
    override init() {
        super.init()
        print("🔔 NotificationManager initialized - User: gamikapunsisi at 2025-08-20 11:38:09")
        setupNotificationCenter()
        checkAuthorizationStatus()
    }
    
    private func setupNotificationCenter() {
        UNUserNotificationCenter.current().delegate = self
        print("📱 Notification center delegate set - User: gamikapunsisi at 2025-08-20 11:38:09")
    }
    
    // MARK: - Permission Management
    func requestPermission() async -> Bool {
        if isUITesting {
            print("🧪 Mock notification permission granted - User: gamikapunsisi at 2025-08-20 11:38:09")
            await MainActor.run {
                self.isAuthorized = true
            }
            return true
        }
        
        print("🔐 Requesting notification permission - User: gamikapunsisi at 2025-08-20 11:38:09")
        
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound, .criticalAlert]
            )
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            if granted {
                print("✅ Notification permission granted - User: gamikapunsisi at 2025-08-20 11:38:09")
                await registerForRemoteNotifications()
            } else {
                print("❌ Notification permission denied - User: gamikapunsisi at 2025-08-20 11:38:09")
            }
            
            return granted
        } catch {
            print("❌ Error requesting notification permission: \(error.localizedDescription)")
            return false
        }
    }
    
    private func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
            print("📡 Registered for remote notifications - User: gamikapunsisi at 2025-08-20 11:38:09")
        }
    }
    
    func checkAuthorizationStatus() {
        if isUITesting {
            self.isAuthorized = true
            return
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationSettings = settings
                self.isAuthorized = settings.authorizationStatus == .authorized
                print("🔍 Notification authorization status: \(settings.authorizationStatus.rawValue) - User: gamikapunsisi at 2025-08-20 11:38:09")
            }
        }
    }
    
    // MARK: - Booking Notifications
    func scheduleBookingConfirmationNotification(
        for booking: ServiceBooking
    ) async {
        print("📅 Scheduling booking confirmation notification - User: gamikapunsisi at 2025-08-20 11:38:09")
        print("   - Service: \(booking.serviceName)")
        print("   - Customer: \(booking.customerName)")
        print("   - Date: \(booking.formattedDate)")
        print("   - Time: \(booking.formattedTime)")
        
        let content = UNMutableNotificationContent()
        content.title = NotificationType.bookingConfirmed.title
        content.body = "Your booking for \(booking.serviceName) has been confirmed for \(booking.formattedDate) at \(booking.formattedTime)."
        content.sound = NotificationType.bookingConfirmed.sound
        content.badge = NSNumber(value: await getBadgeCount() + 1)
        
        // Add custom data
        content.userInfo = [
            "type": NotificationType.bookingConfirmed.rawValue,
            "bookingId": booking.id,
            "serviceName": booking.serviceName,
            "scheduledDate": booking.scheduledDate.timeIntervalSince1970,
            "timestamp": "2025-08-20 11:38:09 UTC",
            "createdBy": "gamikapunsisi"
        ]
        
        // Schedule immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
        let request = UNNotificationRequest(
            identifier: "booking_confirmed_\(booking.id)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Booking confirmation notification scheduled - User: gamikapunsisi at 2025-08-20 11:38:09")
        } catch {
            print("❌ Error scheduling booking confirmation notification: \(error.localizedDescription)")
        }
    }
    
    func scheduleBookingReminderNotification(
        for booking: ServiceBooking,
        reminderTime: TimeInterval = 3600 // 1 hour before
    ) async {
        print("⏰ Scheduling booking reminder notification - User: gamikapunsisi at 2025-08-20 11:38:09")
        
        let content = UNMutableNotificationContent()
        content.title = NotificationType.bookingReminder.title
        content.body = "Don't forget! Your \(booking.serviceName) service is scheduled for \(booking.formattedTime) today."
        content.sound = NotificationType.bookingReminder.sound
        content.badge = NSNumber(value: await getBadgeCount() + 1)
        
        content.userInfo = [
            "type": NotificationType.bookingReminder.rawValue,
            "bookingId": booking.id,
            "serviceName": booking.serviceName,
            "timestamp": "2025-08-20 11:38:09 UTC"
        ]
        
        // Schedule reminder before the booking time
        let reminderDate = booking.scheduledDate.addingTimeInterval(-reminderTime)
        
        if reminderDate > Date() {
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate),
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: "booking_reminder_\(booking.id)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
                print("✅ Booking reminder notification scheduled for \(reminderDate) - User: gamikapunsisi at 2025-08-20 11:38:09")
            } catch {
                print("❌ Error scheduling booking reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleStatusUpdateNotification(
        for bookingId: String,
        serviceName: String,
        newStatus: String,
        message: String
    ) async {
        print("📋 Scheduling status update notification - User: gamikapunsisi at 2025-08-20 11:38:09")
        
        let content = UNMutableNotificationContent()
        content.title = NotificationType.bookingStatusUpdate.title
        content.body = message
        content.sound = NotificationType.bookingStatusUpdate.sound
        content.badge = NSNumber(value: await getBadgeCount() + 1)
        
        content.userInfo = [
            "type": NotificationType.bookingStatusUpdate.rawValue,
            "bookingId": bookingId,
            "serviceName": serviceName,
            "newStatus": newStatus,
            "timestamp": "2025-08-20 11:38:09 UTC"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(
            identifier: "status_update_\(bookingId)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Status update notification scheduled - User: gamikapunsisi at 2025-08-20 11:38:09")
        } catch {
            print("❌ Error scheduling status update notification: \(error.localizedDescription)")
        }
    }
    
    func scheduleServiceCompletedNotification(
        for booking: ServiceBooking
    ) async {
        print("🎉 Scheduling service completed notification - User: gamikapunsisi at 2025-08-20 11:38:09")
        
        let content = UNMutableNotificationContent()
        content.title = NotificationType.serviceCompleted.title
        content.body = "Your \(booking.serviceName) service has been completed successfully! Please rate your experience."
        content.sound = NotificationType.serviceCompleted.sound
        content.badge = NSNumber(value: await getBadgeCount() + 1)
        
        content.userInfo = [
            "type": NotificationType.serviceCompleted.rawValue,
            "bookingId": booking.id,
            "serviceName": booking.serviceName,
            "timestamp": "2025-08-20 11:38:09 UTC"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(
            identifier: "service_completed_\(booking.id)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Service completed notification scheduled - User: gamikapunsisi at 2025-08-20 11:38:09")
        } catch {
            print("❌ Error scheduling service completed notification: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Utility Methods
    private func getBadgeCount() async -> Int {
        do {
            let notifications = try await UNUserNotificationCenter.current().deliveredNotifications()
            return notifications.count
        } catch {
            return 0
        }
    }
    
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("🧹 All notifications cleared - User: gamikapunsisi at 2025-08-20 11:38:09")
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("❌ Cancelled notification: \(identifier) - User: gamikapunsisi at 2025-08-20 11:38:09")
    }
    
    // MARK: - Debug Methods
    func listPendingNotifications() async {
        do {
            let requests = try await UNUserNotificationCenter.current().pendingNotificationRequests()
            print("📋 Pending notifications (\(requests.count)) - User: gamikapunsisi at 2025-08-20 11:38:09:")
            for request in requests {
                print("   - \(request.identifier): \(request.content.title)")
            }
        } catch {
            print("❌ Error fetching pending notifications: \(error.localizedDescription)")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📱 Notification received in foreground - User: gamikapunsisi at 2025-08-20 11:38:09")
        print("   - Title: \(notification.request.content.title)")
        print("   - Body: \(notification.request.content.body)")
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .badge, .sound])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        print("👆 Notification tapped - User: gamikapunsisi at 2025-08-20 11:38:09")
        print("   - Action: \(response.actionIdentifier)")
        print("   - User Info: \(userInfo)")
        
        if let notificationType = userInfo["type"] as? String {
            handleNotificationTap(type: notificationType, userInfo: userInfo)
        }
        
        completionHandler()
    }
    
    private func handleNotificationTap(type: String, userInfo: [AnyHashable: Any]) {
        switch type {
        case NotificationType.bookingConfirmed.rawValue:
            print("🎉 Handling booking confirmation tap")
            // Navigate to booking details or dashboard
            
        case NotificationType.bookingReminder.rawValue:
            print("⏰ Handling booking reminder tap")
            // Navigate to today's bookings
            
        case NotificationType.bookingStatusUpdate.rawValue:
            print("📋 Handling status update tap")
            // Navigate to specific booking
            
        case NotificationType.serviceCompleted.rawValue:
            print("✅ Handling service completed tap")
            // Navigate to rating/review screen
            
        default:
            print("🔔 Handling generic notification tap")
        }
    }
}
