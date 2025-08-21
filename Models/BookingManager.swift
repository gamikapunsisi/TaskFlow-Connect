//
//  BookingManager.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-19.
//  Updated: 2025-08-21 11:19:23 UTC
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

// MARK: - Booking Status Enum
enum BookingStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .confirmed:
            return "Confirmed"
        case .inProgress:
            return "In Progress"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }
    
    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .confirmed:
            return .blue
        case .inProgress:
            return .purple
        case .completed:
            return .green
        case .cancelled:
            return .red
        }
    }
    
    var icon: String {
        switch self {
        case .pending:
            return "clock"
        case .confirmed:
            return "checkmark.circle"
        case .inProgress:
            return "gear"
        case .completed:
            return "checkmark.circle.fill"
        case .cancelled:
            return "xmark.circle"
        }
    }
}

// MARK: - Service Booking Model
struct ServiceBooking: Identifiable, Codable {
    let id: String
    let serviceId: String
    let serviceName: String
    let servicePrice: Double
    let estimatedDuration: String
    
    // Customer Information
    let customerName: String
    let customerEmail: String
    let customerPhone: String
    let customerAddress: String
    
    // Scheduling Information
    let scheduledDate: Date
    let scheduledTime: Date
    let notes: String
    
    // Booking Metadata
    let status: BookingStatus
    let paymentStatus: String
    let totalAmount: Double
    let currency: String
    let createdAt: Date
    let updatedAt: Date
    let createdBy: String
    let bookingType: String
    let platform: String
    let version: String
    let deviceInfo: [String: String]
    
    init(
        serviceId: String,
        serviceName: String,
        servicePrice: Double,
        estimatedDuration: String,
        customerName: String,
        customerEmail: String,
        customerPhone: String,
        customerAddress: String,
        scheduledDate: Date,
        scheduledTime: Date,
        notes: String,
        createdBy: String = "gamikapunsisi"
    ) {
        self.id = UUID().uuidString
        self.serviceId = serviceId
        self.serviceName = serviceName
        self.servicePrice = servicePrice
        self.estimatedDuration = estimatedDuration
        
        // Customer Info
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.customerAddress = customerAddress
        
        // Scheduling
        self.scheduledDate = scheduledDate
        self.scheduledTime = scheduledTime
        self.notes = notes
        
        // Metadata
        self.status = .pending
        self.paymentStatus = "pending"
        self.totalAmount = servicePrice
        self.currency = "LKR"
        self.createdAt = Date()
        self.updatedAt = Date()
        self.createdBy = createdBy
        self.bookingType = "client_booking"
        self.platform = "ios"
        self.version = "1.0"
        self.deviceInfo = [
            "model": UIDevice.current.model,
            "systemName": UIDevice.current.systemName,
            "systemVersion": UIDevice.current.systemVersion,
            "timestamp": "2025-08-21 11:19:23"
        ]
    }
    
    // Convert to Firestore dictionary
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "serviceId": serviceId,
            "serviceName": serviceName,
            "servicePrice": servicePrice,
            "estimatedDuration": estimatedDuration,
            "customerName": customerName,
            "customerEmail": customerEmail,
            "customerPhone": customerPhone,
            "customerAddress": customerAddress,
            "scheduledDate": Timestamp(date: scheduledDate),
            "scheduledTime": Timestamp(date: scheduledTime),
            "notes": notes,
            "status": status.rawValue,
            "paymentStatus": paymentStatus,
            "totalAmount": totalAmount,
            "currency": currency,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
            "createdBy": createdBy,
            "bookingType": bookingType,
            "platform": platform,
            "version": version,
            "deviceInfo": deviceInfo,
            "lastUpdated": "2025-08-21 11:19:23 UTC"
        ]
    }
    
    // Formatted display properties
    var formattedPrice: String {
        return "LKR \(String(format: "%.2f", servicePrice))"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: scheduledDate)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: scheduledTime)
    }
}

// MARK: - Enhanced Booking Form Data Model
class BookingFormData: ObservableObject {
    // Step 2: Customer Information
    @Published var customerName = ""
    @Published var customerEmail = ""
    @Published var customerPhone = ""
    @Published var customerAddress = ""
    
    // Step 3: Date & Time Selection
    @Published var scheduledDate = Date()
    @Published var scheduledTime = Date()
    @Published var notes = ""
    
    // Validation states
    @Published var isValidatingCustomerInfo = false
    @Published var customerInfoErrors: [String] = []
    
