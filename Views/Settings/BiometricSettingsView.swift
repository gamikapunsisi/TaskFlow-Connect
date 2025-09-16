//
//  BiometricSettingsView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-21.
//  Updated: 2025-08-21 18:06:48 UTC
//

import SwiftUI

// MARK: - Biometric Settings View Model
class BiometricSettingsViewModel: ObservableObject {
    @Published var showingBiometricSetup = false
    @Published var setupResult: String?
    @Published var isSettingUp = false
    
    private let biometricManager = BiometricAuthManager.shared
    
    func toggleBiometricAuth() async {
        await MainActor.run {
            self.isSettingUp = true
            self.setupResult = nil
        }
        
        if biometricManager.isBiometricEnabled {
            // Disable biometric auth
            biometricManager.disableBiometricAuth()
            
            await MainActor.run {
                self.isSettingUp = false
                self.setupResult = "Biometric authentication disabled"
            }
        } else {
            // Enable biometric auth
            let success = await biometricManager.enableBiometricAuth()
            
            await MainActor.run {
                self.isSettingUp = false
                self.setupResult = success ?
                    "Biometric authentication enabled successfully!" :
                    "Failed to enable biometric authentication"
            }
        }
    }
    
    func clearSetupResult() {
        setupResult = nil
    }
}

struct BiometricSettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var settingsVM = BiometricSettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    // ✅ Use direct reference to singleton
    private var biometricManager: BiometricAuthManager {
        BiometricAuthManager.shared
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: biometricManager.biometricType.icon)
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Biometric Security")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Secure your TaskFlow account with \(biometricManager.biometricType.displayName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Status Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: biometricManager.isBiometricEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(biometricManager.isBiometricEnabled ? .green : .red)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Status")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                
                                Text(biometricManager.isBiometricEnabled ? "Enabled" : "Disabled")
                                    .font(.headline)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        Text(biometricManager.getBiometricStatusMessage())
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    
                    // Toggle Section
                    if biometricManager.isBiometricAvailable {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Enable \(biometricManager.biometricType.displayName)")
                                        .font(.headline)
                                    
                                    Text("Use your \(biometricManager.biometricType.displayName.lowercased()) to quickly and securely sign in to TaskFlow")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                BiometricToggleButton(
                                    isEnabled: biometricManager.isBiometricEnabled,
                                    isLoading: settingsVM.isSettingUp
                                ) {
                                    Task {
                                        await settingsVM.toggleBiometricAuth()
                                    }
                                }
                            }
                            
                            if settingsVM.isSettingUp {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Setting up biometric authentication...")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if let result = settingsVM.setupResult {
                                HStack {
                                    Image(systemName: result.contains("successfully") ? "checkmark.circle" : "exclamationmark.triangle")
                                        .foregroundColor(result.contains("successfully") ? .green : .red)
                                    
                                    Text(result)
                                        .font(.footnote)
                                        .foregroundColor(result.contains("successfully") ? .green : .red)
                                    
                                    Spacer()
                                    
                                    Button("Dismiss") {
                                        settingsVM.clearSetupResult()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Information Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How it works")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(
                                icon: "shield.fill",
                                title: "Secure Storage",
                                description: "Your credentials are stored securely in the device Keychain"
                            )
                            
                            InfoRow(
                                icon: "touchid",
                                title: "Quick Access",
                                description: "Sign in instantly using your \(biometricManager.biometricType.displayName.lowercased())"
                            )
                            
                            InfoRow(
                                icon: "lock.fill",
                                title: "Privacy First",
                                description: "Biometric data never leaves your device"
                            )
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    
                    // Unavailable State
                    if !biometricManager.isBiometricAvailable {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            
                            Text("Biometric Authentication Unavailable")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Text("Your device doesn't support biometric authentication or it's not set up in Settings.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Open Settings") {
                                openDeviceSettings()
                            }
                            .font(.footnote)
                            .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Test Biometric Button (Debug/Development)
                    #if DEBUG
                    VStack(spacing: 12) {
                        Text("Development Tools")
                            .font(.headline)
                        
                        Button("Test Biometric Authentication") {
                            Task {
                                await testBiometricAuth()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                        
                        Button("Show Debug Info") {
                            showDebugInfo()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                        
                        Button("Refresh Biometric Check") {
                            refreshBiometricCheck()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    #endif
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Biometric Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            print("🔐 BiometricSettingsView appeared - User: gamikapunsisi at 2025-08-21 18:06:48")
            biometricManager.checkBiometricAvailability()
        }
    }
    
    // MARK: - Helper Methods
    
    private func openDeviceSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            print("❌ Cannot open device settings")
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
            print("📱 Opening device settings - User: gamikapunsisi at 2025-08-21 18:06:48")
        }
    }
    
    #if DEBUG
    private func testBiometricAuth() async {
        print("🧪 Testing biometric authentication - User: gamikapunsisi at 2025-08-21 18:06:48")
        
        let result = await biometricManager.authenticateUser(reason: "Test biometric authentication for TaskFlow")
        
        await MainActor.run {
            switch result {
            case .success:
                settingsVM.setupResult = "✅ Biometric test successful!"
            case .failure(let error):
                settingsVM.setupResult = "❌ Biometric test failed: \(error.errorDescription ?? "Unknown error")"
            case .cancelled:
                settingsVM.setupResult = "⚠️ Biometric test cancelled"
            }
        }
    }
    
    private func showDebugInfo() {
        print("🔍 Attempting to get debug info - User: gamikapunsisi at 2025-08-21 18:06:48")
        
        // ✅ Safe access with error handling
        let manager = BiometricAuthManager.shared
        let debugInfo = manager.getBiometricDebugInfo()
        
        print("🔍 Biometric Debug Info:")
        print(debugInfo)
        
        settingsVM.setupResult = "Debug info printed to console. Check Xcode console for details."
    }
    
    private func refreshBiometricCheck() {
        print("🔄 Refreshing biometric availability check - User: gamikapunsisi at 2025-08-21 18:06:48")
        
        let manager = BiometricAuthManager.shared
        let debugCheck = manager.performDebugCheck()
        
        settingsVM.setupResult = "Refresh complete: Available=\(debugCheck.available), Enabled=\(debugCheck.enabled), Type=\(debugCheck.type)"
        
        print("🔄 Debug check result: \(debugCheck)")
    }
    #endif
}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Custom Toggle Button
struct BiometricToggleButton: View {
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isEnabled ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 26, height: 26)
                    .offset(x: isEnabled ? 10 : -10)
                    .animation(.easeInOut(duration: 0.2), value: isEnabled)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(0.6)
                }
            }
        }
        .disabled(isLoading)
    }
}

// MARK: - Preview
#Preview {
    BiometricSettingsView()
        .environmentObject(AuthViewModel())
}
