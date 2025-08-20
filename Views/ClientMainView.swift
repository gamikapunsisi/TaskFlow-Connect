//
//  ClientMainView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-19.
//

import SwiftUI

struct ClientMainView: View {
    @State private var selectedTab: ClientBottomNavigationBar.TabItem = .home
    @StateObject private var bookingManager = BookingManager()
    
    var body: some View {
        ZStack {
            // Main Content
            switch selectedTab {
            case .home:
                ClientDashboardView()
            case .bookings:
                ClientBookingsView()
                    .environmentObject(bookingManager)
            case .profile:
                ClientProfileView()
            }
            
            // Bottom Navigation
            VStack {
                Spacer()
                ClientBottomNavigationBar(selectedTab: $selectedTab)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }
}