    init() {
        print("📝 BookingFormData initialized - User: gamikapunsisi at 2025-08-21 11:19:23")
        
        // ✅ Auto-populate email from logged-in user
        customerEmail = Auth.auth().currentUser?.email ?? ""
        print("📧 Auto-populated email from logged-in user: \(customerEmail)")
    }
    
    // MARK: - Validation Methods
    
    func validateCustomerInformation() -> Bool {
        print("🔍 Validating customer information - User: gamikapunsisi at 2025-08-21 11:19:23")
        print("   - Name: '\(customerName)'")
        print("   - Email: '\(customerEmail)'")
        print("   - Phone: '\(customerPhone)'")
        print("   - Address: '\(customerAddress)'")
        
        customerInfoErrors.removeAll()
        
        // Full Name validation
        let trimmedName = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            customerInfoErrors.append("Full name is required")
            print("❌ Name validation failed: Empty")
        } else if trimmedName.count < 2 {
            customerInfoErrors.append("Full name must be at least 2 characters")
            print("❌ Name validation failed: Too short (\(trimmedName.count) chars)")
        } else {
            print("✅ Name validation passed: '\(trimmedName)'")
        }
        
        // Phone Number validation
        let cleanPhone = customerPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanPhone.isEmpty {
            customerInfoErrors.append("Phone number is required")
            print("❌ Phone validation failed: Empty")
        } else if !isValidPhoneNumber(cleanPhone) {
            customerInfoErrors.append("Please enter a valid Sri Lankan phone number")
            print("❌ Phone validation failed: Invalid format '\(cleanPhone)'")
        } else {
            print("✅ Phone validation passed: '\(cleanPhone)'")
        }
        
        // ✅ Enhanced Service Address validation - More flexible for Sri Lankan locations
        let trimmedAddress = customerAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedAddress.isEmpty {
            customerInfoErrors.append("Service address is required")
            print("❌ Address validation failed: Empty")
        } else if trimmedAddress.count < 3 {
            customerInfoErrors.append("Please provide a valid service address")
            print("❌ Address validation failed: Too short (\(trimmedAddress.count) chars)")
        } else if !isValidAddress(trimmedAddress) {
            customerInfoErrors.append("Please provide a more detailed service address")
            print("❌ Address validation failed: Not detailed enough '\(trimmedAddress)'")
        } else {
            print("✅ Address validation passed: '\(trimmedAddress)'")
        }
        
        // ✅ Email validation (now required since it's auto-populated from Firebase Auth)
        let cleanEmail = customerEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanEmail.isEmpty {
            customerInfoErrors.append("Email address is required - please ensure you are logged in")
            print("❌ Email validation failed: Empty (should be auto-populated)")
        } else if !isValidEmail(cleanEmail) {
            customerInfoErrors.append("Please enter a valid email address")
            print("❌ Email validation failed: Invalid format '\(cleanEmail)'")
        } else {
            print("✅ Email validation passed: '\(cleanEmail)'")
        }
        
        let isValid = customerInfoErrors.isEmpty
        
        print("📝 Customer info validation result: \(isValid ? "✅ VALID" : "❌ INVALID") - User: gamikapunsisi at 2025-08-21 11:19:23")
        if !isValid {
            print("🚫 Validation errors (\(customerInfoErrors.count)):")
            for (index, error) in customerInfoErrors.enumerated() {
                print("   \(index + 1). \(error)")
            }
        }
        
