//
//  AppDelegate.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-20.
//  Updated: 2025-08-20 13:21:20 UTC
//

import UIKit
import Firebase
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("🚀 TaskFlow App launching via AppDelegate - User: gamikapunsisi at 2025-08-20 13:21:20")
        
        // Configure Firebase - Only once!
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("🔥 Firebase configured successfully via AppDelegate - User: gamikapunsisi at 2025-08-20 13:21:20")
        } else {
            print("ℹ️ Firebase already configured - skipping - User: gamikapunsisi at 2025-08-20 13:21:20")
        }
        
        // Initialize NotificationManager (this will request permissions)
        let _ = NotificationManager.shared
        print("🔔 NotificationManager initialized - User: gamikapunsisi at 2025-08-20 13:21:20")
        
        // Request notification permissions on app launch
        Task {
            let granted = await NotificationManager.shared.requestPermission()
            print("🔔 Notification permission on launch: \(granted ? "✅ Granted" : "❌ Denied") - User: gamikapunsisi at 2025-08-20 13:21:20")
        }
        
        return true
    }
    
    // Handle remote notification registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("🔑 Device Token received: \(token) - User: gamikapunsisi at 2025-08-20 13:21:20")
        
        // Store token for server-side notifications (if needed)
        UserDefaults.standard.set(token, forKey: "fcm_token")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "fcm_token_timestamp")
        
        print("💾 Device token saved to UserDefaults - User: gamikapunsisi at 2025-08-20 13:21:20")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription) - User: gamikapunsisi at 2025-08-20 13:21:20")
        
        // Store error for debugging
        UserDefaults.standard.set(error.localizedDescription, forKey: "notification_registration_error")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "notification_error_timestamp")
    }
    
    // Handle background app refresh
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("📱 App entered background - User: gamikapunsisi at 2025-08-20 13:21:20")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("📱 App will enter foreground - User: gamikapunsisi at 2025-08-20 13:21:20")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("📱 App became active - User: gamikapunsisi at 2025-08-20 13:21:20")
        
        // Clear app badge when app becomes active
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Check notification authorization status
        NotificationManager.shared.checkAuthorizationStatus()
    }
}
