//
//  FirebaseManager.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-13.
//

import FirebaseCore

final class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {
        FirebaseApp.configure()
    }
}
