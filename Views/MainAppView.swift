//
//  MainAppView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-13.
//

import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome! You are logged in.")
                .font(.title)
                .padding()

            Button("Sign Out") {
                authVM.signOut()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}
