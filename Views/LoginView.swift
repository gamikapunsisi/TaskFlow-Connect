import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Log In").font(.largeTitle).bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .focused($focusedField, equals: .email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .onSubmit { focusedField = .password }

            SecureField("Password", text: $password)
                .focused($focusedField, equals: .password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .onSubmit { 
                    focusedField = nil
                    if isFormValid {
                        login()
                    }
                }

            if let error = authVM.errorMessage {
                Text(error).foregroundColor(.red).font(.caption)
            }

            Button(action: login) {
                if authVM.isLoading {
                    ProgressView()
                } else {
                    Text("Log In")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(!isFormValid || authVM.isLoading)
        }
        .keyboardAvoidance()
        .keyboardToolbar(dismissAction: { focusedField = nil })
    }

    private var isFormValid: Bool {
        !email.isEmpty && password.count >= 6
    }

    private func login() {
        focusedField = nil
        authVM.login(email: email, password: password)
    }
}
