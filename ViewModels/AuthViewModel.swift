//import SwiftUI
//import FirebaseAuth
//import FirebaseFirestore
//import FirebaseCore
//
//enum UserRole: String, Codable {
//    case tasker
//    case client
//}
//
//class AuthViewModel: ObservableObject {
//    @Published var isLoggedIn: Bool = false
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var role: UserRole? = nil
//
//    private let db = Firestore.firestore()
//
//    init() {
//        // Make sure Firebase is initialized
//        if FirebaseApp.app() == nil {
//            FirebaseApp.configure()
//        }
//
//        // If user already logged in, fetch role
//        if Auth.auth().currentUser != nil {
//            isLoggedIn = true
//            fetchUserRole()
//        }
//    }
//
//    // MARK: - Sign Up with Role
//    func signUp(email: String, password: String, role: UserRole) {
//        guard !email.isEmpty, password.count >= 6 else {
//            errorMessage = "Email or password invalid"
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//
//        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
//            if let error = error {
//                DispatchQueue.main.async {
//                    self?.isLoading = false
//                    self?.errorMessage = error.localizedDescription
//                }
//                return
//            }
//
//            guard let uid = result?.user.uid else {
//                DispatchQueue.main.async {
//                    self?.isLoading = false
//                    self?.errorMessage = "User ID not found"
//                }
//                return
//            }
//
//            // Save role in Firestore
//            self?.db.collection("users").document(uid).setData([
//                "email": email,
//                "role": role.rawValue,
//                "createdAt": FieldValue.serverTimestamp()
//            ]) { firestoreError in
//                DispatchQueue.main.async {
//                    self?.isLoading = false
//                    if let firestoreError = firestoreError {
//                        self?.errorMessage = firestoreError.localizedDescription
//                        return
//                    }
//                    self?.role = role
//                    self?.isLoggedIn = true
//                }
//            }
//        }
//    }
//
//    // MARK: - Login
//    func login(email: String, password: String) {
//        guard !email.isEmpty, password.count >= 6 else {
//            errorMessage = "Email or password invalid"
//            return
//        }
//
//        isLoading = true
//        errorMessage = nil
//
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self?.isLoading = false
//                    self?.errorMessage = error.localizedDescription
//                    return
//                }
//                self?.isLoggedIn = true
//                self?.fetchUserRole()
//                self?.isLoading = false
//            }
//        }
//    }
//
//    // MARK: - Fetch Role
//    func fetchUserRole() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        db.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
//            if let data = snapshot?.data(),
//               let roleString = data["role"] as? String,
//               let userRole = UserRole(rawValue: roleString) {
//                DispatchQueue.main.async {
//                    self?.role = userRole
//                }
//            }
//        }
//    }
//
//    // MARK: - Sign Out
//    func signOut() {
//        do {
//            try Auth.auth().signOut()
//            isLoggedIn = false
//            role = nil
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//    }
//}



import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import Combine

enum UserRole: String, Codable, CaseIterable {
    case tasker = "tasker"
    case client = "client"
    
    var displayName: String {
        switch self {
        case .tasker:
            return "Service Provider"
        case .client:
            return "Client"
        }
    }
    
