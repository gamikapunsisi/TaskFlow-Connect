import SwiftUI

struct TaskerDashboardView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    HStack {
                        Text("TaskFlow")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        NavigationLink(destination: TaskerProfileView()) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stats Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "Total Earnings",
                            value: "15000",
                            change: "3 More vs last 7 days",
                            isPositive: true,
                            backgroundColor: Color(red: 0.5, green: 0.8, blue: 0.4)
                        )
                        
                        StatCard(
                            title: "Rejected Contract",
                            value: "5",
                            change: "2 More vs last 7 days",
                            isPositive: false,
                            backgroundColor: Color(red: 0.9, green: 0.4, blue: 0.4)
                        )
                    }
                    .padding(.horizontal)
                    
                    // New Contracts Card (Full Width)
                    HStack {
                        StatCard(
                            title: "New Contracts",
                            value: "20",
                            change: "15 More vs last 7 days",
                            isPositive: true,
                            backgroundColor: Color(red: 0.3, green: 0.6, blue: 0.9)
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons
                    HStack(spacing: 20) {
                        NavigationLink(destination: ServicesView()) {
                            ActionButton(
                                icon: "folder.fill",
                                title: "Services"
                            )
                        }
                        
                        NavigationLink(destination: UpcomingContractsView()) {
                            ActionButton(
                                icon: "doc.text.fill",
                                title: "Contracts"
                            )
                        }
                        
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                    .navigationBarHidden(true)
                }
                .background(Color(UIColor.systemBackground))
            }
        }
    }
    
    // MARK: - StatCard Component
    struct StatCard: View {
        let title: String
        let value: String
        let change: String
        let isPositive: Bool
        let backgroundColor: Color
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(0.9)
                
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                        .font(.system(size: 12, weight: .medium))
                    Text(change)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
                .opacity(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(backgroundColor)
            .cornerRadius(16)
            .shadow(color: backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - ActionButton Component
    struct ActionButton: View {
        let icon: String
        let title: String
        
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.separator), lineWidth: 1)
            )
        }
    }
    
}
