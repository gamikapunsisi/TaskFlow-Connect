import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole = .tasker  // ✅ Enum, not String

    let roles: [UserRole] = [.tasker, .client] // ✅ Enum list

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign Up")
                .font(.largeTitle)
                .bold()

            // Email Field
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            // Password Field
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            // Confirm Password Field
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            // Role Picker
            Picker("Select Role", selection: $selectedRole) {
                ForEach(roles, id: \.self) { role in
                    Text(role.rawValue.capitalized) // ✅ "Tasker" / "Client"
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical)

            // Error Message
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            // Sign Up Button
            Button(action: signUp) {
                if authVM.isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(!isFormValid || authVM.isLoading)
        }
        .padding()
    }

    // MARK: - Validation
    private var isFormValid: Bool {
        !email.isEmpty && password.count >= 6 && password == confirmPassword
    }

    // MARK: - Actions
    private func signUp() {
        authVM.signUp(email: email, password: password, role: selectedRole) // ✅ Pass UserRole directly
    }
}
