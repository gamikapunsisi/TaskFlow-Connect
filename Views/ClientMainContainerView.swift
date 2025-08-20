//
//  ClientMainContainerView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-19.
//  Updated: 2025-08-19 20:52:02 UTC
//

import SwiftUI

struct ClientMainContainerView: View {
    @State private var selectedTab: ClientBottomNavigationBar.TabItem = .home
    @StateObject private var bookingManager = BookingManager()
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            // Main Content based on selected tab
            switch selectedTab {
            case .home:
                ClientDashboardView()
                    .environmentObject(bookingManager) // ✅ Pass BookingManager
            case .bookings:
                ClientBookingsView()
                    .environmentObject(bookingManager) // ✅ Pass BookingManager
            case .profile:
                ClientProfileView()
                    .environmentObject(bookingManager) // ✅ Pass BookingManager
            }
            
            // Bottom Navigation Overlay
            VStack {
                Spacer()
                ClientBottomNavigationBar(selectedTab: $selectedTab)
            }
        }
        .onAppear {
            print("🚀 ClientMainContainerView appeared - User: gamikapunsisi at 2025-08-19 20:52:02")
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }
}

#Preview {
    ClientMainContainerView()
}
