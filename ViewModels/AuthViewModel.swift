//
//  SignInView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-07.
//
import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func signUp(email: String, password: String) {
        guard !email.isEmpty, password.count >= 6 else {
            errorMessage = "Email or password invalid"
            return
        }
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isLoggedIn = true
                }
            }
        }
    }

    func login(email: String, password: String) {
        guard !email.isEmpty, password.count >= 6 else {
            errorMessage = "Email or password invalid"
            return
        }
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isLoggedIn = true
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
