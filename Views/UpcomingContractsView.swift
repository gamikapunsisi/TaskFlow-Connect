//
//  UpcomingContractsView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-17.
//

import SwiftUI

struct UpcomingContractsView: View {
    @StateObject private var contractManager = ContractManager()
    
    var todayContracts: [Contract] {
        contractManager.contractsForDate(contractManager.selectedDate)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Calendar Week View
                    CalendarWeekView(
                        selectedDate: $contractManager.selectedDate,
                        contracts: contractManager.contracts
                    )
                    
                    // Contracts List
                    VStack(spacing: 16) {
                        if contractManager.isLoading {
                            ProgressView("Loading contracts...")
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else if todayContracts.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                
                                Text("No contracts scheduled")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                
                                Text("for \(formattedSelectedDate())")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            ForEach(todayContracts) { contract in
                                ContractCardView(contract: contract) {
                                    contractManager.cancelContract(contract)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error Message
                    if let errorMessage = contractManager.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Upcoming Contracts")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                contractManager.fetchUpcomingContracts()
            }
        }
    }
    
    private func formattedSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: contractManager.selectedDate)
    }
}

#Preview {
    UpcomingContractsView()
}
