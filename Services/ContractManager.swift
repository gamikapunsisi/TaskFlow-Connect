import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ContractManager: ObservableObject {
    @Published var contracts: [Contract] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedDate = Date()
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        fetchUpcomingContracts()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Fetch Upcoming Contracts
    func fetchUpcomingContracts() {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ No authenticated user")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Remove previous listener
        listener?.remove()
        
        // Get contracts for the current user as a service provider
        listener = db.collection("contracts")
            .whereField("providerId", isEqualTo: currentUser.uid)
            .whereField("status", in: ["pending", "confirmed"])
            .addSnapshotListener { [weak self] querySnapshot, error in
                DispatchQueue.main.async {
                    self?.handleContractsResult(querySnapshot: querySnapshot, error: error)
                }
            }
    }
    
    // MARK: - Handle Query Results
    private func handleContractsResult(querySnapshot: QuerySnapshot?, error: Error?) {
        isLoading = false
        
        if let error = error {
            print("❌ Error fetching contracts: \(error.localizedDescription)")
            errorMessage = "Failed to load contracts: \(error.localizedDescription)"
            return
        }
        
        guard let documents = querySnapshot?.documents else {
            print("❌ No contracts found")
            contracts = []
            return
        }
        
        contracts = documents.compactMap { document in
            do {
                let contract = try document.data(as: Contract.self)
                print("✅ Loaded contract: \(contract.customerName) - \(contract.serviceName)")
                return contract
            } catch {
                print("❌ Error decoding contract: \(error)")
                return nil
            }
        }.sorted { contract1, contract2 in
            // Sort by date and time
            let date1 = contract1.scheduledDate.dateValue()
            let date2 = contract2.scheduledDate.dateValue()
            return date1 < date2
        }
        
        print("✅ Total contracts loaded: \(contracts.count)")
    }
    
    // MARK: - Cancel Contract
    func cancelContract(_ contract: Contract) {
        guard let contractId = contract.id else { return }
        
        db.collection("contracts").document(contractId).updateData([
            "status": ContractStatus.cancelled.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error cancelling contract: \(error)")
                    self?.errorMessage = "Failed to cancel appointment: \(error.localizedDescription)"
                } else {
                    print("✅ Contract cancelled successfully")
                }
            }
        }
    }
    
    // MARK: - Get Contracts for Selected Date
    func contractsForDate(_ date: Date) -> [Contract] {
        let calendar = Calendar.current
        return contracts.filter { contract in
            calendar.isDate(contract.scheduledDate.dateValue(), inSameDayAs: date)
        }
    }
}
