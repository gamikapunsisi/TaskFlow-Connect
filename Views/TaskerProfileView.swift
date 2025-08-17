import SwiftUI
import FirebaseAuth

struct TaskerProfileView: View {
    @StateObject private var profileManager = ProfileManager()
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSignOutAlert = false
    @State private var showingAccount = false
    @State private var showingNotifications = false
    @State private var showingLanguageSupport = false
    @State private var showingAbout = false
    @State private var showingHelp = false
    
    // Get current user
    private var currentUser: User? {
        Auth.auth().currentUser
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    
                    // Header with Back Button
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Profile Section
                    VStack(spacing: 16) {
                        // Profile Image
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 120)
                            
                            if let imageUrl = profileManager.userProfile?.profileImageUrl,
                               !imageUrl.isEmpty {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.black)
                                }
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        // Name and Details
                        VStack(spacing: 8) {
                            // Display name from profile or Firebase Auth
                            Text(displayName)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            // Display profession
                            Text(profileManager.userProfile?.profession ?? "Service Provider")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.secondary)
                            
                            // Display email
                            Text(displayEmail)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.secondary)
                            
                            // Display location if available
                            if let location = profileManager.userProfile?.location,
                               !location.isEmpty && location != "Location not set" {
                                Text(location)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 30)
                    
                    // Menu Items
                    VStack(spacing: 0) {
                        ProfileMenuItem(icon: "person.fill", title: "Account") {
                            showingAccount = true
                        }
                        
                        Divider()
                            .padding(.leading, 68)
                        
                        ProfileMenuItem(icon: "bell.fill", title: "Notifications") {
                            showingNotifications = true
                        }
                        
                        Divider()
                            .padding(.leading, 68)
                        
                        ProfileMenuItem(icon: "globe", title: "Language Support") {
                            showingLanguageSupport = true
                        }
                        
                        Divider()
                            .padding(.leading, 68)
                        
                        ProfileMenuItem(icon: "info.circle.fill", title: "About") {
                            showingAbout = true
                        }
                        
                        Divider()
                            .padding(.leading, 68)
                        
                        ProfileMenuItem(icon: "questionmark.circle.fill", title: "Help") {
                            showingHelp = true
                        }
                        
                        Divider()
                            .padding(.leading, 68)
                        
                        ProfileMenuItem(icon: "rectangle.portrait.and.arrow.right.fill", title: "Logout", showChevron: false) {
                            showingSignOutAlert = true
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                do {
                    try profileManager.signOut()
                    // Handle sign out success (navigate to login)
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print("❌ Sign out error: \(error)")
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        // Sheet presentations for different menu items
        .sheet(isPresented: $showingAccount) {
            AccountSettingsView()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showingLanguageSupport) {
            LanguageSupportView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
    }
    
    // MARK: - Computed Properties
    private var displayName: String {
        // Priority: Firestore profile name > Firebase Auth display name > "User"
        if let profileName = profileManager.userProfile?.fullName, !profileName.isEmpty {
            return profileName
        } else if let authName = currentUser?.displayName, !authName.isEmpty {
            return authName
        } else {
            return "User"
        }
    }
    
    private var displayEmail: String {
        // Priority: Firestore profile email > Firebase Auth email > "No email"
        if let profileEmail = profileManager.userProfile?.email, !profileEmail.isEmpty {
            return profileEmail
        } else if let authEmail = currentUser?.email, !authEmail.isEmpty {
            return authEmail
        } else {
            return "No email available"
        }
    }
}

// MARK: - Placeholder Views for Menu Items
struct AccountSettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Account Settings")
                    .font(.title)
                Spacer()
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct NotificationSettingsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Notification Settings")
                    .font(.title)
                Spacer()
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LanguageSupportView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Language Support")
                    .font(.title)
                Spacer()
            }
            .navigationTitle("Language Support")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AboutView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("About TaskFlow")
                    .font(.title)
                Spacer()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HelpView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Help & Support")
                    .font(.title)
                Spacer()
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TaskerProfileView()
}