    var description: String {
        switch self {
        case .tasker:
            return "Provide services to clients"
        case .client:
            return "Find and hire service providers"
        }
    }
}

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var role: UserRole? = nil
    @Published var currentUser: User? = nil
    @Published var userProfile: UserProfile? = nil
    
    private let db = Firestore.firestore()
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Testing Properties
    private var isUITestingMode: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }
    
    init() {
        print("🔧 AuthViewModel initialized - User: gamikapunsisi")
        print("📅 Current Time: 2025-08-17 20:21:03 UTC")
        
        configureAuthentication()
        setupAuthStateListener()
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Configuration
    private func configureAuthentication() {
        if isUITestingMode {
            print("🧪 AuthViewModel: UI Testing Mode Detected")
            setupMockAuthenticationForTesting()
        } else {
            print("✅ AuthViewModel: Production Mode")
            configureFirebaseAuth()
        }
    }
    
    private func configureFirebaseAuth() {
        // Ensure Firebase is configured
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("✅ Firebase configured in AuthViewModel")
        }
        
        // Check if user is already authenticated
        if let currentUser = Auth.auth().currentUser {
            print("✅ User already authenticated: \(currentUser.email ?? "No email")")
            DispatchQueue.main.async {
                self.isLoggedIn = true
                self.currentUser = currentUser
            }
            fetchUserRole()
        }
    }
    
    private func setupMockAuthenticationForTesting() {
        print("🧪 Setting up mock authentication for UI testing")
        
        // Check if we should start authenticated
        if UserDefaults.standard.bool(forKey: "MOCK_AUTHENTICATED") {
            DispatchQueue.main.async {
                self.isLoggedIn = true
                
                let mockRoleString = UserDefaults.standard.string(forKey: "MOCK_USER_ROLE") ?? "tasker"
                self.role = UserRole(rawValue: mockRoleString) ?? .tasker
                
                // Create mock user profile using your existing UserProfile model
                self.userProfile = UserProfile(
                    fullName: UserDefaults.standard.string(forKey: "MOCK_USER_NAME") ?? "Gamika Punsisi",
                    email: UserDefaults.standard.string(forKey: "MOCK_USER_EMAIL") ?? "gamikapunsisi@taskflow.lk",
                    profession: "Service Provider",
                    location: "Colombo, Sri Lanka",
                    rating: 4.8,
                    totalJobs: 45,
                    joinedDate: Timestamp(date: Date()),
                    isVerified: true
                )
                
                print("🧪 Mock authentication complete - Role: \(mockRoleString)")
            }
        }
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        // Skip Firebase listener in UI testing mode
        guard !isUITestingMode else { return }
        
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isLoggedIn = user != nil
                
                if let user = user {
                    print("✅ Auth state changed: User logged in - \(user.email ?? "No email")")
                    self?.fetchUserRole()
                    self?.fetchUserProfile()
                } else {
                    print("❌ Auth state changed: User logged out")
                    self?.role = nil
                    self?.userProfile = nil
                }
            }
        }
    }
    
    // MARK: - Sign Up with Role
    func signUp(email: String, password: String, fullName: String = "", role: UserRole) {
        // Handle UI testing mode
        if isUITestingMode {
            mockSignUp(email: email, role: role, fullName: fullName)
            return
        }
        
        // Validation
        guard validateSignUpInput(email: email, password: password) else { return }
        
        print("🔄 Starting sign up process for: \(email) with role: \(role.rawValue)")
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("❌ Firebase SignUp Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = self?.friendlyErrorMessage(error)
                }
                return
            }
            
            guard let uid = result?.user.uid else {
                print("❌ Firebase SignUp Error: User ID not found")
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Failed to create user account"
                }
                return
            }
            
            // Update display name if provided
            if !fullName.isEmpty {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = fullName
                changeRequest?.commitChanges { error in
                    if let error = error {
                        print("⚠️ Failed to update display name: \(error.localizedDescription)")
                    }
                }
            }
            
            // Save user data in Firestore
            self?.saveUserToFirestore(uid: uid, email: email, fullName: fullName, role: role)
        }
    }
    
    private func mockSignUp(email: String, role: UserRole, fullName: String) {
        print("🧪 Mock sign up for: \(email)")
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.isLoggedIn = true
            self.role = role
            
            // Use your existing UserProfile model
            self.userProfile = UserProfile(
                fullName: fullName.isEmpty ? "Gamika Punsisi" : fullName,
                email: email,
                profession: role == .tasker ? "Service Provider" : "Client",
                location: "Colombo, Sri Lanka",
                rating: 4.8,
                totalJobs: role == .tasker ? 45 : 12,
                joinedDate: Timestamp(date: Date()),
                isVerified: true
            )
            
            print("🧪 Mock sign up successful")
        }
    }
    
    private func saveUserToFirestore(uid: String, email: String, fullName: String, role: UserRole) {
        let userData: [String: Any] = [
            "email": email,
            "fullName": fullName,
            "role": role.rawValue,
            "profession": role == .tasker ? "Service Provider" : "Client",
            "location": "Location not set",
            "rating": 5.0,
            "totalJobs": 0,
            "isVerified": false,
            "joinedDate": FieldValue.serverTimestamp(),
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
            "createdBy": "gamikapunsisi" // Your identifier
        ]
        
        db.collection("users").document(uid).setData(userData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("❌ Firestore Error: \(error.localizedDescription)")
                    self?.errorMessage = "Failed to save user data"
                    return
                }
                
                print("✅ SignUp successful with role: \(role.rawValue)")
                print("📝 User data saved for: \(email)")
                
                self?.role = role
                self?.isLoggedIn = true
                self?.fetchUserProfile()
            }
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) {
        // Handle UI testing mode
        if isUITestingMode {
            mockLogin(email: email)
            return
        }
        
        // Validation
        guard validateLoginInput(email: email, password: password) else { return }
        
        print("🔄 Starting login process for: \(email)")
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("❌ Firebase Login Error: \(error.localizedDescription)")
                    self?.errorMessage = self?.friendlyErrorMessage(error)
                    return
                }
                
                guard let user = result?.user else {
                    print("❌ Login failed: No user returned")
                    self?.errorMessage = "Login failed"
                    return
                }
                
                print("✅ Login successful for: \(user.email ?? "No email")")
                self?.currentUser = user
                self?.isLoggedIn = true
                // Role and profile will be fetched by auth state listener
            }
        }
    }
    
    private func mockLogin(email: String) {
        print("🧪 Mock login for: \(email)")
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.isLoggedIn = true
            self.role = UserRole(rawValue: UserDefaults.standard.string(forKey: "MOCK_USER_ROLE") ?? "tasker") ?? .tasker
            
            // Use your existing UserProfile model
            self.userProfile = UserProfile(
                fullName: "Gamika Punsisi",
                email: email,
                profession: "Service Provider",
                location: "Colombo, Sri Lanka",
                rating: 4.8,
                totalJobs: 45,
                joinedDate: Timestamp(date: Date()),
                isVerified: true
            )
            
            print("🧪 Mock login successful")
        }
    }
    
    // MARK: - Fetch User Role
    func fetchUserRole() {
        // Skip Firebase calls in UI testing mode
        guard !isUITestingMode else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ Fetch role failed: No current user")
            return
        }
        
        print("🔄 Fetching user role for UID: \(uid)")
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Firestore fetch role error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to fetch user data"
                }
                return
            }
            
            guard let data = snapshot?.data() else {
                print("❌ No user data found in Firestore")
                return
            }
            
            if let roleString = data["role"] as? String,
               let userRole = UserRole(rawValue: roleString) {
                DispatchQueue.main.async {
                    self?.role = userRole
                    print("✅ Fetched role: \(userRole.rawValue)")
                }
            } else {
                print("❌ Invalid role data in Firestore")
                // Default to tasker if no role found
                DispatchQueue.main.async {
                    self?.role = .tasker
                    print("⚠️ Defaulting to tasker role")
                }
            }
        }
    }
    
    // MARK: - Fetch User Profile
    func fetchUserProfile() {
        // Skip Firebase calls in UI testing mode
        guard !isUITestingMode else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ Fetch profile failed: No current user")
            return
        }
        
        print("🔄 Fetching user profile for UID: \(uid)")
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Firestore fetch profile error: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("❌ No profile data found")
                return
            }
            
            // Create UserProfile using your existing model
            let profile = UserProfile(
                fullName: data["fullName"] as? String ?? "User",
                email: data["email"] as? String ?? "",
                profession: data["profession"] as? String ?? "Service Provider",
                location: data["location"] as? String ?? "Location not set",
                rating: data["rating"] as? Double ?? 5.0,
                totalJobs: data["totalJobs"] as? Int ?? 0,
                joinedDate: data["joinedDate"] as? Timestamp ?? Timestamp(date: Date()),
                isVerified: data["isVerified"] as? Bool ?? false
            )
            
            DispatchQueue.main.async {
                self?.userProfile = profile
                print("✅ User profile loaded successfully")
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        print("🔄 Starting sign out process")
        
        // Handle UI testing mode
        if isUITestingMode {
            mockSignOut()
            return
        }
        
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.role = nil
                self.currentUser = nil
                self.userProfile = nil
                self.errorMessage = nil
            }
            
            print("✅ User signed out successfully")
        } catch {
            let errorMsg = error.localizedDescription
            DispatchQueue.main.async {
                self.errorMessage = errorMsg
            }
            print("❌ SignOut Error: \(errorMsg)")
        }
    }
    
    private func mockSignOut() {
        print("🧪 Mock sign out")
        
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.role = nil
            self.userProfile = nil
            self.errorMessage = nil
            
            // Clear mock data
            UserDefaults.standard.set(false, forKey: "MOCK_AUTHENTICATED")
        }
        
        print("🧪 Mock sign out complete")
    }
    
    // MARK: - Input Validation
    private func validateSignUpInput(email: String, password: String) -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanEmail.isEmpty else {
            errorMessage = "Email cannot be empty"
            print("❌ Validation failed: Empty email")
            return false
        }
        
        guard isValidEmail(cleanEmail) else {
            errorMessage = "Please enter a valid email address"
            print("❌ Validation failed: Invalid email format")
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            print("❌ Validation failed: Password too short")
            return false
        }
        
        return true
    }
    
    private func validateLoginInput(email: String, password: String) -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required"
            print("❌ Validation failed: Empty fields")
            return false
        }
        
        guard isValidEmail(cleanEmail) else {
            errorMessage = "Please enter a valid email address"
            print("❌ Validation failed: Invalid email format")
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Error Handling
    private func friendlyErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already registered. Please try logging in."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Please enter a valid email address."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password is too weak. Please choose a stronger password."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email address."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Please try again."
        case AuthErrorCode.userDisabled.rawValue:
            return "This account has been disabled. Please contact support."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection and try again."
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Too many attempts. Please try again later."
        default:
            return error.localizedDescription
        }
    }
    
    // MARK: - Utility Methods
    func clearError() {
        errorMessage = nil
    }
    
    func refreshUserData() {
        guard isLoggedIn else { return }
        
        fetchUserRole()
        fetchUserProfile()
    }
    
    var isTasker: Bool {
        role == .tasker
    }
    
    var isClient: Bool {
        role == .client
    }
}
