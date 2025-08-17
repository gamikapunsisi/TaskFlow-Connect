//
//  CalendarWeekView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-17.
//

import SwiftUI

struct CalendarWeekView: View {
    @Binding var selectedDate: Date
    let contracts: [Contract]
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, yyyy"
        return formatter
    }()
    
    private var weekDays: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }
        
        var days: [Date] = []
        var date = weekInterval.start
        
        for _ in 0..<7 {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month and Year Header with Navigation
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.primary)
                
                Text(dateFormatter.string(from: selectedDate))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: previousWeek) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: nextWeek) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal)
            
            // Week Days
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { day in
                    DayView(
                        date: day,
                        selectedDate: $selectedDate,
                        hasContracts: hasContractsForDate(day)
                    )
                    .onTapGesture {
                        selectedDate = day
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func previousWeek() {
        selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextWeek() {
        selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
    }
    
    private func hasContractsForDate(_ date: Date) -> Bool {
        return contracts.contains { contract in
            calendar.isDate(contract.scheduledDate.dateValue(), inSameDayAs: date)
        }
    }
}

struct DayView: View {
    let date: Date
    @Binding var selectedDate: Date
    let hasContracts: Bool
    
    private let calendar = Calendar.current
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    private var isSelected: Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(dayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .secondary)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.black : Color.clear)
                    .frame(width: 44, height: 44)
                
                if isToday && !isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 44, height: 44)
                }
                
                Text(dayNumber)
                    .font(.title3)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if hasContracts && !isSelected {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                        .offset(x: 12, y: -12)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
