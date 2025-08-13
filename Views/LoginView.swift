//
//  LoginView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-13.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Log In").font(.largeTitle).bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

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
    }

    private var isFormValid: Bool {
        !email.isEmpty && password.count >= 6
    }

    private func login() {
        authVM.login(email: email, password: password)
    }
}
