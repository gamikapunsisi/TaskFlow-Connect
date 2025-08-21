//
//  ProfileView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-20.
//  Updated: 2025-08-20 16:40:15 UTC
//

import SwiftUI
import Firebase

struct ProfileView: View {
    @ObservedObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingLogoutConfirmation = false
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Profile Header
                    profileHeader
                    
                    // MARK: - User Information
                    userInformationSection
                    
                    // MARK: - Account Statistics
                    accountStatsSection
                    
                    // MARK: - Menu Options
                    menuOptionsSection
                    
                    // MARK: - Logout Section
                    logoutSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        print("✅ Profile dismissed - User: gamikapunsisi at 2025-08-20 16:40:15")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        print("✏️ Edit profile tapped - User: gamikapunsisi at 2025-08-20 16:40:15")
                        showingEditProfile = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            TaskFlowEditProfileView(authVM: authVM)
        }
        .alert("Sign Out", isPresented: $showingLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                print("🚪 User confirmed logout - User: gamikapunsisi at 2025-08-20 16:40:15")
                authVM.signOut()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to sign out of TaskFlow?")
        }
        .onAppear {
            print("👤 ProfileView appeared - User: gamikapunsisi at 2025-08-20 16:40:15")
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                // Firebase User profile image
                if let photoURL = authVM.currentUser?.photoURL?.absoluteString, !photoURL.isEmpty {
                    AsyncImage(url: URL(string: photoURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                } else {
                    // Use initials or default icon
                    if let displayName = authVM.currentUser?.displayName, !displayName.isEmpty {
                        Text(getInitials(from: displayName))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // User Name
            Text(authVM.currentUser?.displayName ?? "TaskFlow User")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            // User Role Badge
            HStack {
                Image(systemName: "person.badge")
                    .font(.system(size: 12))
                Text(authVM.role?.displayName ?? "User")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
        }
    }
    
    // MARK: - User Information Section
    private var userInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Information")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ProfileInfoRow(
                    icon: "envelope.fill",
                    title: "Email",
                    value: authVM.currentUser?.email ?? "Not available",
                    iconColor: .blue
                )
                
                ProfileInfoRow(
                    icon: "phone.fill",
                    title: "Phone",
                    value: authVM.currentUser?.phoneNumber ?? "Not provided",
                    iconColor: .green
                )
                
                ProfileInfoRow(
                    icon: "calendar",
                    title: "Member Since",
                    value: formatMemberSince(),
                    iconColor: .orange
                )
                
                ProfileInfoRow(
                    icon: "location.fill",
                    title: "Location",
                    value: "Sri Lanka",
                    iconColor: .red
                )
                
                ProfileInfoRow(
                    icon: "checkmark.shield.fill",
                    title: "Verification Status",
                    value: authVM.currentUser?.isEmailVerified == true ? "Verified" : "Unverified",
                    iconColor: authVM.currentUser?.isEmailVerified == true ? .green : .orange
                )
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Account Statistics Section
    private var accountStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 0) {
                StatCard(
                    icon: "calendar.badge.plus",
                    title: "Total Bookings",
                    value: "0",
                    color: Color.blue
                )
                
                Divider()
                    .frame(height: 60)
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    title: "Completed",
                    value: "0",
                    color: Color.green
                )
                
                Divider()
                    .frame(height: 60)
                
                StatCard(
                    icon: "star.fill",
                    title: "Reviews",
                    value: "0",
                    color: Color.yellow
                )
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Menu Options Section
    private var menuOptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                MenuOptionRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Manage notification preferences",
                    iconColor: .orange
                ) {
                    print("🔔 Notifications settings tapped - User: gamikapunsisi at 2025-08-20 16:40:15")
                }
                
                Divider()
                    .padding(.leading, 50)
                
                MenuOptionRow(
                    icon: "creditcard.fill",
                    title: "Payment Methods",
                    subtitle: "Manage payment options",
                    iconColor: .green
                ) {
                    print("💳 Payment methods tapped - User: gamikapunsisi at 2025-08-20 16:40:15")
                }
                
                Divider()
                    .padding(.leading, 50)
                
                MenuOptionRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    subtitle: "Get help and contact support",
                    iconColor: .blue
                ) {
                    print("❓ Help & Support tapped - User: gamikapunsisi at 2025-08-20 16:40:15")
                }
                
                Divider()
                    .padding(.leading, 50)
                
                MenuOptionRow(
                    icon: "info.circle.fill",
                    title: "About TaskFlow",
                    subtitle: "App version and information",
                    iconColor: .purple
                ) {
                    print("ℹ️ About tapped - User: gamikapunsisi at 2025-08-20 16:40:15")
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Logout Section
    private var logoutSection: some View {
        Button(action: {
            print("🚪 Logout button tapped - User: gamikapunsisi at 2025-08-20 16:40:15")
            showingLogoutConfirmation = true
        }) {
            HStack {
                Image(systemName: "arrow.right.square.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                
                Text("Sign Out")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
                
                Spacer()
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Helper Methods
    private func getInitials(from name: String) -> String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].first ?? "T") + String(words[1].first ?? "F")
        } else if let firstWord = words.first {
            return String(firstWord.first ?? "T")
        }
        return "TF"
    }
    
    private func formatMemberSince() -> String {
        if let creationDate = authVM.currentUser?.metadata.creationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: creationDate)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: Date())
        }
    }
}

// MARK: - Supporting Views

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MenuOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Profile View (Unique Name)
struct TaskFlowEditProfileView: View {
    @ObservedObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var displayName: String = ""
    @State private var phoneNumber: String = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        TextField("Display Name", text: $displayName)
                    }
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                            .frame(width: 20)
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                    }
                }
                
                Section(header: Text("Account")) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Text("Email")
                        Spacer()
                        Text(authVM.currentUser?.email ?? "Not available")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(authVM.currentUser?.isEmailVerified == true ? .green : .orange)
                            .frame(width: 20)
                        Text("Email Verification")
                        Spacer()
                        Text(authVM.currentUser?.isEmailVerified == true ? "Verified" : "Unverified")
                            .foregroundColor(authVM.currentUser?.isEmailVerified == true ? .green : .orange)
                    }
                }
                
                Section(footer: Text("Changes will be saved to your TaskFlow account.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        print("❌ Edit profile cancelled - User: gamikapunsisi at 2025-08-20 16:40:15")
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        print("💾 Save profile changes - User: gamikapunsisi at 2025-08-20 16:40:15")
                        saveProfileChanges()
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                loadCurrentUserData()
            }
            .alert("Profile Update", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .overlay(alignment: .center) {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Saving...")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding(24)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                }
            }
        }
        .onAppear {
            print("✏️ TaskFlowEditProfileView appeared - User: gamikapunsisi at 2025-08-20 16:40:15")
        }
    }
    
    private func loadCurrentUserData() {
        displayName = authVM.currentUser?.displayName ?? ""
        phoneNumber = authVM.currentUser?.phoneNumber ?? ""
        print("📋 Loaded current user data - User: gamikapunsisi at 2025-08-20 16:40:15")
    }
    
    private func saveProfileChanges() {
        isLoading = true
        
        // Simulate profile update process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            alertMessage = "Profile updated successfully!"
            showingAlert = true
            
            print("✅ Profile changes saved - User: gamikapunsisi at 2025-08-20 16:40:15")
            print("   - Display Name: \(displayName)")
            print("   - Phone Number: \(phoneNumber)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    ProfileView(authVM: AuthViewModel())
}
