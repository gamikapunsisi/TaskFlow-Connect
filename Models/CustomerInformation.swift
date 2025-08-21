//
//  CustomerInformation.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-20.
//  Updated: 2025-08-21 10:32:35 UTC
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UIKit
import CoreLocation
import MapKit
import SwiftUI

// MARK: - Customer Information Model (SINGLE DEFINITION)
struct CustomerInformation: Codable, Identifiable {
    var id: String = UUID().uuidString
    let fullName: String
    let emailAddress: String // Auto-populated from logged-in user
    let phoneNumber: String
    let serviceAddress: String
    let createdAt: Timestamp
    let updatedAt: Timestamp
    let createdBy: String
    let userUID: String // Firebase Auth UID for user isolation
    
    // MapKit integration properties
    let latitude: Double?
    let longitude: Double?
    
    // Additional metadata
    let deviceInfo: [String: String]
    let platform: String
    let version: String
    
    // Primary initializer - Auto-populates email from logged-in user
    init(fullName: String, phoneNumber: String, serviceAddress: String, createdBy: String = "gamikapunsisi") {
        self.fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        self.serviceAddress = serviceAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = Timestamp(date: Date())
        self.updatedAt = Timestamp(date: Date())
        self.createdBy = createdBy
        
        // ✅ Auto-populate email and userUID from logged-in user
        self.emailAddress = Auth.auth().currentUser?.email ?? ""
        self.userUID = Auth.auth().currentUser?.uid ?? ""
        
        // Initialize location as nil (will be set via geocoding)
        self.latitude = nil
        self.longitude = nil
        
        print("📧 Auto-populated email from logged-in user: \(self.emailAddress)")
        print("🔑 User UID: \(self.userUID)")
        print("👤 Created by: \(createdBy)")
        print("📅 Customer info created at: 2025-08-21 10:32:35")
        
        // Device metadata
        self.deviceInfo = [
            "model": UIDevice.current.model,
            "systemName": UIDevice.current.systemName,
            "systemVersion": UIDevice.current.systemVersion,
            "timestamp": "2025-08-21 10:32:35"
        ]
        self.platform = "ios"
        self.version = "1.0"
    }
    
    // ✅ Initializer with location data
    init(fullName: String, phoneNumber: String, serviceAddress: String, latitude: Double?, longitude: Double?, createdBy: String = "gamikapunsisi") {
        self.fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        self.serviceAddress = serviceAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = Timestamp(date: Date())
        self.updatedAt = Timestamp(date: Date())
        self.createdBy = createdBy
        
        // Auto-populate email and userUID from logged-in user
        self.emailAddress = Auth.auth().currentUser?.email ?? ""
        self.userUID = Auth.auth().currentUser?.uid ?? ""
        
        // Set location data
        self.latitude = latitude
        self.longitude = longitude
        
        print("📧 Auto-populated email: \(self.emailAddress)")
        print("🔑 User UID: \(self.userUID)")
        print("📍 Location: \(latitude ?? 0.0), \(longitude ?? 0.0)")
        print("📅 Customer with location created at: 2025-08-21 10:32:35")
        
        // Device metadata
        self.deviceInfo = [
            "model": UIDevice.current.model,
            "systemName": UIDevice.current.systemName,
            "systemVersion": UIDevice.current.systemVersion,
            "timestamp": "2025-08-21 10:32:35"
        ]
        self.platform = "ios"
        self.version = "1.0"
    }
    
    // ✅ Alternative initializer with explicit email (for parsing from Firestore or testing)
    init(fullName: String, emailAddress: String, phoneNumber: String, serviceAddress: String, userUID: String? = nil, latitude: Double? = nil, longitude: Double? = nil, createdBy: String = "gamikapunsisi") {
        self.fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.emailAddress = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        self.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        self.serviceAddress = serviceAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = Timestamp(date: Date())
        self.updatedAt = Timestamp(date: Date())
        self.createdBy = createdBy
        self.userUID = userUID ?? Auth.auth().currentUser?.uid ?? ""
        
        // Set location data
        self.latitude = latitude
        self.longitude = longitude
        
        print("📧 Using explicit email: \(self.emailAddress)")
        print("🔑 User UID: \(self.userUID)")
        print("📍 Explicit init with location at: 2025-08-21 10:32:35")
        
        // Device metadata
        self.deviceInfo = [
            "model": UIDevice.current.model,
            "systemName": UIDevice.current.systemName,
            "systemVersion": UIDevice.current.systemVersion,
            "timestamp": "2025-08-21 10:32:35"
        ]
        self.platform = "ios"
        self.version = "1.0"
    }
    
