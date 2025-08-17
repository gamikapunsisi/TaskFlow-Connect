import Foundation
import FirebaseFirestore

struct Contract: Identifiable, Codable {
    @DocumentID var id: String?
    var customerName: String
    var serviceName: String
    var serviceType: String
    var scheduledDate: Timestamp
    var scheduledTime: String
    var location: String
    var status: ContractStatus
    var customerId: String
    var providerId: String
    var serviceId: String
    var notes: String?
    var createdAt: Timestamp?
    
    // Computed properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: scheduledDate.dateValue())
    }
    
    var formattedTime: String {
        return scheduledTime
    }
    
    init(customerName: String = "", serviceName: String = "", serviceType: String = "", scheduledDate: Timestamp = Timestamp(), scheduledTime: String = "", location: String = "", status: ContractStatus = .pending, customerId: String = "", providerId: String = "", serviceId: String = "", notes: String? = nil) {
        self.customerName = customerName
        self.serviceName = serviceName
        self.serviceType = serviceType
        self.scheduledDate = scheduledDate
        self.scheduledTime = scheduledTime
        self.location = location
        self.status = status
        self.customerId = customerId
        self.providerId = providerId
        self.serviceId = serviceId
        self.notes = notes
    }
}

enum ContractStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}
