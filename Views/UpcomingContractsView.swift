import SwiftUI

struct UpcomingContractsView: View {
    @StateObject private var bookingManager = BookingManager()
    @State private var selectedDate: Date = Date()
    
    // Filter bookings for the selected date
    var bookingsForSelectedDate: [ServiceBooking] {
        bookingManager.currentBookings.filter {
            Calendar.current.isDate($0.scheduledDate, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    CalendarWeekView(
                        selectedDate: $selectedDate,
                        bookings: bookingManager.currentBookings
                    )
                    
                    VStack(spacing: 16) {
                        if bookingManager.isLoading {
                            ProgressView("Loading bookings...")
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else if bookingsForSelectedDate.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                
                                Text("No bookings scheduled")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                
                                Text("for \(formattedSelectedDate())")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            ForEach(bookingsForSelectedDate) { booking in
                                BookingCardView(booking: booking) {
                                    Task {
                                        await bookingManager.updateBookingStatus(booking.id, status: .cancelled)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if let errorMessage = bookingManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Upcoming Bookings")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                let userId = "gamikapunsisi"
                await bookingManager.fetchUserBookings(for: userId)
            }
            .onAppear {
                let userId = "gamikapunsisi"
                Task {
                    await bookingManager.fetchUserBookings(for: userId)
                }
            }
        }
    }
    
    private func formattedSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
    
    private func generateWeekDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}

struct BookingCardView: View {
    let booking: ServiceBooking
    var onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(booking.serviceName)
                    .font(.headline)
                Spacer()
                Text(booking.status.displayName)
                    .font(.caption)
                    .foregroundColor(booking.status.color)
            }
            Text("Customer: \(booking.customerName)")
                .font(.subheadline)
            Text("Date: \(booking.formattedDate) • Time: \(booking.formattedTime)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("Address: \(booking.customerAddress)")
                .font(.caption)
                .foregroundColor(.secondary)
            Button("Cancel Booking") {
                onCancel()
            }
            .foregroundColor(.red)
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