    // Convert to Firestore dictionary
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "fullName": fullName,
            "emailAddress": emailAddress,
            "phoneNumber": phoneNumber,
            "serviceAddress": serviceAddress,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "createdBy": createdBy,
            "userUID": userUID,
            "deviceInfo": deviceInfo,
            "platform": platform,
            "version": version,
            "timestamp": "2025-08-21 10:32:35 UTC"
        ]
        
        // ✅ Add location data if available
        if let lat = latitude {
            data["latitude"] = lat
        }
        if let lng = longitude {
            data["longitude"] = lng
        }
        
        return data
    }
    
    // Formatted display properties
    var displayName: String {
        fullName.isEmpty ? "Unknown Customer" : fullName
    }
    
    var displayPhone: String {
        phoneNumber.isEmpty ? "No phone" : phoneNumber
    }
    
    var displayEmail: String {
        emailAddress.isEmpty ? "No email" : emailAddress
    }
    
    var displayAddress: String {
        serviceAddress.isEmpty ? "No address" : serviceAddress
    }
    
    var hasEmail: Bool {
        !emailAddress.isEmpty
    }
    
    // ✅ Location-related computed properties
    var hasLocation: Bool {
        latitude != nil && longitude != nil
    }
    
    var isLoggedInUser: Bool {
        return userUID == Auth.auth().currentUser?.uid
    }
    
    var locationDescription: String {
        if let lat = latitude, let lng = longitude {
            return "📍 \(String(format: "%.4f", lat)), \(String(format: "%.4f", lng))"
        }
        return "📍 Location not available"
    }
    
    var locationCoordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lng = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt.dateValue())
    }
    
    // ✅ Validation methods
    func validateRequiredFields() -> [String] {
        var errors: [String] = []
        
        if fullName.isEmpty {
            errors.append("Full name is required")
        }
        
        if phoneNumber.isEmpty {
            errors.append("Phone number is required")
        }
        
        if serviceAddress.isEmpty {
            errors.append("Service address is required")
        }
        
        if emailAddress.isEmpty {
            errors.append("Email address is missing - please ensure you are logged in")
        }
        
        if userUID.isEmpty {
            errors.append("User authentication required")
        }
        
        print("🔍 Customer validation - Errors: \(errors.count) - User: gamikapunsisi at 2025-08-21 10:32:35")
        return errors
    }
    
    var isValid: Bool {
        return validateRequiredFields().isEmpty
    }
    
    // ✅ Create copy with location data
    func withLocation(latitude: Double, longitude: Double) -> CustomerInformation {
        return CustomerInformation(
            fullName: self.fullName,
            emailAddress: self.emailAddress,
            phoneNumber: self.phoneNumber,
            serviceAddress: self.serviceAddress,
            userUID: self.userUID,
            latitude: latitude,
            longitude: longitude,
            createdBy: self.createdBy
        )
    }
    
    // ✅ Distance calculation helper for service routing
    func distanceFrom(_ coordinate: CLLocationCoordinate2D) -> Double? {
        guard let customerCoordinate = locationCoordinate else { return nil }
        
        let customerLocation = CLLocation(latitude: customerCoordinate.latitude, longitude: customerCoordinate.longitude)
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        return customerLocation.distance(from: targetLocation) / 1000 // Convert to kilometers
    }
}

// MARK: - Location Utility Functions (Global Access)
func formatMapItemAddress(_ mapItem: MKMapItem) -> String {
    let placemark = mapItem.placemark
    var addressComponents: [String] = []
    
    if let name = mapItem.name, !name.isEmpty {
        addressComponents.append(name)
    }
    
    if let thoroughfare = placemark.thoroughfare {
        addressComponents.append(thoroughfare)
    }
    
    if let locality = placemark.locality {
        addressComponents.append(locality)
    }
    
    if let administrativeArea = placemark.administrativeArea {
        addressComponents.append(administrativeArea)
    }
    
    return addressComponents.isEmpty ? "Unknown Location" : addressComponents.joined(separator: ", ")
}

func formatPlacemarkAddress(_ placemark: CLPlacemark) -> String {
    var addressComponents: [String] = []
    
    if let name = placemark.name {
        addressComponents.append(name)
    }
    if let locality = placemark.locality {
        addressComponents.append(locality)
    }
    if let administrativeArea = placemark.administrativeArea {
        addressComponents.append(administrativeArea)
    }
    
    return addressComponents.isEmpty ? "Unknown Location" : addressComponents.joined(separator: ", ")
}

