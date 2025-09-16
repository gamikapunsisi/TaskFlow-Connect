//
//  AuthViewModel.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-20.
//  Updated: 2025-08-21 16:55:48 UTC
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import Combine
import LocalAuthentication

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
    
    // ✅ Biometric Authentication Properties
    @Published var showBiometricLogin = false
    @Published var biometricAuthResult: String? = nil
    @Published var isAuthenticatingBiometric = false
    @Published var shouldShowBiometricPrompt = false
    
    private let db = Firestore.firestore()
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    
    // ✅ Biometric Manager
    private let biometricManager = BiometricAuthManager.shared
    
    // Stored credentials for biometric authentication
    private let keychainService = "com.taskflow.credentials"
    private let emailKey = "stored_email"
    private let passwordKey = "stored_password"
    
    // MARK: - UI Testing Properties
    private var isUITestingMode: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING") ||
        ProcessInfo.processInfo.arguments.contains("UI-TESTING") ||
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
        UserDefaults.standard.bool(forKey: "UI_TESTING_MODE")
    }
    
    init() {
        print("🔧 AuthViewModel initialized with biometric support - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        configureAuthentication()
        setupAuthStateListener()
        setupBiometricAuthentication()
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        print("🔧 AuthViewModel deinitialized - User: gamikapunsisi at 2025-08-21 16:55:48")
    }
    
    // MARK: - ✅ Biometric Authentication Setup
    
    private func setupBiometricAuthentication() {
        print("🔐 Setting up biometric authentication - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        // Check if user has stored credentials and biometric is enabled
        if hasStoredCredentials() && biometricManager.shouldShowBiometricOption() {
            shouldShowBiometricPrompt = true
            print("✅ Biometric prompt will be available")
        }
    }
    
    // MARK: - ✅ Biometric Login Methods
    
    func loginWithBiometrics() async {
        print("🔐 Attempting biometric login - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        await MainActor.run {
            self.isAuthenticatingBiometric = true
            self.biometricAuthResult = nil
        }
        
        // Perform biometric authentication
        let authResult = await biometricManager.authenticateUser(reason: "Sign in to TaskFlow securely")
        
        switch authResult {
        case .success:
            await handleSuccessfulBiometricAuth()
            
        case .failure(let error):
            await handleBiometricAuthError(error)
            
        case .cancelled:
            await MainActor.run {
                self.isAuthenticatingBiometric = false
                self.biometricAuthResult = "Authentication cancelled"
            }
            print("⚠️ Biometric authentication cancelled by user")
        }
    }
    
    private func handleSuccessfulBiometricAuth() async {
        print("✅ Biometric authentication successful, retrieving stored credentials")
        
        // Retrieve stored credentials
        guard let email = getStoredCredential(for: emailKey),
              let password = getStoredCredential(for: passwordKey) else {
            await MainActor.run {
                self.isAuthenticatingBiometric = false
                self.biometricAuthResult = "No stored credentials found"
            }
            print("❌ No stored credentials available for biometric login")
            return
        }
        
        // Perform Firebase login with stored credentials
        await performFirebaseLogin(email: email, password: password, isBiometric: true)
    }
    
    private func handleBiometricAuthError(_ error: BiometricAuthError) async {
        await MainActor.run {
            self.isAuthenticatingBiometric = false
            self.biometricAuthResult = error.errorDescription ?? "Biometric authentication failed"
        }
        
        print("❌ Biometric authentication failed: \(error.errorDescription ?? "Unknown error")")
    }
    
    // MARK: - ✅ Enhanced Login with Biometric Support
    
    func login(email: String, password: String) {
        print("🔄 Starting login process for: \(email) - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        // Handle UI testing mode
        if isUITestingMode {
            mockLogin(email: email)
            return
        }
        
        // Validation
        guard validateLoginInput(email: email, password: password) else { return }
        
        Task {
            await performFirebaseLogin(email: email, password: password)
        }
    }
    
    // ✅ Enhanced login method with biometric credential storage option
    func loginWithBiometricSetup(email: String, password: String, enableBiometric: Bool = false) {
        print("🔄 Starting enhanced login with biometric setup option - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        // Handle UI testing mode
        if isUITestingMode {
            mockLogin(email: email)
            return
        }
        
        // Validation
        guard validateLoginInput(email: email, password: password) else { return }
        
        Task {
            await performFirebaseLogin(email: email, password: password, storeBiometric: enableBiometric)
        }
    }
    
    private func performFirebaseLogin(email: String, password: String, isBiometric: Bool = false, storeBiometric: Bool = false) async {
        await MainActor.run {
            if isBiometric {
                self.isAuthenticatingBiometric = true
            } else {
                self.isLoading = true
            }
            self.errorMessage = nil
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            await MainActor.run {
                if isBiometric {
                    self.isAuthenticatingBiometric = false
                    self.biometricAuthResult = "Login successful!"
                } else {
                    self.isLoading = false
                }
                
                self.currentUser = result.user
                self.isLoggedIn = true
            }
            
            print("✅ Login successful for: \(result.user.email ?? "No email") - User: gamikapunsisi at 2025-08-21 16:55:48")
            
            // Store credentials for biometric authentication if requested
            if storeBiometric && !isBiometric {
                await enableBiometricAuthForUser(email: email, password: password)
            }
            
        } catch {
            await MainActor.run {
                if isBiometric {
                    self.isAuthenticatingBiometric = false
                    self.biometricAuthResult = "Login failed: \(self.friendlyErrorMessage(error))"
                } else {
                    self.isLoading = false
                    self.errorMessage = self.friendlyErrorMessage(error)
                }
            }
            
            print("❌ Firebase Login Error: \(error.localizedDescription) - User: gamikapunsisi at 2025-08-21 16:55:48")
        }
    }
    
    // MARK: - ✅ Biometric Setup for User
    
    func enableBiometricAuthForUser(email: String, password: String) async {
        print("🔐 Setting up biometric authentication for user - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        let success = await biometricManager.enableBiometricAuth()
        
        if success {
            // Store credentials securely
            storeCredentials(email: email, password: password)
            
            await MainActor.run {
                self.shouldShowBiometricPrompt = true
            }
            
            print("✅ Biometric authentication enabled and credentials stored")
        } else {
            print("❌ Failed to enable biometric authentication")
        }
    }
    
    func disableBiometricAuth() {
        print("🔐 Disabling biometric authentication - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        biometricManager.disableBiometricAuth()
        removeStoredCredentials()
        
        shouldShowBiometricPrompt = false
        
        print("✅ Biometric authentication disabled and credentials removed")
    }
    
    // MARK: - ✅ Keychain Management
    
    private func storeCredentials(email: String, password: String) {
        storeCredential(email, for: emailKey)
        storeCredential(password, for: passwordKey)
        print("🔑 Credentials stored securely in Keychain")
    }
    
    private func storeCredential(_ value: String, for key: String) {
        let data = value.data(using: .utf8) ?? Data()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("⚠️ Failed to store credential for key: \(key)")
        }
    }
    
    private func getStoredCredential(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let credential = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return credential
    }
    
    private func removeStoredCredentials() {
        removeStoredCredential(for: emailKey)
        removeStoredCredential(for: passwordKey)
        print("🗑️ Stored credentials removed from Keychain")
    }
    
    private func removeStoredCredential(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    private func hasStoredCredentials() -> Bool {
        return getStoredCredential(for: emailKey) != nil && getStoredCredential(for: passwordKey) != nil
    }
    
    // MARK: - Configuration
    private func configureAuthentication() {
        if isUITestingMode {
            print("🧪 AuthViewModel: UI Testing Mode Detected - User: gamikapunsisi at 2025-08-21 16:55:48")
            setupMockAuthenticationForTesting()
        } else {
            print("✅ AuthViewModel: Production Mode - User: gamikapunsisi at 2025-08-21 16:55:48")
            configureFirebaseAuth()
        }
    }
    
    private func configureFirebaseAuth() {
        // Ensure Firebase is configured only in production mode
        guard !isUITestingMode else { return }
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("✅ Firebase configured in AuthViewModel - User: gamikapunsisi at 2025-08-21 16:55:48")
        }
        
        // Check if user is already authenticated
        if let currentUser = Auth.auth().currentUser {
            print("✅ User already authenticated: \(currentUser.email ?? "No email") - User: gamikapunsisi at 2025-08-21 16:55:48")
            DispatchQueue.main.async {
                self.isLoggedIn = true
                self.currentUser = currentUser
            }
            fetchUserRole()
        }
    }
    
    private func setupMockAuthenticationForTesting() {
        print("🧪 Setting up mock authentication for UI testing - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        // Check if we should start authenticated
        let shouldMockAuth = UserDefaults.standard.bool(forKey: "MOCK_AUTHENTICATED") ||
                           ProcessInfo.processInfo.environment["MOCK_AUTHENTICATED"] == "true"
        
        if shouldMockAuth {
            DispatchQueue.main.async {
                self.isLoggedIn = true
                
                let mockRoleString = UserDefaults.standard.string(forKey: "MOCK_USER_ROLE") ??
                                   ProcessInfo.processInfo.environment["MOCK_USER_ROLE"] ??
                                   "client" // Default to client for UI testing
                
                self.role = UserRole(rawValue: mockRoleString) ?? .client
                
                // Create mock user profile
                self.userProfile = UserProfile(
                    fullName: UserDefaults.standard.string(forKey: "MOCK_USER_NAME") ?? "Gamika Punsisi",
                    email: UserDefaults.standard.string(forKey: "MOCK_USER_EMAIL") ?? "gamikapunsisi@taskflow.lk",
                    profession: self.role == .tasker ? "Service Provider" : "Client",
                    location: "Colombo, Sri Lanka",
                    rating: 4.8,
                    totalJobs: self.role == .tasker ? 45 : 12,
                    joinedDate: Timestamp(date: Date()),
                    isVerified: true
                )
                
                print("🧪 Mock authentication complete - Role: \(mockRoleString) - User: gamikapunsisi at 2025-08-21 16:55:48")
            }
        } else {
            print("🧪 Mock authentication disabled - showing login screen - User: gamikapunsisi at 2025-08-21 16:55:48")
        }
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        // Skip Firebase listener in UI testing mode
        guard !isUITestingMode else {
            print("🧪 Skipping Firebase auth listener in UI testing mode - User: gamikapunsisi at 2025-08-21 16:55:48")
            return
        }
        
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isLoggedIn = user != nil
                
                if let user = user {
                    print("✅ Auth state changed: User logged in - \(user.email ?? "No email") - User: gamikapunsisi at 2025-08-21 16:55:48")
                    self?.fetchUserRole()
                    self?.fetchUserProfile()
                } else {
                    print("❌ Auth state changed: User logged out - User: gamikapunsisi at 2025-08-21 16:55:48")
                    self?.role = nil
                    self?.userProfile = nil
                }
            }
        }
    }
    
    // MARK: - Sign Up with Role
    func signUp(email: String, password: String, fullName: String = "", role: UserRole) {
        print("🔄 Starting sign up process for: \(email) with role: \(role.rawValue) - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        // Handle UI testing mode
        if isUITestingMode {
            mockSignUp(email: email, role: role, fullName: fullName)
            return
        }
        
        // Validation
        guard validateSignUpInput(email: email, password: password) else { return }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("❌ Firebase SignUp Error: \(error.localizedDescription) - User: gamikapunsisi at 2025-08-21 16:55:48")
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = self?.friendlyErrorMessage(error)
                }
                return
            }
            
            guard let uid = result?.user.uid else {
                print("❌ Firebase SignUp Error: User ID not found - User: gamikapunsisi at 2025-08-21 16:55:48")
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
                        print("⚠️ Failed to update display name: \(error.localizedDescription) - User: gamikapunsisi at 2025-08-21 16:55:48")
                    }
                }
            }
            
            // Save user data in Firestore
            self?.saveUserToFirestore(uid: uid, email: email, fullName: fullName, role: role)
        }
    }
    
    private func mockSignUp(email: String, role: UserRole, fullName: String) {
        print("🧪 Mock sign up for: \(email) with role: \(role.rawValue) - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.isLoggedIn = true
            self.role = role
            
            // Create mock user profile
            self.userProfile = UserProfile(
                fullName: fullName.isEmpty ? "Gamika Punsisi" : fullName,
                email: email,
                profession: role == .tasker ? "Service Provider" : "Client",
                location: "Colombo, Sri Lanka",
                rating: role == .tasker ? 4.8 : 5.0,
                totalJobs: role == .tasker ? 45 : 12,
                joinedDate: Timestamp(date: Date()),
                isVerified: true
            )
            
            print("🧪 Mock sign up successful - User: gamikapunsisi at 2025-08-21 16:55:48")
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
            "createdBy": "gamikapunsisi",
            "lastUpdated": "2025-08-21 16:55:48 UTC"
        ]
        
        db.collection("users").document(uid).setData(userData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("❌ Firestore Error: \(error.localizedDescription) - User: gamikapunsisi at 2025-08-21 16:55:48")
                    self?.errorMessage = "Failed to save user data"
                    return
                }
                
                print("✅ SignUp successful with role: \(role.rawValue) - User: gamikapunsisi at 2025-08-21 16:55:48")
                print("📝 User data saved for: \(email)")
                
                self?.role = role
                self?.isLoggedIn = true
                self?.fetchUserProfile()
            }
        }
    }
    
    private func mockLogin(email: String) {
        print("🧪 Mock login for: \(email) - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.isLoggedIn = true
            
            let mockRoleString = UserDefaults.standard.string(forKey: "MOCK_USER_ROLE") ??
                               ProcessInfo.processInfo.environment["MOCK_USER_ROLE"] ??
                               "client"
            
            self.role = UserRole(rawValue: mockRoleString) ?? .client
            
            // Create mock user profile
            self.userProfile = UserProfile(
                fullName: "Gamika Punsisi",
                email: email,
                profession: self.role == .tasker ? "Service Provider" : "Client",
                location: "Colombo, Sri Lanka",
                rating: 4.8,
                totalJobs: self.role == .tasker ? 45 : 12,
                joinedDate: Timestamp(date: Date()),
                isVerified: true
            )
            
            print("🧪 Mock login successful - Role: \(mockRoleString) - User: gamikapunsisi at 2025-08-21 16:55:48")
        }
    }
    
    // MARK: - Fetch User Role
    func fetchUserRole() {
        // Skip Firebase calls in UI testing mode
        guard !isUITestingMode else {
            print("🧪 Skipping Firebase role fetch in UI testing mode - User: gamikapunsisi at 2025-08-21 16:55:48")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ Fetch role failed: No current user - User: gamikapunsisi at 2025-08-21 16:55:48")
            return
        }
        
        print("🔄 Fetching user role for UID: \(uid) - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Firestore fetch role error: \(error.localizedDescription) - User: gamikapunsisi at 2025-08-21 16:55:48")
                DispatchQueue.main.async {
                    self?.errorMessage = "Failed to fetch user data"
                }
                return
            }
            
            guard let data = snapshot?.data() else {
                print("❌ No user data found in Firestore - User: gamikapunsisi at 2025-08-21 16:55:48")
                return
            }
            
            if let roleString = data["role"] as? String,
               let userRole = UserRole(rawValue: roleString) {
                DispatchQueue.main.async {
                    self?.role = userRole
                    print("✅ Fetched role: \(userRole.rawValue) - User: gamikapunsisi at 2025-08-21 16:55:48")
                }
            } else {
                print("❌ Invalid role data in Firestore - User: gamikapunsisi at 2025-08-21 16:55:48")
                // Default to client if no role found (changed from tasker to client)
                DispatchQueue.main.async {
                    self?.role = .client
                    print("⚠️ Defaulting to client role - User: gamikapunsisi at 2025-08-21 16:55:48")
                }
            }
        }
    }
    
    // MARK: - Fetch User Profile
    func fetchUserProfile() {
        // Skip Firebase calls in UI testing mode
        guard !isUITestingMode else {
            print("🧪 Skipping Firebase profile fetch in UI testing mode - User: gamikapunsisi at 2025-08-21 16:55:48")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ Fetch profile failed: No current user - User: gamikapunsisi at 2025-08-21 16:55:48")
            return
        }
        
        print("🔄 Fetching user profile for UID: \(uid) - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Firestore fetch profile error: \(error.localizedDescription) - User: gamikapunsisi at 2025-08-21 16:55:48")
                return
            }
            
            guard let data = snapshot?.data() else {
                print("❌ No profile data found - User: gamikapunsisi at 2025-08-21 16:55:48")
                return
            }
            
            // Create UserProfile using existing model structure
            let profile = UserProfile(
                fullName: data["fullName"] as? String ?? "User",
                email: data["email"] as? String ?? "",
                profession: data["profession"] as? String ?? (self?.role == .tasker ? "Service Provider" : "Client"),
                location: data["location"] as? String ?? "Location not set",
                rating: data["rating"] as? Double ?? 5.0,
                totalJobs: data["totalJobs"] as? Int ?? 0,
                joinedDate: data["joinedDate"] as? Timestamp ?? Timestamp(date: Date()),
                isVerified: data["isVerified"] as? Bool ?? false
            )
            
            DispatchQueue.main.async {
                self?.userProfile = profile
                print("✅ User profile loaded successfully - User: gamikapunsisi at 2025-08-21 16:55:48")
            }
        }
    }
    
    // MARK: - ✅ Enhanced Sign Out with Biometric Cleanup
    func signOut() {
        print("🔄 Starting sign out process - User: gamikapunsisi at 2025-08-21 16:55:48")
        
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
                
                // ✅ Clear biometric state
                self.shouldShowBiometricPrompt = false
                self.biometricAuthResult = nil
                self.isAuthenticatingBiometric = false
            }
            
            print("✅ User signed out successfully - User: gamikapunsisi at 2025-08-21 16:55:48")
        } catch {
            let errorMsg = error.localizedDescription
            DispatchQueue.main.async {
                self.errorMessage = errorMsg
            }
            print("❌ SignOut Error: \(errorMsg) - User: gamikapunsisi at 2025-08-21 16:55:48")
        }
    }
    
    private func mockSignOut() {
        print("🧪 Mock sign out - User: gamikapunsisi at 2025-08-21 16:55:48")
        
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.role = nil
            self.userProfile = nil
            self.errorMessage = nil
            
            // ✅ Clear biometric state
            self.shouldShowBiometricPrompt = false
            self.biometricAuthResult = nil
            self.isAuthenticatingBiometric = false
            
            // Clear mock data
            UserDefaults.standard.set(false, forKey: "MOCK_AUTHENTICATED")
            UserDefaults.standard.removeObject(forKey: "MOCK_USER_ROLE")
            UserDefaults.standard.removeObject(forKey: "MOCK_USER_NAME")
            UserDefaults.standard.removeObject(forKey: "MOCK_USER_EMAIL")
        }
        
        print("🧪 Mock sign out complete - User: gamikapunsisi at 2025-08-21 16:55:48")
    }
    
    // MARK: - Input Validation
    private func validateSignUpInput(email: String, password: String) -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanEmail.isEmpty else {
            errorMessage = "Email cannot be empty"
            print("❌ Validation failed: Empty email - User: gamikapunsisi at 2025-08-21 16:55:48")
            return false
        }
        
        guard isValidEmail(cleanEmail) else {
            errorMessage = "Please enter a valid email address"
            print("❌ Validation failed: Invalid email format - User: gamikapunsisi at 2025-08-21 16:55:48")
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            print("❌ Validation failed: Password too short - User: gamikapunsisi at 2025-08-21 16:55:48")
            return false
        }
        
        return true
    }
    
    private func validateLoginInput(email: String, password: String) -> Bool {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required"
            print("❌ Validation failed: Empty fields - User: gamikapunsisi at 2025-08-21 16:55:48")
            return false
        }
        
        guard isValidEmail(cleanEmail) else {
            errorMessage = "Please enter a valid email address"
            print("❌ Validation failed: Invalid email format - User: gamikapunsisi at 2025-08-21 16:55:48")
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
        biometricAuthResult = nil
        print("🧹 Error messages cleared - User: gamikapunsisi at 2025-08-21 16:55:48")
    }
    
    func refreshUserData() {
        guard isLoggedIn else {
            print("⚠️ Cannot refresh user data: User not logged in - User: gamikapunsisi at 2025-08-21 16:55:48")
            return
        }
        
        print("🔄 Refreshing user data - User: gamikapunsisi at 2025-08-21 16:55:48")
        fetchUserRole()
        fetchUserProfile()
    }
    
    var isTasker: Bool {
        role == .tasker
    }
    
    var isClient: Bool {
        role == .client
    }
    
    // MARK: - ✅ Biometric Properties
    
    var biometricType: BiometricType {
        biometricManager.biometricType
    }
    
    var isBiometricAvailable: Bool {
        biometricManager.isBiometricAvailable
    }
    
    var isBiometricEnabled: Bool {
        biometricManager.isBiometricEnabled
    }
    
    // MARK: - Development & Testing Helpers
    func getCurrentUserInfo() -> String {
        var info = "👤 Current User Info - User: gamikapunsisi at 2025-08-21 16:55:48\n"
        info += "📧 Email: \(currentUser?.email ?? userProfile?.email ?? "Not available")\n"
        info += "👥 Role: \(role?.rawValue ?? "Not set")\n"
        info += "🏠 Name: \(userProfile?.fullName ?? "Not available")\n"
        info += "🔐 Logged In: \(isLoggedIn)\n"
        info += "🧪 UI Testing: \(isUITestingMode)\n"
        info += "👆 Biometric Type: \(biometricType.displayName)\n"
        info += "✅ Biometric Available: \(isBiometricAvailable)\n"
        info += "🔛 Biometric Enabled: \(isBiometricEnabled)\n"
        
        return info
    }
    
    #if DEBUG
    func enableTestingMode() {
        UserDefaults.standard.set(true, forKey: "UI_TESTING_MODE")
        UserDefaults.standard.set(true, forKey: "MOCK_AUTHENTICATED")
        UserDefaults.standard.set("client", forKey: "MOCK_USER_ROLE")
        print("🧪 Testing mode enabled - User: gamikapunsisi at 2025-08-21 16:55:48")
    }
    
    func disableTestingMode() {
        UserDefaults.standard.set(false, forKey: "UI_TESTING_MODE")
        UserDefaults.standard.set(false, forKey: "MOCK_AUTHENTICATED")
        UserDefaults.standard.removeObject(forKey: "MOCK_USER_ROLE")
        print("🧪 Testing mode disabled - User: gamikapunsisi at 2025-08-21 16:55:48")
    }
    #endif
}

// MARK: - Extensions
extension AuthViewModel {
    var userDisplayName: String {
        return userProfile?.fullName ?? currentUser?.displayName ?? "User"
    }
    
    var userEmail: String {
        return userProfile?.email ?? currentUser?.email ?? "No email"
    }
    
    var userRoleDisplayName: String {
        return role?.displayName ?? "Unknown Role"
    }
}