        return isValid
    }
    
    // ✅ Enhanced address validation - More flexible for Sri Lankan locations
    private func isValidAddress(_ address: String) -> Bool {
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // List of valid Sri Lankan cities/districts that should be accepted even if short
        let validSriLankanLocations = [
            "colombo", "kandy", "galle", "jaffna", "negombo", "anuradhapura", "trincomalee",
            "batticaloa", "matara", "ratnapura", "kurunegala", "badulla", "monaragala",
            "hambantota", "kalutara", "gampaha", "kegalle", "nuwara eliya", "polonnaruwa",
            "puttalam", "mannar", "vavuniya", "mullaitivu", "kilinochchi", "ampara",
            "dehiwala", "moratuwa", "kotte", "maharagama", "kesbewa", "homagama",
            "panadura", "beruwala", "bentota", "hikkaduwa", "unawatuna", "mirissa",
            "ella", "nuwara", "eliya", "dambulla", "sigiriya", "polonnaruwa",
            "tissamaharama", "kataragama", "yala", "arugam", "bay", "mount lavinia",
            "wellawatte", "bambalapitiya", "kollupitiya", "cinnamon gardens", "borella",
            "nugegoda", "rajagiriya", "battaramulla", "sri jayawardenepura", "kaduwela"
        ]
        
        let lowercaseAddress = trimmedAddress.lowercased()
        
        // Check if it's a recognized Sri Lankan location
        for location in validSriLankanLocations {
            if lowercaseAddress.contains(location) {
                print("✅ Address contains recognized Sri Lankan location: \(location)")
                return true
            }
        }
        
        // If it's not a recognized location, require more detail (at least 8 characters)
        if trimmedAddress.count >= 8 {
            print("✅ Address is detailed enough (\(trimmedAddress.count) chars)")
            return true
        }
        
        // Check if it contains street indicators (more detailed address)
        let streetIndicators = ["street", "st", "road", "rd", "lane", "ln", "avenue", "ave", "drive", "dr",
                               "place", "pl", "close", "crescent", "mawatha", "veediya", "gama", "watta",
                               "gardens", "park", "square", "circle", "cross", "junction", "temple", "church"]
        
        for indicator in streetIndicators {
            if lowercaseAddress.contains(indicator) {
                print("✅ Address contains street indicator: \(indicator)")
                return true
            }
        }
        
        // Check if it has numbers (likely house/building number)
        if trimmedAddress.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil && trimmedAddress.count >= 5 {
            print("✅ Address contains numbers and is reasonably detailed")
            return true
        }
        
        print("❌ Address needs more detail: '\(trimmedAddress)' (\(trimmedAddress.count) chars)")
        return false
    }
    
    // MARK: - Simple validation for button state
    func hasRequiredFields() -> Bool {
        let nameValid = !customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let phoneValid = !customerPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let addressValid = !customerAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emailValid = !customerEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        let hasRequired = nameValid && phoneValid && addressValid && emailValid
        print("📋 Quick field check - Name: \(nameValid), Phone: \(phoneValid), Address: \(addressValid), Email: \(emailValid) = \(hasRequired)")
        
        return hasRequired
    }
    
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        // More flexible Sri Lankan phone number patterns
        let phoneRegexes = [
            "^(\\+94|0)?[1-9][0-9]{8}$",              // Standard format
            "^(\\+94)?7[0-9]{8}$",                    // Mobile format
            "^07[0-9]{8}$",                           // Local mobile format
            "^\\+947[0-9]{8}$",                       // International mobile format
            "^[0-9]{9,10}$"                           // Basic 9-10 digit format
        ]
        
        for regex in phoneRegexes {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            if predicate.evaluate(with: phone) {
                print("✅ Phone number matches pattern: \(regex)")
                return true
            }
        }
        
        print("❌ Phone number '\(phone)' doesn't match any valid pattern")
        return false
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValid = emailPredicate.evaluate(with: email)
        print("📧 Email validation for '\(email)': \(isValid ? "✅ Valid" : "❌ Invalid")")
        return isValid
    }
    
    // MARK: - Data Export Methods (NO DUPLICATES)
    
    // ✅ Refresh email from Firebase Auth (in case user logs in during form session)
    func refreshEmailFromAuth() {
        let newEmail = Auth.auth().currentUser?.email ?? ""
        if newEmail != customerEmail {
            customerEmail = newEmail
            print("🔄 Email refreshed from Firebase Auth: \(newEmail)")
        }
    }
    
    func getFormSummary() -> String {
        var summary = "📋 Booking Form Summary - User: gamikapunsisi at 2025-08-21 11:19:23\n"
        summary += "👤 Name: \(customerName.isEmpty ? "Not provided" : customerName)\n"
        summary += "📧 Email: \(customerEmail.isEmpty ? "Not provided (auto-populated)" : customerEmail)\n"
        summary += "📱 Phone: \(customerPhone.isEmpty ? "Not provided" : customerPhone)\n"
        summary += "🏠 Address: \(customerAddress.isEmpty ? "Not provided" : customerAddress)\n"
        summary += "📅 Date: \(DateFormatter.localizedString(from: scheduledDate, dateStyle: .medium, timeStyle: .none))\n"
        summary += "⏰ Time: \(DateFormatter.localizedString(from: scheduledTime, dateStyle: .none, timeStyle: .short))\n"
        summary += "📝 Notes: \(notes.isEmpty ? "None" : notes)\n"
        
        return summary
    }
    
    // ✅ Clear form data but preserve auto-populated email
    func clearFormData() {
        customerName = ""
        customerPhone = ""
        customerAddress = ""
        scheduledDate = Date()
        scheduledTime = Date()
        notes = ""
        customerInfoErrors.removeAll()
        
        // ✅ Re-populate email from Firebase Auth after clearing
        customerEmail = Auth.auth().currentUser?.email ?? ""
        
        print("🧹 Form data cleared, email re-populated from Firebase Auth - User: gamikapunsisi at 2025-08-21 11:19:23")
    }
}

