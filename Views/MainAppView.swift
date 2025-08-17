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
            // Show dashboard based on role
            if let role = authVM.role {
                switch role {
                case .tasker:
                    Text("Tasker Dashboard")
                        .font(.title)
                        .bold()
                        .padding()
                case .client:
                    Text("Client Dashboard")
                        .font(.title)
                        .bold()
                        .padding()
                }
            } else {
                ProgressView("Loading role…")
            }

            Button("Sign Out") {
                authVM.signOut()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
