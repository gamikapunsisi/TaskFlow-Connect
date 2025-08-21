////
////  ClientProfileView.swift
////  TaskFlow
////
////  Created by Gamika Punsisi on 2025-08-19.
////
//
//import SwiftUI
//import FirebaseAuth
//
//struct ClientProfileView: View {
//    @EnvironmentObject var authVM: AuthViewModel
//    @State private var showingEditProfile = false
//    @State private var showingSettings = false
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 24) {
//                    // Profile Header
//                    profileHeaderSection
//                    
//                    // Profile Stats
//                    profileStatsSection
//                    
//                    // Menu Options
//                    menuOptionsSection
//                    
//                    // Account Actions
//                    accountActionsSection
//                    
//                    Spacer()
//                }
//                .padding(.horizontal, 20)
//                .padding(.bottom, 100) // Space for bottom navigation
//            }
//            .navigationBarHidden(true)
//        }
//        .sheet(isPresented: $showingEditProfile) {
//            EditProfileView()
//                .environmentObject(authVM)
//        }
//        .sheet(isPresented: $showingSettings) {
//            SettingsView()
//        }
//    }
//    
//    // MARK: - Profile Header Section
//    private var profileHeaderSection: some View {
//        VStack(spacing: 20) {
//            // Profile Image
//            ZStack {
//                Circle()
//                    .fill(LinearGradient(
//                        gradient: Gradient(colors: [Color.blue, Color.purple]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    ))
//                    .frame(width: 100, height: 100)
//                
//                Text(getInitials())
//                    .font(.system(size: 36, weight: .bold))
//                    .foregroundColor(.white)
//            }
//            
//            // Profile Info
//            VStack(spacing: 8) {
//                Text(authVM.userProfile?.fullName ?? "User")
//                    .font(.system(size: 24, weight: .bold))
//                    .foregroundColor(.primary)
//                
//                Text(authVM.userProfile?.email ?? Auth.auth().currentUser?.email ?? "gamikapunsisi@taskflow.lk")
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.secondary)
//                
//                HStack(spacing: 16) {
//                    ProfileBadge(
//                        icon: "checkmark.seal.fill",
//                        text: authVM.userProfile?.isVerified == true ? "Verified" : "Unverified",
//                        color: authVM.userProfile?.isVerified == true ? .green : .orange
//                    )
//                    
//                    ProfileBadge(
//                        icon: "person.fill",
//                        text: authVM.role?.displayName ?? "Client",
//                        color: .blue
//                    )
//                }
//            }
//            
//            // Edit Profile Button
//            Button(action: {
//                showingEditProfile = true
//            }) {
//                HStack {
//                    Image(systemName: "pencil")
//                        .font(.system(size: 14, weight: .semibold))
//                    Text("Edit Profile")
//                        .font(.system(size: 16, weight: .semibold))
//                }
//                .foregroundColor(.blue)
//                .padding(.horizontal, 20)
//                .padding(.vertical, 10)
//                .background(Color.blue.opacity(0.1))
//                .cornerRadius(20)
//            }
//        }
//        .padding(.top, 20)
//    }
//    
//    // MARK: - Profile Stats Section
//    private var profileStatsSection: some View {
//        HStack(spacing: 20) {
//            ProfileStatCard(
//                title: "Total Bookings",
//                value: authVM.userProfile?.totalJobs ?? 0,
//                icon: "calendar",
//                color: .blue
//            )
//            
//            ProfileStatCard(
//                title: "Rating",
//                value: authVM.userProfile?.rating ?? 5.0,
//                icon: "star.fill",
//                color: .yellow,
//                isRating: true
//            )
//            
//            ProfileStatCard(
//                title: "Saved",
//                value: 0,
//                icon: "heart.fill",
//                color: .red
//            )
//        }
//    }
//    
//    // MARK: - Menu Options Section
//    private var menuOptionsSection: some View {
//        VStack(spacing: 16) {
//            Text("Account")
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundColor(.primary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            VStack(spacing: 0) {
//                ProfileMenuRow(
//                    icon: "person.circle",
//                    title: "Personal Information",
//                    subtitle: "Update your details"
//                ) {
//                    showingEditProfile = true
//                }
//                
//                Divider()
//                
//                ProfileMenuRow(
//                    icon: "bell",
//                    title: "Notifications",
//                    subtitle: "Manage notification preferences"
//                ) {
//                    print("🔔 Notifications tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
//                }
//                
//                Divider()
//                
//                ProfileMenuRow(
//                    icon: "creditcard",
//                    title: "Payment Methods",
//                    subtitle: "Manage payment options"
//                ) {
//                    print("💳 Payment methods tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
//                }
//                
//                Divider()
//                
//                ProfileMenuRow(
//                    icon: "location",
//                    title: "Saved Addresses",
//                    subtitle: "Manage service locations"
//                ) {
//                    print("📍 Saved addresses tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
//                }
//                
//                Divider()
//                
//                ProfileMenuRow(
//                    icon: "gear",
//                    title: "Settings",
//                    subtitle: "App preferences and privacy"
//                ) {
//                    showingSettings = true
//                }
//            }
//            .background(Color(UIColor.secondarySystemBackground))
//            .cornerRadius(12)
//        }
//    }
//    
//    // MARK: - Account Actions Section
//    private var accountActionsSection: some View {
//        VStack(spacing: 16) {
//            Text("Support")
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundColor(.primary)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            VStack(spacing: 0) {
//                ProfileMenuRow(
//                    icon: "questionmark.circle",
//                    title: "Help & Support",
//                    subtitle: "Get help or contact support"
//                ) {
//                    print("❓ Help & Support tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
//                }
//                
//                Divider()
//                
//                ProfileMenuRow(
//                    icon: "doc.text",
//                    title: "Terms & Privacy",
//                    subtitle: "Review our policies"
//                ) {
//                    print("📄 Terms & Privacy tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
//                }
//                
//                Divider()
//                
//                ProfileMenuRow(
//                    icon: "info.circle",
//                    title: "About TaskFlow",
//                    subtitle: "App version and information"
//                ) {
//                    print("ℹ️ About TaskFlow tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
//                }
//            }
//            .background(Color(UIColor.secondarySystemBackground))
//            .cornerRadius(12)
//            
//            // Sign Out Button
//            Button(action: {
//                print("🚪 Sign out tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
//                authVM.signOut()
//            }) {
//                HStack {
//                    Image(systemName: "power")
//                        .font(.system(size: 16, weight: .semibold))
//                    Text("Sign Out")
//                        .font(.system(size: 16, weight: .semibold))
//                }
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 16)
//                .background(Color.red)
//                .cornerRadius(12)
//            }
//        }
//    }
//    
//    // MARK: - Helper Methods
//    private func getInitials() -> String {
//        let name = authVM.userProfile?.fullName ?? "Gamika Punsisi"
//        let components = name.components(separatedBy: " ")
//        let initials = components.compactMap { $0.first }.prefix(2)
//        return String(initials).uppercased()
//    }
//}
//
//// MARK: - Supporting Views
//
//struct ProfileBadge: View {
//    let icon: String
//    let text: String
//    let color: Color
//    
//    var body: some View {
//        HStack(spacing: 6) {
//            Image(systemName: icon)
//                .font(.system(size: 12, weight: .semibold))
//            Text(text)
//                .font(.system(size: 12, weight: .semibold))
//        }
//        .foregroundColor(color)
//        .padding(.horizontal, 12)
//        .padding(.vertical, 6)
//        .background(color.opacity(0.1))
//        .cornerRadius(12)
//    }
//}
//
//struct ProfileStatCard: View {
//    let title: String
//    let value: Any
//    let icon: String
//    let color: Color
//    var isRating: Bool = false
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            Image(systemName: icon)
//                .font(.system(size: 24, weight: .medium))
//                .foregroundColor(color)
//            
//            if isRating, let rating = value as? Double {
//                Text(String(format: "%.1f", rating))
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.primary)
//            } else if let intValue = value as? Int {
//                Text("\(intValue)")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.primary)
//            } else {
//                Text("\(value)")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.primary)
//            }
//            
//            Text(title)
//                .font(.system(size: 12, weight: .medium))
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 20)
//        .background(Color(UIColor.secondarySystemBackground))
//        .cornerRadius(12)
//    }
//}
//
//struct ProfileMenuRow: View {
//    let icon: String
//    let title: String
//    let subtitle: String
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 16) {
//                Image(systemName: icon)
//                    .font(.system(size: 20, weight: .medium))
//                    .foregroundColor(.blue)
//                    .frame(width: 24)
//                
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(title)
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.primary)
//                    
//                    Text(subtitle)
//                        .font(.system(size: 14, weight: .regular))
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//                
//                Image(systemName: "chevron.right")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.secondary)
//            }
//            .padding(.vertical, 16)
//            .padding(.horizontal, 16)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}
//
//// MARK: - Placeholder Views
//
//struct EditProfileView: View {
//    @EnvironmentObject var authVM: AuthViewModel
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                Text("Edit Profile functionality will be implemented here")
//                    .font(.system(size: 16))
//                    .foregroundColor(.secondary)
//                    .padding()
//                
//                Spacer()
//            }
//            .navigationTitle("Edit Profile")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Save") {
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct SettingsView: View {
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                Text("Settings functionality will be implemented here")
//                    .font(.system(size: 16))
//                    .foregroundColor(.secondary)
//                    .padding()
//                
//                Spacer()
//            }
//            .navigationTitle("Settings")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Close") {
//                        presentationMode.wrappedValue.dismiss()
//                    }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    ClientMainView()
//}


//
//  ClientProfileView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-19.
//

import SwiftUI
import FirebaseAuth

struct ClientProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    profileHeaderSection
                    
                    // Profile Stats
                    profileStatsSection
                    
                    // Menu Options
                    menuOptionsSection
                    
                    // Account Actions
                    accountActionsSection
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Space for bottom navigation
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
                .environmentObject(authVM)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: 20) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text(getInitials())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Profile Info
            VStack(spacing: 8) {
                Text(authVM.userProfile?.fullName ?? "User")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(authVM.userProfile?.email ?? Auth.auth().currentUser?.email ?? "gamikapunsisi@taskflow.lk")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    ProfileBadge(
                        icon: "checkmark.seal.fill",
                        text: authVM.userProfile?.isVerified == true ? "Verified" : "Unverified",
                        color: authVM.userProfile?.isVerified == true ? .green : .orange
                    )
                    
                    ProfileBadge(
                        icon: "person.fill",
                        text: authVM.role?.displayName ?? "Client",
                        color: .blue
                    )
                }
            }
            
            // Edit Profile Button
            Button(action: {
                showingEditProfile = true
            }) {
                HStack {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Edit Profile")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Profile Stats Section
    private var profileStatsSection: some View {
        HStack(spacing: 20) {
            ProfileStatCard(
                title: "Total Bookings",
                value: authVM.userProfile?.totalJobs ?? 0,
                icon: "calendar",
                color: .blue
            )
            
            ProfileStatCard(
                title: "Rating",
                value: authVM.userProfile?.rating ?? 5.0,
                icon: "star.fill",
                color: .yellow,
                isRating: true
            )
            
            ProfileStatCard(
                title: "Saved",
                value: 0,
                icon: "heart.fill",
                color: .red
            )
        }
    }
    
    // MARK: - Menu Options Section
    private var menuOptionsSection: some View {
        VStack(spacing: 16) {
            Text("Account")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                ProfileMenuRow(
                    icon: "person.circle",
                    title: "Personal Information",
                    subtitle: "Update your details"
                ) {
                    showingEditProfile = true
                }
                
                Divider()
                
                ProfileMenuRow(
                    icon: "bell",
                    title: "Notifications",
                    subtitle: "Manage notification preferences"
                ) {
                    print("🔔 Notifications tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
                }
                
                Divider()
                
                ProfileMenuRow(
                    icon: "creditcard",
                    title: "Payment Methods",
                    subtitle: "Manage payment options"
                ) {
                    print("💳 Payment methods tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
                }
                
                Divider()
                
                ProfileMenuRow(
                    icon: "location",
                    title: "Saved Addresses",
                    subtitle: "Manage service locations"
                ) {
                    print("📍 Saved addresses tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
                }
                
                Divider()
                
                ProfileMenuRow(
                    icon: "gear",
                    title: "Settings",
                    subtitle: "App preferences and privacy"
                ) {
                    showingSettings = true
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Account Actions Section
    private var accountActionsSection: some View {
        VStack(spacing: 16) {
            Text("Support")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 0) {
                ProfileMenuRow(
                    icon: "questionmark.circle",
                    title: "Help & Support",
                    subtitle: "Get help or contact support"
                ) {
                    print("❓ Help & Support tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
                }
                
                Divider()
                
                ProfileMenuRow(
                    icon: "doc.text",
                    title: "Terms & Privacy",
                    subtitle: "Review our policies"
                ) {
                    print("📄 Terms & Privacy tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
                }
                
                Divider()
                
                ProfileMenuRow(
                    icon: "info.circle",
                    title: "About TaskFlow",
                    subtitle: "App version and information"
                ) {
                    print("ℹ️ About TaskFlow tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            // Sign Out Button
            Button(action: {
                print("🚪 Sign out tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
                authVM.signOut()
            }) {
                HStack {
                    Image(systemName: "power")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red)
                .cornerRadius(12)
            }
            .padding(.top, 12) // ✅ ensures it’s clearly visible
        }
    }
    
    // MARK: - Helper Methods
    private func getInitials() -> String {
        let name = authVM.userProfile?.fullName ?? "Gamika Punsisi"
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}

// MARK: - Supporting Views

struct ProfileBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: Any
    let icon: String
    let color: Color
    var isRating: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
            
            if isRating, let rating = value as? Double {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            } else if let intValue = value as? Int {
                Text("\(intValue)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            } else {
                Text("\(value)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder Views

struct EditProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Profile functionality will be implemented here")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings functionality will be implemented here")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ClientMainView()
}
