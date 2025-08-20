//
//  ClientBottomNavigationBar.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-19.
//

import SwiftUI

struct ClientBottomNavigationBar: View {
    @Binding var selectedTab: TabItem
    
    enum TabItem: String, CaseIterable {
        case home = "home"
        case bookings = "bookings"
        case profile = "profile"
        
        var title: String {
            switch self {
            case .home:
                return "Home"
            case .bookings:
                return "My Bookings"
            case .profile:
                return "Profile"
            }
        }
        
        var icon: String {
            switch self {
            case .home:
                return "house"
            case .bookings:
                return "calendar"
            case .profile:
                return "person"
            }
        }
        
        var filledIcon: String {
            switch self {
            case .home:
                return "house.fill"
            case .bookings:
                return "calendar.fill"
            case .profile:
                return "person.fill"
            }
        }
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            // Home Button
            Button(action: {
                print("🏠 Home tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
                selectedTab = .home
            }) {
                VStack(spacing: 4) {
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(selectedTab == .home ? .white : .gray)
                    
                    Text("Home")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(selectedTab == .home ? .white : .gray)
                }
            }
            
            Spacer()
            
            // Bookings Button (Center - Highlighted)
            Button(action: {
                print("📅 Bookings tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
                selectedTab = .bookings
            }) {
                ZStack {
                    Circle()
                        .fill(selectedTab == .bookings ? Color.blue : Color.white)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    VStack(spacing: 2) {
                        Image(systemName: selectedTab == .bookings ? "calendar.fill" : "calendar")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(selectedTab == .bookings ? .white : .black)
                        
                        Text("Bookings")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(selectedTab == .bookings ? .white : .black)
                    }
                }
            }
            
            Spacer()
            
            // Profile Button
            Button(action: {
                print("👤 Profile tapped - User: gamikapunsisi at 2025-08-19 13:51:05")
                selectedTab = .profile
            }) {
                VStack(spacing: 4) {
                    Image(systemName: selectedTab == .profile ? "person.fill" : "person")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(selectedTab == .profile ? .white : .gray)
                    
                    Text("Profile")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(selectedTab == .profile ? .white : .gray)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 30)
        .background(
            Color.black
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -2)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}
