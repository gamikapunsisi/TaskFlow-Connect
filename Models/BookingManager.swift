//
//  BookingManager.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-19.
//  Updated: 2025-08-20 09:47:20 UTC
//

import Foundation
import Firebase
import FirebaseFirestore
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
            "timestamp": "2025-08-20 09:47:20"
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
            "lastUpdated": "2025-08-20 09:47:20 UTC"
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
        print("📝 BookingFormData initialized - User: gamikapunsisi at 2025-08-20 09:47:20")
    }
    
    // MARK: - Validation Methods
    
    func validateCustomerInformation() -> Bool {
        print("🔍 Validating customer information - User: gamikapunsisi at 2025-08-20 09:47:20")
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
        
        // Service Address validation
        let trimmedAddress = customerAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedAddress.isEmpty {
            customerInfoErrors.append("Service address is required")
            print("❌ Address validation failed: Empty")
        } else if trimmedAddress.count < 10 {
            customerInfoErrors.append("Please provide a complete service address")
            print("❌ Address validation failed: Too short (\(trimmedAddress.count) chars)")
        } else {
            print("✅ Address validation passed: '\(trimmedAddress)'")
        }
        
        // Email validation (optional but if provided must be valid)
        let cleanEmail = customerEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleanEmail.isEmpty && !isValidEmail(cleanEmail) {
            customerInfoErrors.append("Please enter a valid email address")
            print("❌ Email validation failed: Invalid format '\(cleanEmail)'")
        } else if !cleanEmail.isEmpty {
            print("✅ Email validation passed: '\(cleanEmail)'")
        } else {
            print("ℹ️ Email validation skipped: Empty (optional)")
        }
        
        let isValid = customerInfoErrors.isEmpty
        
        print("📝 Customer info validation result: \(isValid ? "✅ VALID" : "❌ INVALID") - User: gamikapunsisi at 2025-08-20 09:47:20")
        if !isValid {
            print("🚫 Validation errors (\(customerInfoErrors.count)):")
            for (index, error) in customerInfoErrors.enumerated() {
                print("   \(index + 1). \(error)")
            }
        }
        
        return isValid
    }
    
    // MARK: - Simple validation for button state
    func hasRequiredFields() -> Bool {
        let nameValid = !customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let phoneValid = !customerPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let addressValid = !customerAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        let hasRequired = nameValid && phoneValid && addressValid
        print("📋 Quick field check - Name: \(nameValid), Phone: \(phoneValid), Address: \(addressValid) = \(hasRequired)")
        
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
    
    // MARK: - Data Export Methods
    
    func createCustomerInformation() -> CustomerInformation {
        return CustomerInformation(
            fullName: customerName,
            emailAddress: customerEmail,
            phoneNumber: customerPhone,
            serviceAddress: customerAddress,
            createdBy: "gamikapunsisi"
        )
    }
    
    func getFormSummary() -> String {
        var summary = "📋 Booking Form Summary - User: gamikapunsisi at 2025-08-20 09:47:20\n"
        summary += "👤 Name: \(customerName.isEmpty ? "Not provided" : customerName)\n"
        summary += "📧 Email: \(customerEmail.isEmpty ? "Not provided" : customerEmail)\n"
        summary += "📱 Phone: \(customerPhone.isEmpty ? "Not provided" : customerPhone)\n"
        summary += "🏠 Address: \(customerAddress.isEmpty ? "Not provided" : customerAddress)\n"
        summary += "📅 Date: \(DateFormatter.localizedString(from: scheduledDate, dateStyle: .medium, timeStyle: .none))\n"
        summary += "⏰ Time: \(DateFormatter.localizedString(from: scheduledTime, dateStyle: .none, timeStyle: .short))\n"
        summary += "📝 Notes: \(notes.isEmpty ? "None" : notes)\n"
        
        return summary
    }
    
    // Clear form data
    func clearFormData() {
        customerName = ""
        customerEmail = ""
        customerPhone = ""
        customerAddress = ""
        scheduledDate = Date()
        scheduledTime = Date()
        notes = ""
        customerInfoErrors.removeAll()
        
        print("🧹 Form data cleared - User: gamikapunsisi at 2025-08-20 09:47:20")
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
        print("📅 BookingManager initialized - User: gamikapunsisi at 2025-08-20 09:47:20")
        setupFirestore()
    }
    
    private func setupFirestore() {
        if isUITesting {
            print("🧪 BookingManager: UI Testing mode - Mock Firestore - User: gamikapunsisi at 2025-08-20 09:47:20")
            db = nil // Use nil for testing to avoid Firebase calls
        } else {
            db = Firestore.firestore()
            print("🔥 BookingManager: Firestore initialized - User: gamikapunsisi at 2025-08-20 09:47:20")
        }
    }
    
    // MARK: - Create Booking
    func createBooking(_ booking: ServiceBooking) async {
        print("📅 Creating booking - User: gamikapunsisi at 2025-08-20 09:47:20")
        print("🎯 Service: \(booking.serviceName)")
        print("👤 Customer: \(booking.customerName)")
        print("📱 Phone: \(booking.customerPhone)")
        print("📍 Address: \(booking.customerAddress)")
        print("📅 Date: \(booking.formattedDate)")
        print("⏰ Time: \(booking.formattedTime)")
        print("💰 Amount: \(booking.formattedPrice)")
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            bookingSuccess = false
        }
        
        if isUITesting {
            // Mock booking creation for UI testing
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            await MainActor.run {
                self.isLoading = false
                self.bookingSuccess = true
                self.currentBookings.append(booking)
                print("🧪 Mock booking created successfully - User: gamikapunsisi at 2025-08-20 09:47:20")
            }
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
            print("   - Timestamp: 2025-08-20 09:47:20 UTC")
            
            await MainActor.run {
                self.isLoading = false
                self.bookingSuccess = true
                self.currentBookings.append(booking)
            }
            
        } catch {
            print("❌ Error creating booking: \(error.localizedDescription)")
            print("📅 Error occurred at: 2025-08-20 09:47:20 UTC")
            
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to create booking: \(error.localizedDescription)"
            }
        }
    }
    
    // ... [Rest of BookingManager methods remain the same]
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
        customerEmail: "john@example.com",
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
        formData.customerEmail = "jane@example.com"
        formData.customerPhone = "+94771234567"
        formData.customerAddress = "456 Test Street, Kandy"
        formData.notes = "Test booking notes"
        return formData
    }()
}
#endif