// MARK: - Location Selection Data Model
class LocationSelectionData: ObservableObject {
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var selectedAddress: String = ""
    @Published var isUsingCurrentLocation: Bool = false
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var searchResults: [MKMapItem] = []
    @Published var isSearching: Bool = false
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612), // Default to Colombo
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    init() {
        print("📍 LocationSelectionData initialized - User: gamikapunsisi at 2025-08-21 10:32:35")
    }
    
    // Set location from coordinates with reverse geocoding
    func setLocation(coordinate: CLLocationCoordinate2D, address: String? = nil) {
        selectedCoordinate = coordinate
        
        if let providedAddress = address {
            selectedAddress = providedAddress
            print("📍 Location set with provided address: \(providedAddress)")
        } else {
            // Reverse geocode to get address
            Task {
                await reverseGeocodeCoordinate(coordinate)
            }
        }
        
        // Update map region
        mapRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    // Use current location
    func useCurrentLocation() {
        isUsingCurrentLocation = true
        print("📍 Using current location - User: gamikapunsisi at 2025-08-21 10:32:35")
        
        // Request current location
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if let currentLoc = currentLocation {
            setLocation(coordinate: currentLoc)
        } else {
            // Default to Colombo if current location not available
            let colomboCoordinate = CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612)
            setLocation(coordinate: colomboCoordinate, address: "Colombo, Sri Lanka")
            print("📍 Using default location (Colombo) as current location unavailable")
        }
    }
    
    // Search for addresses
    func searchAddresses(_ query: String) async {
        guard !query.isEmpty else {
            await MainActor.run {
                self.searchResults = []
            }
            return
        }
        
        await MainActor.run {
            self.isSearching = true
        }
        
        print("🔍 Searching for addresses: '\(query)' - User: gamikapunsisi at 2025-08-21 10:32:35")
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718), // Sri Lanka center
            span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        )
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            
            await MainActor.run {
                self.searchResults = response.mapItems
                self.isSearching = false
                print("✅ Found \(response.mapItems.count) search results")
            }
            
        } catch {
            print("❌ Failed to search addresses: \(error.localizedDescription)")
            await MainActor.run {
                self.searchResults = []
                self.isSearching = false
            }
        }
    }
    
    // Select from search results
    func selectSearchResult(_ mapItem: MKMapItem) {
        let coordinate = mapItem.placemark.coordinate
        let address = formatMapItemAddress(mapItem)
        
        setLocation(coordinate: coordinate, address: address)
        searchResults = []
        
        print("✅ Selected search result: \(address)")
    }
    
    // Reverse geocode coordinate to address
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) async {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            if let placemark = placemarks.first {
                let address = formatPlacemarkAddress(placemark)
                
                await MainActor.run {
                    self.selectedAddress = address
                }
                
                print("✅ Reverse geocoded to: \(address)")
            }
            
        } catch {
            print("❌ Failed to reverse geocode: \(error.localizedDescription)")
            await MainActor.run {
                self.selectedAddress = "Location selected on map"
            }
        }
    }
    
    // Clear selection
    func clearSelection() {
        selectedCoordinate = nil
        selectedAddress = ""
        isUsingCurrentLocation = false
        searchResults = []
        
        // Reset to default region
        mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        print("🧹 Location selection cleared - User: gamikapunsisi at 2025-08-21 10:32:35")
    }
    
    // Check if location is selected
    var hasSelectedLocation: Bool {
        selectedCoordinate != nil
    }
    
    // Get formatted location string
    var formattedLocation: String {
        if hasSelectedLocation {
            if isUsingCurrentLocation {
                return "📍 Current Location: \(selectedAddress)"
            } else {
                return "📍 Selected: \(selectedAddress)"
            }
        }
        return "📍 No location selected"
    }
}

