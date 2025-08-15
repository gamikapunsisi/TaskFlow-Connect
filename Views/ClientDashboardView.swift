//
//  ClientDashboardView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-14.
//

import SwiftUI
import FirebaseAuth

struct ClientDashboardView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Client Dashboard")
                    .font(.largeTitle)
                    .bold()

                Text("Welcome, \(Auth.auth().currentUser?.email ?? "Client")")
                    .foregroundColor(.gray)

                NavigationLink(destination: CreateTaskView()) {
                    Text("Create New Task")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                NavigationLink(destination: MyTasksView()) {
                    Text("My Posted Tasks")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        print("Error signing out: \(error)")
                    }
                }) {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

struct ClientDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ClientDashboardView()
    }
}
