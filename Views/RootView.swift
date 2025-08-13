//
//  RootView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-13.
//

import SwiftUI

enum AuthScreen {
    case login, signup
}

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var currentScreen: AuthScreen = .signup

    var body: some View {
        if authVM.isLoggedIn {
            MainAppView()
        } else {
            VStack(spacing: 20) {
                switch currentScreen {
                case .signup:
                    SignUpView()
                        .environmentObject(authVM)
                        .transition(.slide)

                    Button("Already have an account? Log In") {
                        withAnimation { currentScreen = .login }
                        authVM.errorMessage = nil
                    }
                    .padding(.top, 8)

                case .login:
                    LoginView()
                        .environmentObject(authVM)
                        .transition(.slide)

                    Button("Don't have an account? Sign Up") {
                        withAnimation { currentScreen = .signup }
                        authVM.errorMessage = nil
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
    }
}
