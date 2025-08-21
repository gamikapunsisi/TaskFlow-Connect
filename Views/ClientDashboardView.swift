//
//  ClientDashboardView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-20.
//  Updated: 2025-08-20 16:02:31 UTC
//

import SwiftUI
import Firebase

struct ClientDashboardView: View {
    @StateObject private var serviceManager = ServiceManager()
    @StateObject private var bookingManager = BookingManager()
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showingNotificationPermission = false
    @State private var showingProfile = false
    @State private var searchText = ""
    @State private var selectedService: Service?
    @State private var showingSearchResults = false
    
    // Filter services based on search
    var filteredServices: [Service] {
        if searchText.isEmpty {
            return serviceManager.services
        } else {
            return serviceManager.services.filter { service in
                service.name.localizedCaseInsensitiveContains(searchText) ||
                service.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Group services by category for better display
    var groupedServices: [String: [Service]] {
        Dictionary(grouping: filteredServices) { service in
            categorizeService(service.name)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // MARK: - Hero Section with Profile
                        heroSectionWithProfile
                        
                        // MARK: - Services Section
                        servicesSection
                    }
                }
                .refreshable {
                    print("🔄 Refreshing services - User: gamikapunsisi at 2025-08-20 16:02:31")
                    serviceManager.refreshServices()
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(item: $selectedService) { service in
            BookingNavigationFlow(service: service, bookingManager: bookingManager)
        }
        .sheet(isPresented: $showingNotificationPermission) {
            NotificationPermissionView(showingPermissionRequest: $showingNotificationPermission)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(authVM: authVM)
        }
        .onAppear {
            print("🚀 ClientDashboardView appeared - User: gamikapunsisi at 2025-08-20 16:02:31")
            serviceManager.fetchServices()
            
            // Check notification permission after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if !notificationManager.isAuthorized {
                    showingNotificationPermission = true
                }
            }
        }
    }
    
    // MARK: - Hero Section with Profile Icon
    private var heroSectionWithProfile: some View {
        ZStack {
            // Background with Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.green.opacity(0.8),
                    Color.blue.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                Image(systemName: "leaf.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white.opacity(0.1))
                    .rotationEffect(.degrees(45))
                    .offset(x: 50, y: -50)
            )
            .frame(height: 280)
            
            VStack(spacing: 0) {
                // Top section with profile icon
                HStack {
                    Spacer()
                    
                    // Profile Button
                    Button(action: {
                        print("👤 Profile icon tapped - User: gamikapunsisi at 2025-08-20 16:02:31")
                        showingProfile = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            // Profile image or default icon - Fixed to use Firebase User properties
                            if let photoURL = authVM.currentUser?.photoURL?.absoluteString, !photoURL.isEmpty {
                                AsyncImage(url: URL(string: photoURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 36, height: 36)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            } else {
                                // Use initials or default icon
                                if let displayName = authVM.currentUser?.displayName, !displayName.isEmpty {
                                    Text(getInitials(from: displayName))
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                        }
                    }
                    .accessibilityIdentifier("profile-button")
                    .accessibilityLabel("Profile")
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Center content
                VStack(spacing: 20) {
                    // TASKFLOW Title
                    HStack {
                        Text("TASK")
                            .font(.system(size: 32, weight: .heavy, design: .default))
                            .foregroundColor(.white)
                        Text("FLOW")
                            .font(.system(size: 32, weight: .heavy, design: .default))
                            .foregroundColor(.purple)
                    }
                    .accessibilityIdentifier("TaskFlowTitle")
                    
                    // Dynamic Subtitle
                    Text(getSubtitleText())
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Search Bar
                    searchBar
                }
                
                Spacer()
            }
        }
        .frame(height: 280)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            HStack {
                TextField("Search services...", text: $searchText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: searchText) { oldValue, newValue in
                        showingSearchResults = !newValue.isEmpty
                        print("🔍 Search text changed: '\(newValue)' - User: gamikapunsisi at 2025-08-20 16:02:31")
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        showingSearchResults = false
                        hideKeyboard()
                        print("❌ Search cleared - User: gamikapunsisi at 2025-08-20 16:02:31")
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                } else {
                    Button(action: {
                        performSearch()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Color.black.opacity(0.3)
            )
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - Services Section
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Services Header
            HStack {
                Text(showingSearchResults ? "Search Results" : "Available Services")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("(\(filteredServices.count))")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Refresh Button
                Button(action: {
                    print("🔄 Manual refresh triggered - User: gamikapunsisi at 2025-08-20 16:02:31")
                    serviceManager.refreshServices()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(serviceManager.isLoading ? 360 : 0))
                        .animation(
                            serviceManager.isLoading ?
                            Animation.linear(duration: 1).repeatForever(autoreverses: false) :
                            Animation.default,
                            value: serviceManager.isLoading
                        )
                }
                .disabled(serviceManager.isLoading)
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            
            // Content based on state
            if serviceManager.isLoading && serviceManager.services.isEmpty {
                LoadingStateView()
            } else if let errorMessage = serviceManager.errorMessage {
                ErrorStateView(errorMessage: errorMessage) {
                    serviceManager.fetchServices()
                }
            } else if filteredServices.isEmpty {
                EmptyStateView(isSearching: showingSearchResults) {
                    searchText = ""
                    showingSearchResults = false
                }
            } else {
                servicesGrid
            }
            
            Spacer(minLength: 120)
        }
    }
    
    // MARK: - Services Grid
    private var servicesGrid: some View {
        Group {
            if showingSearchResults {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 15) {
                    ForEach(filteredServices, id: \.id) { service in
                        ClientServiceCard(service: service) {
                            print("🎯 Service card tapped: \(service.name) - User: gamikapunsisi at 2025-08-20 16:02:31")
                            selectedService = service
                        }
                    }
                }
                .padding(.horizontal, 20)
            } else {
                ForEach(Array(groupedServices.keys.sorted()), id: \.self) { category in
                    if let categoryServices = groupedServices[category], !categoryServices.isEmpty {
                        CategorySectionView(
                            category: category,
                            services: categoryServices,
                            onServiceTap: { service in
                                print("🎯 Service tapped in category '\(category)': \(service.name) - User: gamikapunsisi at 2025-08-20 16:02:31")
                                selectedService = service
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getSubtitleText() -> String {
        let serviceCount = serviceManager.services.count
        if serviceCount == 0 {
            return "Find and hire professional service providers"
        } else {
            return "Choose from \(serviceCount) professional services available"
        }
    }
    
    private func getInitials(from name: String) -> String {
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].first ?? "T") + String(words[1].first ?? "F")
        } else if let firstWord = words.first {
            return String(firstWord.prefix(2)).uppercased()
        }
        return "TF"
    }
    
    private func categorizeService(_ serviceName: String) -> String {
        let name = serviceName.lowercased()
        
        if name.contains("clean") || name.contains("house") {
            return "🏠 Home Services"
        } else if name.contains("garden") || name.contains("grass") || name.contains("coconut") || name.contains("landscap") {
            return "🌿 Garden & Outdoor"
        } else if name.contains("plumb") || name.contains("electric") || name.contains("repair") {
            return "🔧 Maintenance"
        } else if name.contains("paint") || name.contains("carpen") || name.contains("construct") {
            return "🎨 Construction & Craft"
        } else if name.contains("beauty") || name.contains("hair") || name.contains("massage") {
            return "💄 Beauty & Wellness"
        } else if name.contains("tutoring") || name.contains("teach") || name.contains("lesson") {
            return "📚 Education"
        } else {
            return "⚡ Other Services"
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        showingSearchResults = true
        print("🔍 Searching for: '\(searchText)' - User: gamikapunsisi at 2025-08-20 16:02:31")
        print("📊 Found \(filteredServices.count) matching services")
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Client Service Card
struct ClientServiceCard: View {
    let service: Service
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            print("🔘 ClientServiceCard button pressed: \(service.name) - User: gamikapunsisi at 2025-08-20 16:02:31")
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Service Image
                AsyncImage(url: URL(string: service.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.6),
                                Color.purple.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        Image(systemName: getServiceIcon(service.name))
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 100)
                .cornerRadius(12)
                .clipped()
                
                // Service Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(service.displayPrice)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text(service.estimatedTime)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 8)
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
    
    private func getServiceIcon(_ serviceName: String) -> String {
        let name = serviceName.lowercased()
        
        if name.contains("clean") {
            return "sparkles"
        } else if name.contains("garden") || name.contains("grass") {
            return "leaf"
        } else if name.contains("coconut") {
            return "tree"
        } else if name.contains("plumb") {
            return "wrench"
        } else if name.contains("paint") {
            return "paintbrush"
        } else if name.contains("carpen") {
            return "hammer"
        } else if name.contains("electric") {
            return "bolt"
        } else if name.contains("beauty") || name.contains("hair") {
            return "scissors"
        } else {
            return "briefcase"
        }
    }
}

// MARK: - Category Section View
struct CategorySectionView: View {
    let category: String
    let services: [Service]
    let onServiceTap: (Service) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(category)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("(\(services.count))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 15) {
                ForEach(services, id: \.id) { service in
                    ClientServiceCard(service: service) {
                        print("📂 Service selected from \(category): \(service.name) - User: gamikapunsisi at 2025-08-20 16:02:31")
                        onServiceTap(service)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 10)
    }
}

// MARK: - Loading State View
struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            Text("Loading services...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            Text("User: gamikapunsisi • 2025-08-20 16:02:31")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .onAppear {
            print("⏳ Loading state displayed - User: gamikapunsisi at 2025-08-20 16:02:31")
        }
    }
}

// MARK: - Error State View
struct ErrorStateView: View {
    let errorMessage: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Oops! Something went wrong")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(errorMessage)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                print("🔄 Retry attempt - User: gamikapunsisi at 2025-08-20 16:02:31")
                onRetry()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
        .onAppear {
            print("❌ Error state displayed: \(errorMessage) - User: gamikapunsisi at 2025-08-20 16:02:31")
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let isSearching: Bool
    let onClearSearch: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isSearching ? "magnifyingglass" : "briefcase")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text(isSearching ? "No services found" : "No services available")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(isSearching ?
                 "Try searching with different keywords" :
                 "Check back later for new services")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if isSearching {
                Button("Clear Search") {
                    print("🗑️ Clear search tapped - User: gamikapunsisi at 2025-08-20 16:02:31")
                    onClearSearch()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Text("User: gamikapunsisi • 2025-08-20 16:02:31")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
        .onAppear {
            print("📋 Empty state displayed - Search: \(isSearching) - User: gamikapunsisi at 2025-08-20 16:02:31")
        }
    }
}

#Preview {
    ClientDashboardView()
        .environmentObject(NotificationManager.shared)
        .environmentObject(AuthViewModel())
}
