//
//  RootView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-20.
//  Updated: 2025-08-20 06:23:57 UTC
//

import SwiftUI

enum AuthScreen {
    case login, signup
}

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentScreen: AuthScreen = .signup
    
    // UI Testing detection
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING") ||
        ProcessInfo.processInfo.arguments.contains("UI-TESTING") ||
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
        UserDefaults.standard.bool(forKey: "UI_TESTING_MODE")
    }
    
    var body: some View {
        Group {
            if isUITesting {
                // UI Testing Mode - Go directly to ClientDashboardView
                handleUITestingMode()
            } else {
                // Normal Mode - Use authentication flow
                handleNormalMode()
            }
        }
        .onAppear {
            handleRootViewAppear()
        }
    }
    
    // MARK: - UI Testing Mode
    @ViewBuilder
    private func handleUITestingMode() -> some View {
        let mockRole = UserDefaults.standard.string(forKey: "MOCK_USER_ROLE") ?? "client"
        
        if UserDefaults.standard.bool(forKey: "MOCK_AUTHENTICATED") {
            // Show authenticated view based on mock role
            if let role = UserRole(rawValue: mockRole) {
                switch role {
                case .client:
                    ClientDashboardView()
                        .onAppear {
                            print("🧪 UI Testing: Showing ClientDashboardView - User: gamikapunsisi at 2025-08-20 06:23:57")
                        }
                case .tasker:
                    TaskerDashboardView()
                        .onAppear {
                            print("🧪 UI Testing: Showing TaskerDashboardView - User: gamikapunsisi at 2025-08-20 06:23:57")
                        }
                }
            } else {
                ClientDashboardView() // Default fallback
                    .onAppear {
                        print("🧪 UI Testing: Fallback to ClientDashboardView - User: gamikapunsisi at 2025-08-20 06:23:57")
                    }
            }
        } else {
            // Show authentication screen for UI testing
            authenticationView()
                .onAppear {
                    print("🧪 UI Testing: Showing authentication screen - User: gamikapunsisi at 2025-08-20 06:23:57")
                }
        }
    }
    
    // MARK: - Normal Mode
    @ViewBuilder
    private func handleNormalMode() -> some View {
        if authVM.isLoggedIn {
            authenticatedView()
        } else {
            authenticationView()
        }
    }
    
    // MARK: - Authenticated Views
    @ViewBuilder
    private func authenticatedView() -> some View {
        // Handle the case where role might be nil
        if let role = authVM.role {
            switch role {
            case .client:
                ClientDashboardView()
                    .onAppear {
                        print("📱 Showing ClientDashboardView - User: gamikapunsisi at 2025-08-20 06:23:57")
                    }
                    .accessibility(identifier: "client-dashboard")
                    
            case .tasker:
                TaskerDashboardView()
                    .onAppear {
                        print("👷 Showing TaskerDashboardView - User: gamikapunsisi at 2025-08-20 06:23:57")
                    }
                    .accessibility(identifier: "tasker-dashboard")
            }
        } else {
            // Show loading state when role is nil
            ProgressView("Loading role...")
                .onAppear {
                    print("⏳ Loading user role - User: gamikapunsisi at 2025-08-20 06:23:57")
                    authVM.fetchUserRole()
                }
                .accessibility(identifier: "loading-role")
        }
    }
    
    // MARK: - Authentication Views
    @ViewBuilder
    private func authenticationView() -> some View {
        VStack(spacing: 20) {
            switch currentScreen {
            case .signup:
                SignUpView()
                    .environmentObject(authVM)
                    .transition(.slide)
                    .accessibility(identifier: "signup-view")

                Button("Already have an account? Log In") {
                    withAnimation {
                        currentScreen = .login
                        print("🔄 Switched to login screen - User: gamikapunsisi at 2025-08-20 06:23:57")
                    }
                    authVM.errorMessage = nil
                }
                .padding(.top, 8)
                .accessibility(identifier: "switch-to-login")

            case .login:
                LoginView()
                    .environmentObject(authVM)
                    .transition(.slide)
                    .accessibility(identifier: "login-view")

                Button("Don't have an account? Sign Up") {
                    withAnimation {
                        currentScreen = .signup
                        print("🔄 Switched to signup screen - User: gamikapunsisi at 2025-08-20 06:23:57")
                    }
                    authVM.errorMessage = nil
                }
                .padding(.top, 8)
                .accessibility(identifier: "switch-to-signup")
            }
        }
        .padding()
        .accessibility(identifier: "authentication-container")
    }
    
    // MARK: - Lifecycle Methods
    private func handleRootViewAppear() {
        print("🏠 RootView appeared - User: gamikapunsisi at 2025-08-20 06:23:57")
        
        if isUITesting {
            print("🧪 RootView in UI Testing mode")
            setupUITestingState()
        } else {
            print("✅ RootView in normal mode")
            print("🔐 Auth state: \(authVM.isLoggedIn ? "Logged in" : "Not logged in")")
            if authVM.isLoggedIn {
                print("👤 User role: \(authVM.role?.rawValue ?? "unknown")")
            }
        }
    }
    
    private func setupUITestingState() {
        // Apply any additional UI testing setup if needed
        if UserDefaults.standard.bool(forKey: "MOCK_AUTHENTICATED") {
            let mockRole = UserDefaults.standard.string(forKey: "MOCK_USER_ROLE") ?? "client"
            print("🧪 Setting up mock authentication state - Role: \(mockRole) - User: gamikapunsisi at 2025-08-20 06:23:57")
            
            // Update AuthViewModel for consistency (if not using Firebase)
            DispatchQueue.main.async {
                self.authVM.isLoggedIn = true
                if let role = UserRole(rawValue: mockRole) {
                    self.authVM.role = role
                }
            }
        }
    }
}

// MARK: - Preview Support
#Preview {
    RootView()
        .environmentObject(AuthViewModel())
}

// MARK: - UI Testing Helper Views
#if DEBUG
struct UITestingRootView: View {
    var body: some View {
        ClientDashboardView()
            .onAppear {
                print("🧪 UITestingRootView: Direct to ClientDashboardView - User: gamikapunsisi at 2025-08-20 06:23:57")
            }
    }
}
#endif
