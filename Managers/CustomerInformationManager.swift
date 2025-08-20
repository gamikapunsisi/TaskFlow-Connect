//
//  CustomerInformation.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-20.
//  Updated: 2025-08-20 07:51:31 UTC
//

import Foundation
import FirebaseFirestore
import UIKit

// MARK: - Customer Information Model
struct CustomerInformation: Codable, Identifiable {
    var id: String = UUID().uuidString
    let fullName: String
    let emailAddress: String
    let phoneNumber: String
    let serviceAddress: String
    let createdAt: Timestamp
    let updatedAt: Timestamp
    let createdBy: String
    
    // Additional metadata
    let deviceInfo: [String: String]
    let platform: String
    let version: String
    
    init(fullName: String, emailAddress: String, phoneNumber: String, serviceAddress: String, createdBy: String = "gamikapunsisi") {
        self.fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.emailAddress = emailAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        self.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        self.serviceAddress = serviceAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = Timestamp(date: Date())
        self.updatedAt = Timestamp(date: Date())
        self.createdBy = createdBy
        
        // Device metadata
        self.deviceInfo = [
            "model": UIDevice.current.model,
            "systemName": UIDevice.current.systemName,
            "systemVersion": UIDevice.current.systemVersion,
            "timestamp": "2025-08-20 07:51:31"
        ]
        self.platform = "ios"
        self.version = "1.0"
    }
    
    // Convert to Firestore dictionary
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id,
            "fullName": fullName,
            "emailAddress": emailAddress,
            "phoneNumber": phoneNumber,
            "serviceAddress": serviceAddress,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "createdBy": createdBy,
            "deviceInfo": deviceInfo,
            "platform": platform,
            "version": version,
            "timestamp": "2025-08-20 07:51:31 UTC"
        ]
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
    
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt.dateValue())
    }
}

// MARK: - Preview Support
#if DEBUG
extension CustomerInformation {
    static let mockCustomer = CustomerInformation(
        fullName: "John Doe",
        emailAddress: "john@example.com",
        phoneNumber: "+94771234567",
        serviceAddress: "123 Main Street, Colombo 07",
        createdBy: "gamikapunsisi"
    )
    
    static let mockCustomers = [
        CustomerInformation(
            fullName: "Jane Smith",
            emailAddress: "jane@example.com",
            phoneNumber: "+94771234568",
            serviceAddress: "456 Queen Street, Kandy",
            createdBy: "gamikapunsisi"
        ),
        CustomerInformation(
            fullName: "Bob Wilson",
            emailAddress: "",
            phoneNumber: "+94771234569",
            serviceAddress: "789 King Street, Galle",
            createdBy: "gamikapunsisi"
        )
    ]
}
#endif
