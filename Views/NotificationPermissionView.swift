//
//  NotificationPermissionView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-20.
//  Updated: 2025-08-20 11:38:09 UTC
//

import SwiftUI

struct NotificationPermissionView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @Binding var showingPermissionRequest: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: "bell.badge")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            // Title
            Text("Stay Updated!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            // Description
            VStack(spacing: 12) {
                Text("Get notified about:")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    NotificationFeatureRow(icon: "checkmark.circle", text: "Booking confirmations")
                    NotificationFeatureRow(icon: "clock", text: "Service reminders")
                    NotificationFeatureRow(icon: "person.badge.plus", text: "Servicer assignments")
                    NotificationFeatureRow(icon: "star", text: "Service completions")
                }
            }
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        let granted = await notificationManager.requestPermission()
                        if granted {
                            showingPermissionRequest = false
                        }
                        print("🔔 Permission request result: \(granted ? "✅ Granted" : "❌ Denied") - User: gamikapunsisi at 2025-08-20 11:38:09")
                    }
                }) {
                    Text("Enable Notifications")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button("Maybe Later") {
                    showingPermissionRequest = false
                    print("⏭️ Notification permission skipped - User: gamikapunsisi at 2025-08-20 11:38:09")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
        .onAppear {
            print("🔔 Notification permission view appeared - User: gamikapunsisi at 2025-08-20 11:38:09")
        }
    }
}

struct NotificationFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.green)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    NotificationPermissionView(showingPermissionRequest: .constant(true))
        .environmentObject(NotificationManager.shared)
}
