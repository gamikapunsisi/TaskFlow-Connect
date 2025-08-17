//
//  ContractCardView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-17.
//

import SwiftUI

struct ContractCardView: View {
    let contract: Contract
    let onCancel: () -> Void
    @State private var showingCancelAlert = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .font(.title3)
            }
            
            // Contract Details
            VStack(alignment: .leading, spacing: 4) {
                Text(contract.customerName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(contract.serviceName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Text(contract.scheduledTime)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("|")
                        .foregroundColor(.secondary)
                    
                    Text(contract.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Cancel Button
            Button(action: {
                showingCancelAlert = true
            }) {
                Text("Cancel Appointment")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16)
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .alert("Cancel Appointment", isPresented: $showingCancelAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, Cancel", role: .destructive) {
                onCancel()
            }
        } message: {
            Text("Are you sure you want to cancel this appointment with \(contract.customerName)?")
        }
    }
}
