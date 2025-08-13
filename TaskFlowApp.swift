//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-07.
//

import SwiftUI

@main
struct TaskFlowApp: App {
    @StateObject private var authVM = AuthViewModel()
    
    init() {
        FirebaseManager.shared  // Initialize Firebase once
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
        }
    }
}
