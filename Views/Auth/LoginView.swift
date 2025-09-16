//
//  LoginView.swift
//  TaskFlow
//
//  Updated: 2025-08-21 16:33:58 UTC
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var rememberCredentials = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Sign in to your TaskFlow account")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
            
            // ✅ Biometric Login Option (if available)
            if authVM.shouldShowBiometricPrompt {
                BiometricLoginButton()
                    .padding(.bottom, 10)
                
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    Text("OR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.bottom, 10)
            }

            // Email Field
            VStack(alignment: .leading, spacing: 5) {
                Text("Email")
                    .font(.footnote)
                    .fontWeight(.medium)
                
                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }

            // Password Field
            VStack(alignment: .leading, spacing: 5) {
                Text("Password")
                    .font(.footnote)
                    .fontWeight(.medium)
                
                SecureField("Enter your password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // ✅ Remember Credentials Toggle (for biometric setup)
            if authVM.isBiometricAvailable && !authVM.isBiometricEnabled {
                HStack {
                    Toggle("Remember credentials for \(authVM.biometricType.displayName)", isOn: $rememberCredentials)
                        .font(.footnote)
                    
                    Spacer()
                }
                .padding(.horizontal, 5)
            }

            // Error Message
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // ✅ Biometric Auth Result
            if let biometricResult = authVM.biometricAuthResult {
                Text(biometricResult)
                    .foregroundColor(biometricResult.contains("successful") ? .green : .red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Login Button
            Button(action: login) {
                if authVM.isLoading {
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Signing In...")
                    }
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isFormValid ? Color.green : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(!isFormValid || authVM.isLoading)

            Spacer()
        }
        .padding(.horizontal, 30)
        .onTapGesture {
            hideKeyboard()
        }
    }

    private var isFormValid: Bool {
        !email.isEmpty && password.count >= 6
    }

    private func login() {
        hideKeyboard()
        
        if rememberCredentials {
            // ✅ Use enhanced login with biometric setup
            authVM.loginWithBiometricSetup(email: email, password: password, enableBiometric: true)
        } else {
            // ✅ Use regular login
            authVM.login(email: email, password: password)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// ✅ Biometric Login Button Component
struct BiometricLoginButton: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        Button(action: {
            Task {
                await authVM.loginWithBiometrics()
            }
        }) {
            HStack(spacing: 12) {
                if authVM.isAuthenticatingBiometric {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: authVM.biometricType.icon)
                        .font(.title2)
                }
                
                Text("Sign in with \(authVM.biometricType.displayName)")
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(10)
        .disabled(authVM.isAuthenticatingBiometric)
        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
