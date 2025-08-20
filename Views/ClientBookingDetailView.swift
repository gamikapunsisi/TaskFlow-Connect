//
//  BookingDetailView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-19.
//

import SwiftUI

struct BookingDetailView: View {
    let booking: Booking
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Status Header
                    statusHeader
                    
                    // Service Details
                    serviceDetailsSection
                    
                    // Customer Information
                    customerInfoSection
                    
                    // Schedule Information
                    scheduleInfoSection
                    
                    // Payment Information
                    paymentInfoSection
                    
                    // Additional Notes
                    if !booking.notes.isEmpty {
                        notesSection
                    }
                    
                    // Action Buttons
                    actionButtonsSection
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Booking Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        shareBooking()
                    }
                }
            }
        }
    }
    
    private var statusHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Booking #\(booking.id.prefix(8))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(booking.status.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(booking.status.color)
                    .cornerRadius(16)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.serviceName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Created on \(DateFormatter.detailDateFormatter.string(from: booking.createdAt))")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var serviceDetailsSection: some View {
        SectionContainer(title: "Service Details", icon: "wrench.and.screwdriver") {
            DetailRow(title: "Service", value: booking.serviceName)
            DetailRow(title: "Price", value: booking.displayPrice)
            DetailRow(title: "Duration", value: booking.estimatedDuration)
        }
    }
    
    private var customerInfoSection: some View {
        SectionContainer(title: "Customer Information", icon: "person") {
            DetailRow(title: "Name", value: booking.customerName)
            if !booking.customerEmail.isEmpty {
                DetailRow(title: "Email", value: booking.customerEmail)
            }
            DetailRow(title: "Phone", value: booking.customerPhone)
            DetailRow(title: "Address", value: booking.customerAddress)
        }
    }
    
    private var scheduleInfoSection: some View {
        SectionContainer(title: "Schedule", icon: "calendar") {
            DetailRow(title: "Date", value: DateFormatter.detailDateFormatter.string(from: booking.scheduledDate))
            DetailRow(title: "Time", value: DateFormatter.timeFormatter.string(from: booking.scheduledTime))
        }
    }
    
    private var paymentInfoSection: some View {
        SectionContainer(title: "Payment", icon: "creditcard") {
            DetailRow(title: "Total Amount", value: booking.displayPrice)
            DetailRow(title: "Currency", value: booking.currency)
            DetailRow(title: "Payment Status", value: booking.paymentStatus.capitalized)
        }
    }
    
    private var notesSection: some View {
        SectionContainer(title: "Additional Notes", icon: "note.text") {
            Text(booking.notes)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primary)
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(8)
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if booking.status == .pending {
                Button(action: {
                    cancelBooking()
                }) {
                    HStack {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Cancel Booking")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red)
                    .cornerRadius(10)
                }
            }
            
            Button(action: {
                contactSupport()
            }) {
                HStack {
                    Image(systemName: "phone")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Contact Support")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
    
    private func shareBooking() {
        print("📤 Sharing booking: \(booking.id) - User: gamikapunsisi at 2025-08-19 13:51:05")
    }
    
    private func cancelBooking() {
        print("❌ Cancelling booking: \(booking.id) - User: gamikapunsisi at 2025-08-19 13:51:05")
    }
    
    private func contactSupport() {
        print("📞 Contacting support for booking: \(booking.id) - User: gamikapunsisi at 2025-08-19 13:51:05")
    }
}

struct SectionContainer<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            content
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

extension DateFormatter {
    static let detailDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
}
