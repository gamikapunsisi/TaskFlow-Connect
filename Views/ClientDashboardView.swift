import SwiftUI

struct ClientDashboardView: View {
    var body: some View {
        Text("Client Dashboard")
            .font(.largeTitle)
            .padding()
    }
}

#Preview {
    ClientDashboardView()
}

//
//import SwiftUI
//
//struct ClientDashboardView: View {
//    @State private var searchText = ""
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // Background gradient
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.2)]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(spacing: 0) {
//                        // Header Section with Hero Image
//                        ZStack {
//                            // Background image placeholder
//                            RoundedRectangle(cornerRadius: 0)
//                                .fill(
//                                    LinearGradient(
//                                        gradient: Gradient(colors: [Color.green.opacity(0.7), Color.orange.opacity(0.6)]),
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    )
//                                )
//                                .frame(height: 280)
//                                .overlay(
//                                    // Simulated background pattern
//                                    Image(systemName: "scissors")
//                                        .font(.system(size: 60))
//                                        .foregroundColor(.white.opacity(0.3))
//                                        .offset(x: 80, y: 20)
//                                )
//                            
//                            VStack(spacing: 16) {
//                                // Logo and Title
//                                VStack(spacing: 8) {
//                                    Text("TASK")
//                                        .font(.system(size: 36, weight: .bold, design: .rounded))
//                                        .foregroundColor(.black) +
//                                    Text("FLOW")
//                                        .font(.system(size: 36, weight: .bold, design: .rounded))
//                                        .foregroundColor(.purple)
//                                    
//                                    Text("Experts at cutting and coloring hair of all type")
//                                        .font(.system(size: 16, weight: .medium))
//                                        .foregroundColor(.white)
//                                        .multilineTextAlignment(.center)
//                                        .padding(.horizontal, 20)
//                                }
//                                
//                                // Search Bar
//                                HStack {
//                                    Image(systemName: "magnifyingglass")
//                                        .foregroundColor(.gray)
//                                    
//                                    TextField("Search", text: $searchText)
//                                        .textFieldStyle(PlainTextFieldStyle())
//                                }
//                                .padding(.horizontal, 16)
//                                .padding(.vertical, 12)
//                                .background(Color.white.opacity(0.9))
//                                .cornerRadius(25)
//                                .padding(.horizontal, 30)
//                            }
//                        }
//                        
//                        // Services Section
//                        VStack(alignment: .leading, spacing: 20) {
//                            HStack {
//                                Text("Services")
//                                    .font(.system(size: 28, weight: .bold))
//                                    .foregroundColor(.black)
//                                
//                                Text("(8)")
//                                    .font(.system(size: 28, weight: .bold))
//                                    .foregroundColor(.gray)
//                                
//                                Spacer()
//                            }
//                            .padding(.horizontal, 20)
//                            .padding(.top, 30)
//                            
//                            // Services Grid
//                            LazyVGrid(columns: [
//                                GridItem(.flexible(), spacing: 10),
//                                GridItem(.flexible(), spacing: 10)
//                            ], spacing: 15) {
//                                ServiceCard(title: "Plumber", icon: "wrench.and.screwdriver.fill", colors: [.blue.opacity(0.7), .gray.opacity(0.5)])
//                                ServiceCard(title: "Painter", icon: "paintbrush.fill", colors: [.yellow.opacity(0.8), .orange.opacity(0.6)])
//                                ServiceCard(title: "Coconut Picker", icon: "leaf.fill", colors: [.green.opacity(0.7), .brown.opacity(0.4)])
//                                ServiceCard(title: "House Cleaner", icon: "house.fill", colors: [.gray.opacity(0.6), .white.opacity(0.8)])
//                                ServiceCard(title: "Carpenter", icon: "hammer.fill", colors: [.brown.opacity(0.7), .orange.opacity(0.5)])
//                                ServiceCard(title: "Gardener", icon: "leaf.arrow.triangle.circlepath", colors: [.green.opacity(0.8), .mint.opacity(0.6)])
//                                ServiceCard(title: "Landscaping Worker", icon: "mountain.2.fill", colors: [.gray.opacity(0.8), .green.opacity(0.4)])
//                                ServiceCard(title: "Grass Cutter", icon: "scissors", colors: [.green.opacity(0.9), .green.opacity(0.7)])
//                            }
//                            .padding(.horizontal, 20)
//                            
//                            Spacer(minLength: 100)
//                        }
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//        }
//        .overlay(
//            // Bottom Tab Bar
//            VStack {
//                Spacer()
//                CustomTabBar()
//            }
//        )
//    }
//}
//
//struct ServiceCard: View {
//    let title: String
//    let icon: String
//    let colors: [Color]
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 16)
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(colors: colors),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .frame(height: 120)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 16)
//                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                )
//            
//            VStack {
//                Image(systemName: icon)
//                    .font(.system(size: 24, weight: .medium))
//                    .foregroundColor(.white.opacity(0.9))
//                    .padding(.bottom, 8)
//                
//                Text(title)
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                    .lineLimit(2)
//            }
//            .padding()
//        }
//        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//    }
//}
//
//struct CustomTabBar: View {
//    @State private var selectedTab = 0
//    
//    var body: some View {
//        HStack {
//            TabBarButton(icon: "house.fill", isSelected: selectedTab == 0) {
//                selectedTab = 0
//            }
//            
//            Spacer()
//            
//            TabBarButton(icon: "calendar", isSelected: selectedTab == 1) {
//                selectedTab = 1
//            }
//            
//            Spacer()
//            
//            TabBarButton(icon: "person.fill", isSelected: selectedTab == 2) {
//                selectedTab = 2
//            }
//        }
//        .padding(.horizontal, 60)
//        .padding(.vertical, 16)
//        .background(
//            RoundedRectangle(cornerRadius: 30)
//                .fill(Color.black)
//                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -2)
//        )
//        .padding(.horizontal, 30)
//        .padding(.bottom, 30)
//    }
//}
//
//struct TabBarButton: View {
//    let icon: String
//    let isSelected: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            ZStack {
//                if isSelected {
//                    Circle()
//                        .fill(Color.white)
//                        .frame(width: 50, height: 50)
//                        .overlay(
//                            Image(systemName: "calendar")
//                                .font(.system(size: 16, weight: .medium))
//                                .foregroundColor(.black)
//                        )
//                } else {
//                    Image(systemName: icon)
//                        .font(.system(size: 24, weight: .medium))
//                        .foregroundColor(.white)
//                }
//            }
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}
//
//#Preview {
//    ClientDashboardView()
//        .preferredColorScheme(.light)
//}
//
//// Additional Views for Navigation
//struct ServiceDetailView: View {
//    let serviceName: String
//    
//    var body: some View {
//        VStack {
//            Text(serviceName)
//                .font(.largeTitle)
//                .padding()
//            
//            Text("Service details and booking options would go here")
//                .padding()
//            
//            Spacer()
//        }
//        .navigationTitle(serviceName)
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
