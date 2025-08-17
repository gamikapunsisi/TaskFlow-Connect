import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class ProfileManager: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchUserProfile()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Fetch User Profile
    func fetchUserProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ No authenticated user")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        listener = db.collection("users").document(currentUser.uid)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        print("❌ Error fetching profile: \(error.localizedDescription)")
                        self?.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let document = documentSnapshot,
                          document.exists else {
                        print("❌ Profile document does not exist")
                        self?.createDefaultProfile()
                        return
                    }
                    
                    do {
                        self?.userProfile = try document.data(as: UserProfile.self)
                        print("✅ Profile loaded successfully")
                        // Sync with Firebase Auth after loading profile
                        self?.syncWithFirebaseAuth()
                    } catch {
                        print("❌ Error decoding profile: \(error)")
                        self?.errorMessage = "Failed to decode profile: \(error.localizedDescription)"
                    }
                }
            }
    }
    
    // MARK: - Create Default Profile
    private func createDefaultProfile() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let defaultProfile = UserProfile(
            fullName: currentUser.displayName ?? "User",
            email: currentUser.email ?? "",
            profession: "Service Provider",
            location: "Location not set",
            rating: 5.0,
            totalJobs: 0,
            joinedDate: Timestamp(date: Date()),
            isVerified: false
        )
        
        do {
            try db.collection("users").document(currentUser.uid).setData(from: defaultProfile)
            print("✅ Default profile created")
        } catch {
            print("❌ Error creating default profile: \(error)")
        }
    }
    
    // MARK: - Sync with Firebase Auth
    func syncWithFirebaseAuth() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // Update profile with current Firebase Auth data if profile is missing data
        if var profile = userProfile {
            var needsUpdate = false
            
            if profile.email.isEmpty && currentUser.email != nil {
                profile.email = currentUser.email!
                needsUpdate = true
                print("🔄 Updating profile email from Firebase Auth")
            }
            
            if profile.fullName.isEmpty && currentUser.displayName != nil {
                profile.fullName = currentUser.displayName!
                needsUpdate = true
                print("🔄 Updating profile name from Firebase Auth")
            }
            
            if needsUpdate {
                // Update Firestore with current auth data
                do {
                    try db.collection("users").document(currentUser.uid).setData(from: profile, merge: true)
                    print("✅ Profile synced with Firebase Auth data")
                    // Update the published property
                    DispatchQueue.main.async {
                        self.userProfile = profile
                    }
                } catch {
                    print("❌ Error syncing profile with Firebase Auth: \(error)")
                }
            }
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(_ updatedProfile: UserProfile) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        do {
            try db.collection("users").document(currentUser.uid).setData(from: updatedProfile, merge: true)
            print("✅ Profile updated successfully")
        } catch {
            print("❌ Error updating profile: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
        userProfile = nil
        listener?.remove()
    }
}
