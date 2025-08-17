import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ServiceManager: ObservableObject {
    @Published var services: [Service] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private var listener: ListenerRegistration?
    
    init() {
        fetchServices()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Fetch All Services (Fixed for Index Issue)
    func fetchServices() {
        isLoading = true
        errorMessage = nil
        
        // Remove previous listener
        listener?.remove()
        
        // Simplified query to avoid index issues
        listener = db.collection("services")
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    self?.handleServicesResult(querySnapshot: querySnapshot, error: error)
                }
            }
    }
    
    // MARK: - Fetch User's Services (Fixed for Index Issue)
    func fetchUserServices() {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ No authenticated user")
            DispatchQueue.main.async {
                self.errorMessage = "You must be logged in to view your services"
                self.isLoading = false
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Remove previous listener
        listener?.remove()
        
        // Query user services without ordering to avoid index issues
        listener = db.collection("services")
            .whereField("userId", isEqualTo: currentUser.uid)
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    self?.handleServicesResult(querySnapshot: querySnapshot, error: error)
                }
            }
    }
    
    // MARK: - Handle Query Results
    private func handleServicesResult(querySnapshot: QuerySnapshot?, error: Error?) {
        isLoading = false
        
        if let error = error {
            print("❌ Error fetching services: \(error.localizedDescription)")
            
            // Check if it's an index error
            if error.localizedDescription.contains("index") {
                errorMessage = "Database is setting up. Please try again in a moment."
            } else {
                errorMessage = "Failed to load services: \(error.localizedDescription)"
            }
            return
        }
        
        guard let documents = querySnapshot?.documents else {
            print("❌ No documents found")
            services = []
            return
        }
        
        print("📄 Found \(documents.count) documents")
        
        // Parse documents and handle errors
        var loadedServices: [Service] = []
        
        for document in documents {
            do {
                let service = try document.data(as: Service.self)
                loadedServices.append(service)
                print("✅ Loaded service: \(service.name) - Price: \(service.displayPrice)")
            } catch {
                print("❌ Error decoding service from document \(document.documentID): \(error)")
                // Continue with other documents
            }
        }
        
        // Sort manually by creation date (descending - newest first)
        services = loadedServices.sorted { service1, service2 in
            guard let date1 = service1.createdAt?.dateValue(),
                  let date2 = service2.createdAt?.dateValue() else {
                // If no date, put at end
                return service1.createdAt != nil && service2.createdAt == nil
            }
            return date1 > date2
        }
        
        print("✅ Total services loaded and sorted: \(services.count)")
        errorMessage = nil
    }
    
    // MARK: - Refresh Services
    func refreshServices() {
        fetchServices()
    }
    
    // MARK: - Delete Service
    func deleteService(_ service: Service) {
        guard let serviceId = service.id else {
            print("❌ No service ID found")
            return
        }
        
        // Check if user owns this service
        guard let currentUser = Auth.auth().currentUser,
              service.userId == currentUser.uid else {
            DispatchQueue.main.async {
                self.errorMessage = "You can only delete your own services"
            }
            return
        }
        
        db.collection("services").document(serviceId).updateData([
            "isActive": false,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error deleting service: \(error)")
                    self?.errorMessage = "Failed to delete service: \(error.localizedDescription)"
                } else {
                    print("✅ Service '\(service.name)' deleted successfully")
                    // Service will be automatically removed from the list due to the listener
                }
            }
        }
    }
    
    // MARK: - Add Service (Optional - for testing)
    func addTestService() {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ No authenticated user")
            return
        }
        
        let testService: [String: Any] = [
            "name": "Test Service",
            "description": "This is a test service",
            "price": 25.0,
            "priceString": "25",
            "estimatedTime": "1 hour",
            "userId": currentUser.uid,
            "imageUrl": "",
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
            "isActive": true
        ]
        
        db.collection("services").addDocument(data: testService) { error in
            if let error = error {
                print("❌ Error adding test service: \(error)")
            } else {
                print("✅ Test service added successfully")
            }
        }
    }
}
