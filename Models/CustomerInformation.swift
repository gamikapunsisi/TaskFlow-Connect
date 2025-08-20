//
//  CustomerInformationManager.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-20.
//  Updated: 2025-08-20 07:51:31 UTC
//

import Foundation
import FirebaseFirestore
import SwiftUI

class CustomerInformationManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var savedCustomers: [CustomerInformation] = []
    
    private var db: Firestore?
    
    // UI Testing detection
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING") ||
        ProcessInfo.processInfo.arguments.contains("UI-TESTING") ||
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
        UserDefaults.standard.bool(forKey: "UI_TESTING_MODE")
    }
    
    init() {
        print("👥 CustomerInformationManager initialized - User: gamikapunsisi at 2025-08-20 07:51:31")
        setupFirestore()
    }
    
    private func setupFirestore() {
        if isUITesting {
            print("🧪 CustomerInformationManager: UI Testing mode - Mock Firestore - User: gamikapunsisi at 2025-08-20 07:51:31")
            db = nil
        } else {
            db = Firestore.firestore()
            print("🔥 CustomerInformationManager: Firestore initialized - User: gamikapunsisi at 2025-08-20 07:51:31")
        }
    }
    
    // MARK: - Save Customer Information
    func saveCustomerInformation(_ customerInfo: CustomerInformation) async -> Bool {
        print("💾 Saving customer information - User: gamikapunsisi at 2025-08-20 07:51:31")
        print("👤 Customer: \(customerInfo.fullName)")
        print("📱 Phone: \(customerInfo.phoneNumber)")
        print("🏠 Address: \(customerInfo.serviceAddress)")
        
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
        
        do {
            try await db.collection("customer_information")
                .document(customerInfo.id)
                .setData(customerInfo.toFirestoreData())
            
            await MainActor.run {
                self.isLoading = false
                self.savedCustomers.append(customerInfo)
            }
            
            print("✅ Customer information saved successfully with ID: \(customerInfo.id)")
            return true
            
        } catch {
            print("❌ Failed to save customer information: \(error.localizedDescription) - User: gamikapunsisi at 2025-08-20 07:51:31")
            
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to save customer information: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    private func mockSaveCustomerInformation(_ customerInfo: CustomerInformation) async -> Bool {
        print("🧪 Mock saving customer information - User: gamikapunsisi at 2025-08-20 07:51:31")
        
        await MainActor.run {
            self.isLoading = true
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await MainActor.run {
            self.isLoading = false
            self.savedCustomers.append(customerInfo)
        }
        
        return true
    }
    
    // MARK: - Auto-fill Functionality
    func autoFillCustomerInformation(phoneNumber: String, formData: BookingFormData) async {
        print("🔄 Attempting auto-fill for phone: \(phoneNumber) - User: gamikapunsisi at 2025-08-20 07:51:31")
        
        if let existingCustomer = await fetchCustomerInformation(by: phoneNumber) {
            await MainActor.run {
                formData.customerName = existingCustomer.fullName
                formData.customerEmail = existingCustomer.emailAddress
                formData.customerPhone = existingCustomer.phoneNumber
                formData.customerAddress = existingCustomer.serviceAddress
            }
            
            print("✅ Auto-filled customer information - User: gamikapunsisi at 2025-08-20 07:51:31")
        } else {
            print("ℹ️ No existing customer data found for auto-fill - User: gamikapunsisi at 2025-08-20 07:51:31")
        }
    }
    
    // MARK: - Fetch Customer Information
    func fetchCustomerInformation(by phoneNumber: String) async -> CustomerInformation? {
        guard !isUITesting else {
            return mockFetchCustomerInformation(by: phoneNumber)
        }
        
        guard let db = db else { return nil }
        
        print("🔍 Fetching customer information for phone: \(phoneNumber) - User: gamikapunsisi at 2025-08-20 07:51:31")
        
        do {
            let snapshot = try await db.collection("customer_information")
                .whereField("phoneNumber", isEqualTo: phoneNumber)
                .limit(to: 1)
                .getDocuments()
            
            if let document = snapshot.documents.first {
                return parseCustomerInformation(from: document.data())
            }
            
            return nil
            
        } catch {
            print("❌ Failed to fetch customer information: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func mockFetchCustomerInformation(by phoneNumber: String) -> CustomerInformation? {
        return savedCustomers.first { $0.phoneNumber == phoneNumber }
    }
    
    private func parseCustomerInformation(from data: [String: Any]) -> CustomerInformation? {
        guard let fullName = data["fullName"] as? String,
              let phoneNumber = data["phoneNumber"] as? String,
              let serviceAddress = data["serviceAddress"] as? String else {
            return nil
        }
        
        let emailAddress = data["emailAddress"] as? String ?? ""
        let createdBy = data["createdBy"] as? String ?? "gamikapunsisi"
        
        return CustomerInformation(
            fullName: fullName,
            emailAddress: emailAddress,
            phoneNumber: phoneNumber,
            serviceAddress: serviceAddress,
            createdBy: createdBy
        )
    }
}
