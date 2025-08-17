import SwiftUI
import FirebaseAuth

struct ServicesView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var serviceManager = ServiceManager()
    @State private var showingMyServicesOnly = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Filter Toggle
                    if Auth.auth().currentUser != nil {
                        HStack {
                            Picker("Filter", selection: $showingMyServicesOnly) {
                                Text("All Services").tag(false)
                                Text("My Services").tag(true)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding(.horizontal)
                        .onChange(of: showingMyServicesOnly) { newValue in
                            if newValue {
                                serviceManager.fetchUserServices()
                            } else {
                                serviceManager.fetchServices()
                            }
                        }
                    }
                    
                    // Services Grid
                    if serviceManager.isLoading {
                        ProgressView("Loading services...")
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if serviceManager.services.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No services available")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text("Be the first to add a service!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(serviceManager.services) { service in
                                ServiceCardView(service: service)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Add Service Button
                    AddServiceButton()
                        .padding(.horizontal)
                    
                    // Error Message
                    if let errorMessage = serviceManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }
                }
            }
            .navigationTitle("Services")
            .refreshable {
                if showingMyServicesOnly {
                    serviceManager.fetchUserServices()
                } else {
                    serviceManager.fetchServices()
                }
            }
        }
    }
}

#Preview {
    ServicesView()
}
