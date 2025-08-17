//
//  Service.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-17.
//

import Foundation
import FirebaseFirestore

struct Service: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var price: Double
    var priceString: String
    var estimatedTime: String
    var userId: String
    var imageUrl: String
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var isActive: Bool
    
    // Computed property for display
    var displayPrice: String {
        return "$\(String(format: "%.2f", price))"
    }
    
    init(name: String = "", description: String = "", price: Double = 0.0, priceString: String = "", estimatedTime: String = "", userId: String = "", imageUrl: String = "", isActive: Bool = true) {
        self.name = name
        self.description = description
        self.price = price
        self.priceString = priceString
        self.estimatedTime = estimatedTime
        self.userId = userId
        self.imageUrl = imageUrl
        self.isActive = isActive
    }
}