// MARK: - Booking Manager
class BookingManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var bookingSuccess = false
    @Published var currentBookings: [ServiceBooking] = []
    
    private var db: Firestore?
    
    // UI Testing detection
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING") ||
        ProcessInfo.processInfo.arguments.contains("UI-TESTING") ||
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
        UserDefaults.standard.bool(forKey: "UI_TESTING_MODE")
    }
    
    init() {
        print("📅 BookingManager initialized - User: gamikapunsisi at 2025-08-21 11:19:23")
        setupFirestore()
    }
    
    private func setupFirestore() {
        if isUITesting {
            print("🧪 BookingManager: UI Testing mode - Mock Firestore - User: gamikapunsisi at 2025-08-21 11:19:23")
            db = nil // Use nil for testing to avoid Firebase calls
        } else {
            db = Firestore.firestore()
            print("🔥 BookingManager: Firestore initialized - User: gamikapunsisi at 2025-08-21 11:19:23")
        }
    }
    
    // MARK: - Create Booking (✅ REAL NOTIFICATIONS)
    func createBooking(_ booking: ServiceBooking) async {
        print("📅 Creating booking - User: gamikapunsisi at 2025-08-21 11:19:23")
        print("🎯 Service: \(booking.serviceName)")
        print("👤 Customer: \(booking.customerName)")
        print("📱 Phone: \(booking.customerPhone)")
        print("📍 Address: \(booking.customerAddress)")
        print("📅 Date: \(booking.formattedDate)")
        print("⏰ Time: \(booking.formattedTime)")
        print("💰 Amount: \(booking.formattedPrice)")
        
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
            self.bookingSuccess = false
        }
        
        if isUITesting {
            // Mock booking creation for UI testing
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            await MainActor.run {
                self.isLoading = false
                self.bookingSuccess = true
                self.currentBookings.append(booking)
                print("🧪 Mock booking created successfully - User: gamikapunsisi at 2025-08-21 11:19:23")
            }
            
            // ✅ Schedule REAL notifications even in testing
            await scheduleBookingNotifications(for: booking)
            return
        }
        
        guard let db = db else {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Database not available"
            }
            return
        }
        
        do {
            // Create booking document in Firestore
            try await db.collection("bookings").document(booking.id).setData(booking.toFirestoreData())
            
            print("✅ Booking created successfully with ID: \(booking.id)")
            print("📊 Booking Details:")
            print("   - Service: \(booking.serviceName)")
            print("   - Customer: \(booking.customerName)")
            print("   - Phone: \(booking.customerPhone)")
            print("   - Address: \(booking.customerAddress)")
            print("   - Date: \(booking.formattedDate)")
            print("   - Time: \(booking.formattedTime)")
            print("   - Amount: \(booking.formattedPrice)")
            print("   - Status: \(booking.status.displayName)")
            print("   - Created by: \(booking.createdBy)")
            print("   - Platform: \(booking.platform)")
            print("   - Timestamp: 2025-08-21 11:19:23 UTC")
            
            await MainActor.run {
                self.isLoading = false
                self.bookingSuccess = true
                self.currentBookings.append(booking)
            }
            
            // ✅ Schedule REAL notifications after successful booking creation
            await scheduleBookingNotifications(for: booking)
            
        } catch {
            print("❌ Error creating booking: \(error.localizedDescription)")
            print("📅 Error occurred at: 2025-08-21 11:19:23 UTC")
            
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to create booking: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - ✅ REAL Notification Scheduling
    private func scheduleBookingNotifications(for booking: ServiceBooking) async {
        print("🔔 Scheduling REAL booking notifications - User: gamikapunsisi at 2025-08-21 11:19:23")
        
        let notificationManager = NotificationManager.shared
        
        // 1. ✅ REAL Immediate confirmation notification
        await notificationManager.scheduleBookingConfirmationNotification(for: booking)
        
        // 2. ✅ REAL Reminder notification (1 hour before service)
        await notificationManager.scheduleBookingReminderNotification(for: booking, reminderTime: 3600)
        
        // 3. ✅ REAL Additional reminder (24 hours before service) if booking is more than 24 hours away
        let timeUntilService = booking.scheduledDate.timeIntervalSinceNow
        if timeUntilService > 86400 { // More than 24 hours
            await notificationManager.scheduleBookingReminderNotification(for: booking, reminderTime: 86400)
            print("📅 24-hour reminder scheduled - User: gamikapunsisi at 2025-08-21 11:19:23")
        }
        
        print("✅ All REAL booking notifications scheduled successfully - User: gamikapunsisi at 2025-08-21 11:19:23")
    }
    
    // MARK: - Fetch User Bookings
    func fetchUserBookings(for userId: String) async {
        guard !isUITesting else {
            await mockFetchUserBookings()
            return
        }
        
        guard let db = db else { return }
        
        print("🔍 Fetching bookings for user: \(userId) - User: gamikapunsisi at 2025-08-21 11:19:23")
        
        do {
            let snapshot = try await db.collection("bookings")
                .whereField("createdBy", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let bookings = try snapshot.documents.compactMap { document -> ServiceBooking? in
                let data = document.data()
                return try parseBookingFromFirestore(data: data, id: document.documentID)
            }
            
            await MainActor.run {
                self.currentBookings = bookings
                print("✅ Fetched \(bookings.count) bookings - User: gamikapunsisi at 2025-08-21 11:19:23")
            }
            
        } catch {
            print("❌ Failed to fetch bookings: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "Failed to fetch bookings: \(error.localizedDescription)"
            }
        }
    }
    
    private func mockFetchUserBookings() async {
        print("🧪 Mock fetching user bookings - User: gamikapunsisi at 2025-08-21 11:19:23")
        
        // Create some mock bookings
        let mockBookings = [
            ServiceBooking(
                serviceId: "mock-service-1",
                serviceName: "House Cleaning",
                servicePrice: 2500.0,
                estimatedDuration: "2 hours",
                customerName: "Mock Customer",
                customerEmail: "gamikapunsisi@taskflow.lk",
                customerPhone: "+94771234567",
                customerAddress: "Mock Address, Colombo",
                scheduledDate: Date(),
                scheduledTime: Date(),
                notes: "Mock booking for testing"
            )
        ]
        
        await MainActor.run {
            self.currentBookings = mockBookings
        }
    }
    
    // MARK: - ✅ Update Booking Status (with REAL notifications)
    func updateBookingStatus(_ bookingId: String, status: BookingStatus) async {
        guard !isUITesting else {
            await mockUpdateBookingStatus(bookingId, status: status)
            return
        }
        
        guard let db = db else { return }
        
        print("🔄 Updating booking \(bookingId) to status: \(status.displayName) - User: gamikapunsisi at 2025-08-21 11:19:23")
        
        do {
            try await db.collection("bookings").document(bookingId).updateData([
                "status": status.rawValue,
                "updatedAt": FieldValue.serverTimestamp(),
                "lastUpdated": "2025-08-21 11:19:23 UTC"
            ])
            
            // Update local booking
            await MainActor.run {
                if let index = self.currentBookings.firstIndex(where: { $0.id == bookingId }) {
                    let booking = self.currentBookings[index]
                    
                    // ✅ Schedule REAL status update notification
                    Task {
                        let message = self.getStatusUpdateMessage(for: status, serviceName: booking.serviceName)
                        await NotificationManager.shared.scheduleStatusUpdateNotification(
                            for: bookingId,
                            serviceName: booking.serviceName,
                            newStatus: status.rawValue,
                            message: message
                        )
                        
                        // ✅ If completed, schedule REAL completion notification
                        if status == .completed {
                            await NotificationManager.shared.scheduleServiceCompletedNotification(for: booking)
                        }
                    }
                }
            }
            
            print("✅ Booking status updated successfully with REAL notifications")
            
        } catch {
            print("❌ Failed to update booking status: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = "Failed to update booking status: \(error.localizedDescription)"
            }
        }
    }
    
    private func mockUpdateBookingStatus(_ bookingId: String, status: BookingStatus) async {
        print("🧪 Mock updating booking status - User: gamikapunsisi at 2025-08-21 11:19:23")
        await MainActor.run {
            // Mock update logic here
            print("🧪 Mock status update complete for booking: \(bookingId)")
        }
    }
    
    private func getStatusUpdateMessage(for status: BookingStatus, serviceName: String) -> String {
        switch status {
        case .confirmed:
            return "Your \(serviceName) booking has been confirmed by the service provider."
        case .inProgress:
            return "Your \(serviceName) service is now in progress."
        case .completed:
            return "Your \(serviceName) service has been completed successfully!"
        case .cancelled:
            return "Your \(serviceName) booking has been cancelled."
        case .pending:
            return "Your \(serviceName) booking status has been updated to pending."
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseBookingFromFirestore(data: [String: Any], id: String) throws -> ServiceBooking? {
        // This is a simplified parser - you might want to use Codable with Firestore
        guard let serviceName = data["serviceName"] as? String,
              let servicePrice = data["servicePrice"] as? Double,
              let customerName = data["customerName"] as? String,
              let customerPhone = data["customerPhone"] as? String else {
            return nil
        }
        
        let serviceId = data["serviceId"] as? String ?? ""
        let estimatedDuration = data["estimatedDuration"] as? String ?? "Unknown"
        let customerEmail = data["customerEmail"] as? String ?? ""
        let customerAddress = data["customerAddress"] as? String ?? ""
        let notes = data["notes"] as? String ?? ""
        
        // Parse dates
        let scheduledDate = (data["scheduledDate"] as? Timestamp)?.dateValue() ?? Date()
        let scheduledTime = (data["scheduledTime"] as? Timestamp)?.dateValue() ?? Date()
        
        return ServiceBooking(
            serviceId: serviceId,
            serviceName: serviceName,
            servicePrice: servicePrice,
            estimatedDuration: estimatedDuration,
            customerName: customerName,
            customerEmail: customerEmail,
            customerPhone: customerPhone,
            customerAddress: customerAddress,
            scheduledDate: scheduledDate,
            scheduledTime: scheduledTime,
            notes: notes
        )
    }
    
    // Clear success state
    func clearBookingState() {
        bookingSuccess = false
        errorMessage = nil
        
        print("🧹 Booking state cleared - User: gamikapunsisi at 2025-08-21 11:19:23")
    }
    
    // Get booking by ID
    func getBooking(by id: String) -> ServiceBooking? {
        return currentBookings.first { $0.id == id }
    }
    
    // Get bookings by status
    func getBookings(by status: BookingStatus) -> [ServiceBooking] {
        return currentBookings.filter { $0.status == status }
    }
    
    // Get booking statistics
    func getBookingStatistics() -> (total: Int, pending: Int, completed: Int, cancelled: Int) {
        let total = currentBookings.count
        let pending = currentBookings.filter { $0.status == .pending || $0.status == .confirmed }.count
        let completed = currentBookings.filter { $0.status == .completed }.count
        let cancelled = currentBookings.filter { $0.status == .cancelled }.count
        
        return (total: total, pending: pending, completed: completed, cancelled: cancelled)
    }
}

// MARK: - Extensions
extension BookingManager {
    var hasActiveBookings: Bool {
        !currentBookings.filter { $0.status == .pending || $0.status == .confirmed || $0.status == .inProgress }.isEmpty
    }
    
    var totalBookingsCount: Int {
        currentBookings.count
    }
    
    var recentBookings: [ServiceBooking] {
        Array(currentBookings.prefix(5))
    }
}

// MARK: - Preview Support
#if DEBUG
extension ServiceBooking {
    static let mockBooking = ServiceBooking(
        serviceId: "mock-service-id",
        serviceName: "House Cleaning Service",
        servicePrice: 2500.0,
        estimatedDuration: "2 hours",
        customerName: "John Doe",
        customerEmail: "gamikapunsisi@taskflow.lk",
        customerPhone: "+94771234567",
        customerAddress: "123 Main Street, Colombo 07",
        scheduledDate: Date(),
        scheduledTime: Date(),
        notes: "Please bring necessary cleaning supplies"
    )
}

extension BookingFormData {
    static let mockFormData: BookingFormData = {
        let formData = BookingFormData()
        formData.customerName = "Jane Smith"
        // Email will be auto-populated from Firebase Auth in init()
        formData.customerPhone = "+94771234567"
        formData.customerAddress = "456 Test Street, Kandy"
        formData.notes = "Test booking notes"
        return formData
    }()
}
#endif