// MARK: - Address Selection View
struct AddressSelectionView: View {
    @StateObject private var locationData = LocationSelectionData()
    @State private var searchQuery = ""
    @Binding var selectedAddress: String
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for address...", text: $searchQuery)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: searchQuery) { query in
                                Task {
                                    await locationData.searchAddresses(query)
                                }
                            }
                    }
                    
                    // Current Location Button
                    Button(action: {
                        locationData.useCurrentLocation()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Use Current Location")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .shadow(radius: 2)
                
                // Search Results
                if locationData.isSearching {
                    HStack {
                        ProgressView()
                        Text("Searching...")
                    }
                    .padding()
                } else if !locationData.searchResults.isEmpty {
                    List(locationData.searchResults, id: \.self) { mapItem in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mapItem.name ?? "Unknown")
                                .font(.headline)
                            Text(formatMapItemAddress(mapItem))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            locationData.selectSearchResult(mapItem)
                            searchQuery = ""
                        }
                    }
                    .frame(maxHeight: 200)
                }
                
                // Map View
                Map(coordinateRegion: $locationData.mapRegion,
                    interactionModes: .all,
                    showsUserLocation: true,
                    annotationItems: locationData.hasSelectedLocation ? [LocationPin(coordinate: locationData.selectedCoordinate!)] : []) { pin in
                    MapPin(coordinate: pin.coordinate, tint: .red)
                }
                .onTapGesture(coordinateSpace: .local) { location in
                    // Convert tap location to coordinate (this is simplified)
                    // In a real implementation, you'd need to convert screen coordinates to map coordinates
                    let coordinate = locationData.mapRegion.center
                    locationData.setLocation(coordinate: coordinate)
                }
                
                // Selected Location Info
                if locationData.hasSelectedLocation {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Location")
                            .font(.headline)
                        Text(locationData.formattedLocation)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Button("Clear Selection") {
                                locationData.clearSelection()
                            }
                            .foregroundColor(.red)
                            
                            Spacer()
                            
                            Button("Use This Location") {
                                selectedAddress = locationData.selectedAddress
                                selectedCoordinate = locationData.selectedCoordinate
                                presentationMode.wrappedValue.dismiss()
                            }
                            .foregroundColor(.blue)
                            .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .shadow(radius: 2)
                }
            }
            .navigationTitle("Select Address")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// Helper struct for map pins
struct LocationPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - BookingFormData Extension (Enhanced for Auto-Email and Location)
extension BookingFormData {
    // ✅ Updated to use auto-email functionality
    func createCustomerInformation() -> CustomerInformation {
        print("📝 Creating customer information from form data - User: gamikapunsisi at 2025-08-21 10:32:35")
        print("   - Name: \(customerName)")
        print("   - Phone: \(customerPhone)")
        print("   - Address: \(customerAddress)")
        print("   - Email will be auto-populated from logged-in user (overriding form email)")
        
        // ✅ Use the primary initializer that auto-populates email from Firebase Auth
        return CustomerInformation(
            fullName: customerName,
            phoneNumber: customerPhone,
            serviceAddress: customerAddress,
            createdBy: "gamikapunsisi"
        )
    }
    
    // ✅ Create customer info with location data
    func createCustomerInformationWithLocation(latitude: Double?, longitude: Double?) -> CustomerInformation {
        print("📝 Creating customer information with location data - User: gamikapunsisi at 2025-08-21 10:32:35")
        print("   - Name: \(customerName)")
        print("   - Phone: \(customerPhone)")
        print("   - Address: \(customerAddress)")
        print("   - Location: \(latitude ?? 0.0), \(longitude ?? 0.0)")
        print("   - Email will be auto-populated from logged-in user")
        
        return CustomerInformation(
            fullName: customerName,
            phoneNumber: customerPhone,
            serviceAddress: customerAddress,
            latitude: latitude,
            longitude: longitude,
            createdBy: "gamikapunsisi"
        )
    }
    
    // ✅ Update form data from existing customer (for auto-fill)
    func populateFromCustomerInformation(_ customer: CustomerInformation) {
        print("🔄 Auto-filling form from customer information - User: gamikapunsisi at 2025-08-21 10:32:35")
        
        customerName = customer.fullName
        customerPhone = customer.phoneNumber
        customerAddress = customer.serviceAddress
        // ✅ Always use current logged-in user's email, not stored customer email
        customerEmail = Auth.auth().currentUser?.email ?? ""
        
        print("✅ Form auto-filled:")
        print("   - Name: \(customerName)")
        print("   - Phone: \(customerPhone)")
        print("   - Address: \(customerAddress)")
        print("   - Email (from auth): \(customerEmail)")
    }
    
    // ✅ Update address from map selection
    func updateAddressFromMap(address: String, coordinate: CLLocationCoordinate2D?) {
        customerAddress = address
        
        if let coord = coordinate {
            print("📍 Address updated from map selection:")
            print("   - Address: \(address)")
            print("   - Coordinates: \(coord.latitude), \(coord.longitude)")
        }
    }
}

// MARK: - Search and Filter Extensions
extension CustomerInformation {
    func matchesSearchQuery(_ query: String) -> Bool {
        let lowercaseQuery = query.lowercased()
        return fullName.lowercased().contains(lowercaseQuery) ||
               phoneNumber.contains(lowercaseQuery) ||
               emailAddress.lowercased().contains(lowercaseQuery) ||
               serviceAddress.lowercased().contains(lowercaseQuery)
    }
    
