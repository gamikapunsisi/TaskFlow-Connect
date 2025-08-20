import SwiftUI
import Firebase

struct ClientBookingsView: View {
    @StateObject private var bookingManager = ClientBookingManager()
    @State private var selectedStatus: BookingStatus? = nil
    @State private var showingBookingDetail: ClientBooking? = nil
    
    var filteredBookings: [ClientBooking] {
        if let status = selectedStatus {
            return bookingManager.userBookings.filter { $0.status == status }
        }
        return bookingManager.userBookings
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Status Filter
                statusFilterSection
                
                // Bookings List
                if bookingManager.isLoadingBookings {
                    LoadingBookingsView()
                } else if filteredBookings.isEmpty {
                    EmptyBookingsView(hasBookings: !bookingManager.userBookings.isEmpty)
                } else {
                    bookingsListSection
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $showingBookingDetail) { booking in
            ClientBookingDetailView(booking: booking)
        }
        .onAppear {
            print("📅 ClientBookingsView appeared - User: gamikapunsisi at 2025-08-19 14:11:36")
            bookingManager.fetchUserBookings()
        }
        .refreshable {
            bookingManager.fetchUserBookings()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("My Bookings")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Refresh Button
                Button(action: {
                    bookingManager.fetchUserBookings()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(bookingManager.isLoadingBookings ? 360 : 0))
                        .animation(
                            bookingManager.isLoadingBookings ?
                            Animation.linear(duration: 1).repeatForever(autoreverses: false) :
                            Animation.default,
                            value: bookingManager.isLoadingBookings
                        )
                }
            }
            
            // Booking Stats
            HStack(spacing: 20) {
                BookingStatCard(
                    title: "Total",
                    count: bookingManager.userBookings.count,
                    color: .blue
                )
                
                BookingStatCard(
                    title: "Pending",
                    count: bookingManager.userBookings.filter { $0.status == .pending }.count,
                    color: .orange
                )
                
                BookingStatCard(
                    title: "Completed",
                    count: bookingManager.userBookings.filter { $0.status == .completed }.count,
                    color: .green
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Status Filter Section
    private var statusFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All Bookings Filter
                FilterChip(
                    title: "All (\(bookingManager.userBookings.count))",
                    isSelected: selectedStatus == nil,
                    color: .blue
                ) {
                    selectedStatus = nil
                }
                
                // Status-specific Filters
                ForEach(BookingStatus.allCases, id: \.self) { status in
                    let count = bookingManager.userBookings.filter { $0.status == status }.count
                    if count > 0 {
                        FilterChip(
                            title: "\(status.displayName) (\(count))",
                            isSelected: selectedStatus == status,
                            color: status.color
                        ) {
                            selectedStatus = status
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Bookings List Section
    private var bookingsListSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredBookings.sorted(by: { $0.createdAt > $1.createdAt })) { booking in
                    BookingCard(booking: booking) {
                        showingBookingDetail = booking
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // Space for bottom navigation
        }
    }
}

// MARK: - Client Booking Model (Fixed Codable issues)
struct ClientBooking: Identifiable, Codable {
    let id: String
    let serviceId: String
    let serviceName: String
    let servicePrice: Double
    let estimatedDuration: String
    let customerName: String
    let customerEmail: String
    let customerPhone: String
    let customerAddress: String
    let scheduledDate: Date
    let scheduledTime: Date
    let notes: String
    let status: BookingStatus
    let paymentStatus: String
    let totalAmount: Double
    let currency: String
    let createdAt: Date
    let updatedAt: Date
    
    var displayPrice: String {
        return "LKR \(String(format: "%.0f", totalAmount))"
    }
    
    var scheduledDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
        return dateFormatter.string(from: scheduledDate)
    }
    
    // Custom coding keys to handle Firebase Timestamp conversion
    enum CodingKeys: String, CodingKey {
        case id, serviceId, serviceName, servicePrice, estimatedDuration
        case customerName, customerEmail, customerPhone, customerAddress
        case scheduledDate, scheduledTime, notes, status, paymentStatus
        case totalAmount, currency, createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        serviceId = try container.decode(String.self, forKey: .serviceId)
        serviceName = try container.decode(String.self, forKey: .serviceName)
        servicePrice = try container.decode(Double.self, forKey: .servicePrice)
        estimatedDuration = try container.decode(String.self, forKey: .estimatedDuration)
        customerName = try container.decode(String.self, forKey: .customerName)
        customerEmail = try container.decode(String.self, forKey: .customerEmail)
        customerPhone = try container.decode(String.self, forKey: .customerPhone)
        customerAddress = try container.decode(String.self, forKey: .customerAddress)
        
        // Handle Date decoding
        scheduledDate = try container.decode(Date.self, forKey: .scheduledDate)
        scheduledTime = try container.decode(Date.self, forKey: .scheduledTime)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        notes = try container.decode(String.self, forKey: .notes)
        let statusString = try container.decode(String.self, forKey: .status)
        status = BookingStatus(rawValue: statusString) ?? .pending
        paymentStatus = try container.decode(String.self, forKey: .paymentStatus)
        totalAmount = try container.decode(Double.self, forKey: .totalAmount)
        currency = try container.decode(String.self, forKey: .currency)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(serviceId, forKey: .serviceId)
        try container.encode(serviceName, forKey: .serviceName)
        try container.encode(servicePrice, forKey: .servicePrice)
        try container.encode(estimatedDuration, forKey: .estimatedDuration)
        try container.encode(customerName, forKey: .customerName)
        try container.encode(customerEmail, forKey: .customerEmail)
        try container.encode(customerPhone, forKey: .customerPhone)
        try container.encode(customerAddress, forKey: .customerAddress)
        try container.encode(scheduledDate, forKey: .scheduledDate)
        try container.encode(scheduledTime, forKey: .scheduledTime)
        try container.encode(notes, forKey: .notes)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(paymentStatus, forKey: .paymentStatus)
        try container.encode(totalAmount, forKey: .totalAmount)
        try container.encode(currency, forKey: .currency)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    // Convenience initializer for direct creation
    init(id: String, serviceId: String, serviceName: String, servicePrice: Double,
         estimatedDuration: String, customerName: String, customerEmail: String,
         customerPhone: String, customerAddress: String, scheduledDate: Date,
         scheduledTime: Date, notes: String, status: BookingStatus,
         paymentStatus: String, totalAmount: Double, currency: String,
         createdAt: Date, updatedAt: Date) {
        self.id = id
        self.serviceId = serviceId
        self.serviceName = serviceName
        self.servicePrice = servicePrice
        self.estimatedDuration = estimatedDuration
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.customerAddress = customerAddress
        self.scheduledDate = scheduledDate
        self.scheduledTime = scheduledTime
        self.notes = notes
        self.status = status
        self.paymentStatus = paymentStatus
        self.totalAmount = totalAmount
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Client Booking Manager (Fixed extension issues)
class ClientBookingManager: ObservableObject {
    @Published var userBookings: [ClientBooking] = []
    @Published var isLoadingBookings = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func fetchUserBookings() {
        print("📅 Fetching user bookings - User: gamikapunsisi at 2025-08-19 14:11:36")
        
        isLoadingBookings = true
        errorMessage = nil
        
        // Fetch bookings created by gamikapunsisi
        db.collection("bookings")
            .whereField("createdBy", isEqualTo: "gamikapunsisi")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] (querySnapshot: QuerySnapshot?, error: Error?) in
                DispatchQueue.main.async {
                    self?.isLoadingBookings = false
                    
                    if let error = error {
                        print("❌ Error fetching bookings: \(error.localizedDescription)")
                        self?.errorMessage = "Failed to load bookings: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        print("❌ No booking documents found")
                        self?.userBookings = []
                        return
                    }
                    
                    var bookings: [ClientBooking] = []
                    
                    for document in documents {
                        do {
                            let data = document.data()
                            
                            let booking = ClientBooking(
                                id: document.documentID,
                                serviceId: data["serviceId"] as? String ?? "",
                                serviceName: data["serviceName"] as? String ?? "",
                                servicePrice: data["servicePrice"] as? Double ?? 0.0,
                                estimatedDuration: data["estimatedDuration"] as? String ?? "",
                                customerName: data["customerName"] as? String ?? "",
                                customerEmail: data["customerEmail"] as? String ?? "",
                                customerPhone: data["customerPhone"] as? String ?? "",
                                customerAddress: data["customerAddress"] as? String ?? "",
                                scheduledDate: (data["scheduledDate"] as? Timestamp)?.dateValue() ?? Date(),
                                scheduledTime: (data["scheduledTime"] as? Timestamp)?.dateValue() ?? Date(),
                                notes: data["notes"] as? String ?? "",
                                status: BookingStatus(rawValue: data["status"] as? String ?? "pending") ?? .pending,
                                paymentStatus: data["paymentStatus"] as? String ?? "pending",
                                totalAmount: data["totalAmount"] as? Double ?? 0.0,
                                currency: data["currency"] as? String ?? "LKR",
                                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                            )
                            
                            bookings.append(booking)
                            
                        } catch {
                            print("❌ Error parsing booking document \(document.documentID): \(error)")
                        }
                    }
                    
                    self?.userBookings = bookings
                    print("✅ Loaded \(bookings.count) bookings for user: gamikapunsisi at 2025-08-19 14:11:36")
                }
            }
    }
    
    func cancelBooking(_ booking: ClientBooking) {
        print("❌ Cancelling booking: \(booking.id) - User: gamikapunsisi at 2025-08-19 14:11:36")
        
        db.collection("bookings").document(booking.id).updateData([
            "status": BookingStatus.cancelled.rawValue,
            "updatedAt": FieldValue.serverTimestamp(),
            "cancelledBy": "gamikapunsisi",
            "cancelledAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("❌ Error cancelling booking: \(error.localizedDescription)")
            } else {
                print("✅ Booking cancelled successfully")
            }
        }
    }
}

// MARK: - Supporting Views

struct BookingStatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : color.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct BookingCard: View {
    let booking: ClientBooking
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(booking.serviceName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Booking #\(booking.id.prefix(8))")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    Text(booking.status.displayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(booking.status.color)
                        .cornerRadius(12)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(booking.scheduledDateTime)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(booking.customerAddress)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(booking.displayPrice)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LoadingBookingsView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading your bookings...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            Text("Fetching data from Firebase...")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyBookingsView: View {
    let hasBookings: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            Text(hasBookings ? "No bookings match your filter" : "No bookings yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(hasBookings ? "Try changing your filter selection" : "When you book a service, it will appear here")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if !hasBookings {
                Text("User: gamikapunsisi • 2025-08-19 14:11:36")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ClientBookingsView()
}