    var searchableText: String {
        return "\(fullName) \(phoneNumber) \(emailAddress) \(serviceAddress)".lowercased()
    }
    
    // ✅ Location-based search helpers
    func isWithinRadius(_ radius: Double, from coordinate: CLLocationCoordinate2D) -> Bool {
        guard let distance = distanceFrom(coordinate) else { return false }
        return distance <= radius
    }
}

// MARK: - Comparable for Sorting
extension CustomerInformation: Comparable {
    static func < (lhs: CustomerInformation, rhs: CustomerInformation) -> Bool {
        // Sort by created date (most recent first)
        return lhs.createdAt.dateValue() > rhs.createdAt.dateValue()
    }
    
    static func == (lhs: CustomerInformation, rhs: CustomerInformation) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Customer Information Manager (Enhanced with Location Services)
class CustomerInformationManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var savedCustomers: [CustomerInformation] = []
    @Published var recentCustomers: [CustomerInformation] = []
    @Published var suggestedAddresses: [String] = []
    @Published var isGeocodingAddress = false
    @Published var selectedLocation: CLLocationCoordinate2D?
    
    private var db: Firestore?
    private let geocoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    
    // UI Testing detection
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING") ||
        ProcessInfo.processInfo.arguments.contains("UI-TESTING") ||
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
        UserDefaults.standard.bool(forKey: "UI_TESTING_MODE")
    }
    
    init() {
        print("👥 CustomerInformationManager initialized with enhanced MapKit - User: gamikapunsisi at 2025-08-21 10:32:35")
        setupFirestore()
        setupLocationManager()
        loadRecentCustomers()
    }
    
    private func setupFirestore() {
        if isUITesting {
            print("🧪 CustomerInformationManager: UI Testing mode - Mock Firestore")
            db = nil
        } else {
            db = Firestore.firestore()
            print("🔥 CustomerInformationManager: Firestore initialized")
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = LocationManagerDelegate.shared
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        print("📍 Location manager configured with delegate - User: gamikapunsisi at 2025-08-21 10:32:35")
    }
    
    // MARK: - Enhanced MapKit Integration
    
    // Geocode address to get coordinates
    func geocodeAddress(_ address: String) async -> CLLocationCoordinate2D? {
        guard !address.isEmpty else { return nil }
        
        print("🗺️ Geocoding address: \(address) - User: gamikapunsisi at 2025-08-21 10:32:35")
        
        await MainActor.run {
            self.isGeocodingAddress = true
        }
        
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            
            await MainActor.run {
                self.isGeocodingAddress = false
            }
            
            if let placemark = placemarks.first,
               let location = placemark.location {
                let coordinates = location.coordinate
                print("✅ Geocoded address to coordinates: \(coordinates.latitude), \(coordinates.longitude)")
                
                await MainActor.run {
                    self.selectedLocation = coordinates
                }
                
                return coordinates
            }
            
        } catch {
            print("❌ Failed to geocode address: \(error.localizedDescription)")
            await MainActor.run {
                self.isGeocodingAddress = false
                self.errorMessage = "Failed to locate address: \(error.localizedDescription)"
            }
        }
        
        return nil
    }
    
    // Get current location
    func getCurrentLocation() async -> CLLocationCoordinate2D? {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            print("❌ Location permission not granted")
            return nil
        }
        
        print("📍 Getting current location - User: gamikapunsisi at 2025-08-21 10:32:35")
        
        return await withCheckedContinuation { continuation in
            LocationManagerDelegate.shared.currentLocationContinuation = continuation
            locationManager.requestLocation()
        }
    }
    
    // Search for locations
    func searchLocations(_ query: String) async -> [MKMapItem] {
        guard !query.isEmpty else { return [] }
        
        print("🔍 Searching locations for: '\(query)' - User: gamikapunsisi at 2025-08-21 10:32:35")
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718), // Sri Lanka center
            span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0)
        )
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            print("✅ Found \(response.mapItems.count) location results")
            return response.mapItems
        } catch {
            print("❌ Failed to search locations: \(error.localizedDescription)")
            return []
        }
    }
    
    // Reverse geocode coordinates to address
    func reverseGeocodeLocation(_ coordinate: CLLocationCoordinate2D) async -> String? {
        print("🔄 Reverse geocoding location: \(coordinate.latitude), \(coordinate.longitude)")
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            if let placemark = placemarks.first {
                let address = formatPlacemarkAddress(placemark)
                print("✅ Reverse geocoded to: \(address)")
                return address
            }
            
        } catch {
            print("❌ Failed to reverse geocode location: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    // MARK: - Save Customer Information (Enhanced with Auto-Geocoding)
    func saveCustomerInformation(_ customerInfo: CustomerInformation) async -> Bool {
        print("💾 Saving customer information with enhanced location - User: gamikapunsisi at 2025-08-21 10:32:35")
        print("👤 Customer: \(customerInfo.fullName)")
        print("📧 Email (auto): \(customerInfo.emailAddress)")
        print("📱 Phone: \(customerInfo.phoneNumber)")
        print("🏠 Address: \(customerInfo.serviceAddress)")
        print("🔑 User UID: \(customerInfo.userUID)")
        
        if isUITesting {
            return await mockSaveCustomerInformation(customerInfo)
        }
        
        guard let db = db else {
            await MainActor.run {
                self.errorMessage = "Database not available"
            }
            return false
        }
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        // Geocode the address before saving if no location data exists
        var customerInfoWithLocation = customerInfo
        if !customerInfo.hasLocation {
            if let coordinates = await geocodeAddress(customerInfo.serviceAddress) {
                customerInfoWithLocation = customerInfo.withLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                print("📍 Added location data: \(coordinates.latitude), \(coordinates.longitude)")
            }
        }
        
        do {
            try await db.collection("customer_information")
                .document(customerInfoWithLocation.id)
                .setData(customerInfoWithLocation.toFirestoreData())
            
            await MainActor.run {
                self.isLoading = false
                
                // Add to saved customers if not already exists
                if !self.savedCustomers.contains(where: { $0.id == customerInfoWithLocation.id }) {
                    self.savedCustomers.append(customerInfoWithLocation)
                }
                
                // Add to recent customers at the top
                if !self.recentCustomers.contains(where: { $0.id == customerInfoWithLocation.id }) {
                    self.recentCustomers.insert(customerInfoWithLocation, at: 0)
                    
                    // Keep only recent 10 customers
                    if self.recentCustomers.count > 10 {
                        self.recentCustomers = Array(self.recentCustomers.prefix(10))
                    }
                }
            }
            
            print("✅ Customer information saved successfully with location - ID: \(customerInfoWithLocation.id)")
            return true
            
        } catch {
            print("❌ Failed to save customer information: \(error.localizedDescription)")
            
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to save customer information: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    private func mockSaveCustomerInformation(_ customerInfo: CustomerInformation) async -> Bool {
        print("🧪 Mock saving customer information with location - User: gamikapunsisi at 2025-08-21 10:32:35")
        
        await MainActor.run {
            self.isLoading = true
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await MainActor.run {
            self.isLoading = false
            self.savedCustomers.append(customerInfo)
            self.recentCustomers.insert(customerInfo, at: 0)
            
            // Keep only recent 10 for mock data
            if self.recentCustomers.count > 10 {
                self.recentCustomers = Array(self.recentCustomers.prefix(10))
            }
        }
        
        return true
    }
    
    // MARK: - Auto-fill Functionality (Enhanced with Location)
    func autoFillCustomerInformation(phoneNumber: String, formData: BookingFormData) async {
        print("🔄 Attempting enhanced auto-fill for phone: \(phoneNumber) - User: gamikapunsisi at 2025-08-21 10:32:35")
        
        // First check recent customers for faster lookup
        if let recentCustomer = getRecentCustomerByPhone(phoneNumber) {
            await MainActor.run {
                formData.populateFromCustomerInformation(recentCustomer)
            }
            
            // Set location if available
            if let coordinate = recentCustomer.locationCoordinate {
                await MainActor.run {
                    self.selectedLocation = coordinate
                }
            }
            
            print("✅ Auto-filled from recent customers with location - User: gamikapunsisi at 2025-08-21 10:32:35")
            return
        }
        
        // If not in recent, fetch from database
        if let existingCustomer = await fetchCustomerInformation(by: phoneNumber) {
            await MainActor.run {
                formData.populateFromCustomerInformation(existingCustomer)
            }
            
            // Set location if available
            if let coordinate = existingCustomer.locationCoordinate {
                await MainActor.run {
                    self.selectedLocation = coordinate
                }
            }
            
            print("✅ Auto-filled from database with location - User: gamikapunsisi at 2025-08-21 10:32:35")
        } else {
            // For new customers, just set the email from logged-in user
            await MainActor.run {
                formData.customerEmail = Auth.auth().currentUser?.email ?? ""
            }
            
            print("ℹ️ No existing customer data found - Email set to logged-in user")
        }
    }
    
    // MARK: - Fetch Customer Information (Filter by current user)
    func fetchCustomerInformation(by phoneNumber: String) async -> CustomerInformation? {
        guard !isUITesting else {
            return mockFetchCustomerInformation(by: phoneNumber)
        }
        
        guard let db = db, let currentUser = Auth.auth().currentUser else {
            print("❌ No database or logged-in user available")
            return nil
        }
        
        print("🔍 Fetching customer information for phone: \(phoneNumber)")
        print("🔑 Current user UID: \(currentUser.uid)")
        
        do {
            let snapshot = try await db.collection("customer_information")
                .whereField("phoneNumber", isEqualTo: phoneNumber)
                .whereField("userUID", isEqualTo: currentUser.uid)
                .limit(to: 1)
                .getDocuments()
            
            if let document = snapshot.documents.first {
                let customerInfo = parseCustomerInformation(from: document.data())
                print("✅ Found customer information for current user with location")
                return customerInfo
            }
            
            print("ℹ️ No customer information found for phone: \(phoneNumber)")
            return nil
            
        } catch {
            print("❌ Failed to fetch customer information: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func mockFetchCustomerInformation(by phoneNumber: String) -> CustomerInformation? {
        return savedCustomers.first { customer in
            customer.phoneNumber == phoneNumber && customer.isLoggedInUser
        }
    }
    
    // MARK: - Load Recent Customers for Current User (Enhanced)
    private func loadRecentCustomers() {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ No logged-in user - cannot load recent customers")
            return
        }
        
        if isUITesting {
            loadMockRecentCustomers()
            return
        }
        
        guard let db = db else { return }
        
        print("📋 Loading recent customers with location for user: \(currentUser.uid)")
        
        Task {
            do {
                let querySnapshot = try await db.collection("customer_information")
                    .whereField("userUID", isEqualTo: currentUser.uid)
                    .order(by: "createdAt", descending: true)
                    .limit(to: 10)
                    .getDocuments()
                
                let customers = querySnapshot.documents.compactMap { document -> CustomerInformation? in
                    return parseCustomerInformation(from: document.data())
                }
                
                await MainActor.run {
                    self.recentCustomers = customers
                    print("✅ Loaded \(customers.count) recent customers with location - User: gamikapunsisi at 2025-08-21 10:32:35")
                }
                
            } catch {
                print("❌ Failed to load recent customers: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = "Failed to load recent customers: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func loadMockRecentCustomers() {
        print("🧪 Loading mock recent customers with location - User: gamikapunsisi at 2025-08-21 10:32:35")
        
        let mockCustomers = [
            CustomerInformation(
                fullName: "John Doe",
                emailAddress: "gamikapunsisi@taskflow.lk",
                phoneNumber: "+94771234567",
                serviceAddress: "123 Main Street, Colombo 07",
                userUID: "mock-user-uid",
                latitude: 6.9271,
                longitude: 79.8612,
                createdBy: "gamikapunsisi"
            ),
            CustomerInformation(
                fullName: "Jane Smith",
                emailAddress: "gamikapunsisi@taskflow.lk",
                phoneNumber: "+94771234568",
                serviceAddress: "456 Queen Street, Kandy",
                userUID: "mock-user-uid",
                latitude: 7.2906,
                longitude: 80.6337,
                createdBy: "gamikapunsisi"
            )
        ]
        
        recentCustomers = mockCustomers
    }
    
    private func parseCustomerInformation(from data: [String: Any]) -> CustomerInformation? {
        guard let fullName = data["fullName"] as? String,
              let phoneNumber = data["phoneNumber"] as? String,
              let serviceAddress = data["serviceAddress"] as? String else {
            return nil
        }
        
        let emailAddress = data["emailAddress"] as? String ?? Auth.auth().currentUser?.email ?? ""
        let createdBy = data["createdBy"] as? String ?? "gamikapunsisi"
        let userUID = data["userUID"] as? String ?? Auth.auth().currentUser?.uid ?? ""
        let latitude = data["latitude"] as? Double
        let longitude = data["longitude"] as? Double
        
        return CustomerInformation(
            fullName: fullName,
            emailAddress: emailAddress,
            phoneNumber: phoneNumber,
            serviceAddress: serviceAddress,
            userUID: userUID,
            latitude: latitude,
            longitude: longitude,
            createdBy: createdBy
        )
    }
    
    // MARK: - Utility Methods (Enhanced)
    func getRecentCustomerByPhone(_ phoneNumber: String) -> CustomerInformation? {
        return recentCustomers.first { customer in
            customer.phoneNumber == phoneNumber && customer.isLoggedInUser
        }
    }
    
    func clearRecentCustomers() {
        recentCustomers.removeAll()
        selectedLocation = nil
        suggestedAddresses.removeAll()
        print("🧹 Recent customers and location data cleared - User: gamikapunsisi at 2025-08-21 10:32:35")
    }
    
    func getCustomerCount() -> Int {
        return recentCustomers.count
    }
    
    func getUniqueCustomerCount() -> Int {
        let uniquePhones = Set(recentCustomers.map { $0.phoneNumber })
        return uniquePhones.count
    }
    
    // MARK: - Enhanced Search and Filter with Location
    func searchCustomers(by query: String) -> [CustomerInformation] {
        guard !query.isEmpty else { return recentCustomers }
        
        let lowercaseQuery = query.lowercased()
        return recentCustomers.filter { customer in
            customer.fullName.lowercased().contains(lowercaseQuery) ||
            customer.phoneNumber.contains(lowercaseQuery) ||
            customer.serviceAddress.lowercased().contains(lowercaseQuery)
        }
    }
    
    func getCustomersNearLocation(_ location: CLLocationCoordinate2D, radius: Double = 10.0) -> [CustomerInformation] {
        return recentCustomers.filter { customer in
            guard let customerCoordinate = customer.locationCoordinate else {
                return false
            }
            
            let customerLocation = CLLocation(latitude: customerCoordinate.latitude, longitude: customerCoordinate.longitude)
            let targetLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = customerLocation.distance(from: targetLocation) / 1000 // Convert to kilometers
            
            return distance <= radius
        }
    }
    
    // Calculate distance between two locations
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation) / 1000 // Convert to kilometers
    }
}

// MARK: - Location Manager Delegate
class LocationManagerDelegate: NSObject, CLLocationManagerDelegate, ObservableObject {
    static let shared = LocationManagerDelegate()
    
    var currentLocationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            currentLocationContinuation?.resume(returning: nil)
            currentLocationContinuation = nil
            return
        }
        
        print("📍 Current location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        currentLocationContinuation?.resume(returning: location.coordinate)
        currentLocationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Failed to get current location: \(error.localizedDescription)")
        currentLocationContinuation?.resume(returning: nil)
        currentLocationContinuation = nil
    }
}

// MARK: - Extensions
extension CustomerInformationManager {
    var hasRecentCustomers: Bool {
        !recentCustomers.isEmpty
    }
    
    var mostRecentCustomer: CustomerInformation? {
        recentCustomers.first
    }
    
    func getFrequentAddresses() -> [String] {
        let addresses = recentCustomers.map { $0.serviceAddress }
        let addressCounts = Dictionary(grouping: addresses, by: { $0 })
        return addressCounts.sorted { $0.value.count > $1.value.count }
                           .prefix(5)
                           .map { $0.key }
    }
    
    var hasLocationPermission: Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse ||
               locationManager.authorizationStatus == .authorizedAlways
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        print("📍 Requesting location permission - User: gamikapunsisi at 2025-08-21 10:32:35")
    }
}

// MARK: - Preview Support
#if DEBUG
extension CustomerInformation {
    static let mockCustomer = CustomerInformation(
        fullName: "John Doe",
        emailAddress: "gamikapunsisi@taskflow.lk",
        phoneNumber: "+94771234567",
        serviceAddress: "123 Main Street, Colombo 07",
        userUID: "mock-user-uid-20250821",
        latitude: 6.9271,
        longitude: 79.8612,
        createdBy: "gamikapunsisi"
    )
    
    static let mockCustomers = [
        CustomerInformation(
            fullName: "Jane Smith",
            emailAddress: "gamikapunsisi@taskflow.lk",
            phoneNumber: "+94771234568",
            serviceAddress: "456 Queen Street, Kandy",
            userUID: "mock-user-uid-20250821",
            latitude: 7.2906,
            longitude: 80.6337,
            createdBy: "gamikapunsisi"
        ),
        CustomerInformation(
            fullName: "Bob Wilson",
            emailAddress: "gamikapunsisi@taskflow.lk",
            phoneNumber: "+94771234569",
            serviceAddress: "789 King Street, Galle",
            userUID: "mock-user-uid-20250821",
            latitude: 6.0535,
            longitude: 80.2210,
            createdBy: "gamikapunsisi"
        ),
        CustomerInformation(
            fullName: "Alice Johnson",
            emailAddress: "gamikapunsisi@taskflow.lk",
            phoneNumber: "+94771234570",
            serviceAddress: "321 Park Road, Negombo",
            userUID: "mock-user-uid-20250821",
            createdBy: "gamikapunsisi"
        )
    ]
}
#endif
