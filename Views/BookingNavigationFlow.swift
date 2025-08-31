//
//  BookingNavigationFlow.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-19.
//  Updated: 2025-08-20 09:53:32 UTC
//

import SwiftUI

// MARK: - Multi-Page Booking Navigation Flow
struct BookingNavigationFlow: View {
    let service: Service
    @ObservedObject var bookingManager: BookingManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentStep: BookingStep = .serviceDetails
    @State private var bookingData = BookingFormData()
    @StateObject private var customerManager = CustomerInformationManager()
    
    enum BookingStep: Int, CaseIterable {
        case serviceDetails = 0
        case customerInfo = 1
        case dateTime = 2
        case confirmation = 3
        case success = 4
        
        var title: String {
            switch self {
            case .serviceDetails:
                return "Service Details"
            case .customerInfo:
                return "Your Information"
            case .dateTime:
                return "Schedule Service"
            case .confirmation:
                return "Confirm Booking"
            case .success:
                return "Booking Confirmed"
            }
        }
        
        var progress: Double {
            return Double(rawValue + 1) / Double(BookingStep.allCases.count)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress Bar
                if currentStep != .success {
                    BookingProgressBar(currentStep: currentStep.rawValue, totalSteps: BookingStep.allCases.count - 1)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                }
                
                // Content
                TabView(selection: $currentStep) {
                    // Step 1: Service Details
                    ServiceDetailsStep(service: service)
                        .tag(BookingStep.serviceDetails)
                    
                    // Step 2: Customer Information
                    CustomerInfoStep(bookingData: $bookingData, customerManager: customerManager)
                        .tag(BookingStep.customerInfo)
                    
                    // Step 3: Date & Time Selection
                    DateTimeStep(bookingData: $bookingData)
                        .tag(BookingStep.dateTime)
                    
                    // Step 4: Confirmation
                    ConfirmationStep(service: service, bookingData: bookingData)
                        .tag(BookingStep.confirmation)
                    
                    // Step 5: Success
                    BookingSuccessStep(service: service, bookingData: bookingData)
                        .tag(BookingStep.success)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation Buttons
                if currentStep != .success {
                    navigationButtons
                }
            }
            .navigationTitle(currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        print("❌ Booking cancelled - User: gamikapunsisi at 2025-08-20 09:53:32")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onChange(of: bookingManager.bookingSuccess) { oldValue, newValue in
            if newValue {
                currentStep = .success
            }
        }
        .onAppear {
            print("📱 BookingNavigationFlow appeared - User: gamikapunsisi at 2025-08-20 09:53:32")
            print("🔧 Service: \(service.name)")
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back Button
            if currentStep.rawValue > 0 {
                Button(action: {
                    withAnimation {
                        currentStep = BookingStep(rawValue: currentStep.rawValue - 1) ?? .serviceDetails
                        print("⬅️ Back to step \(currentStep.rawValue) - User: gamikapunsisi at 2025-08-20 09:53:32")
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Next/Submit Button
            Button(action: {
                handleNextAction()
            }) {
                HStack {
                    if bookingManager.isLoading && currentStep == .confirmation {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Text(getButtonText())
                            .font(.system(size: 16, weight: .semibold))
                        if currentStep != .confirmation {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isNextButtonEnabled() ? Color.blue : Color.gray)
                .cornerRadius(8)
            }
            .disabled(!isNextButtonEnabled() || bookingManager.isLoading)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func getButtonText() -> String {
        switch currentStep {
        case .serviceDetails:
            return "Continue"
        case .customerInfo:
            return "Next"
        case .dateTime:
            return "Review"
        case .confirmation:
            return bookingManager.isLoading ? "Creating..." : "Book Service"
        case .success:
            return "Done"
        }
    }
    
    private func isNextButtonEnabled() -> Bool {
        let isEnabled: Bool
        
        switch currentStep {
        case .serviceDetails:
            isEnabled = true
            
        case .customerInfo:
            // Use the simple field check instead of full validation for button state
            isEnabled = bookingData.hasRequiredFields()
            print("🔘 Customer info step - Button enabled: \(isEnabled) - User: gamikapunsisi at 2025-08-20 09:53:32")
            
        case .dateTime:
            isEnabled = bookingData.scheduledDate >= Calendar.current.startOfDay(for: Date())
            print("📅 Date/time step - Button enabled: \(isEnabled) - User: gamikapunsisi at 2025-08-20 09:53:32")
            
        case .confirmation:
            isEnabled = !bookingManager.isLoading
            
        case .success:
            isEnabled = true
        }
        
        return isEnabled
    }
    
    private func handleNextAction() {
        print("➡️ Moving from step \(currentStep.rawValue) - User: gamikapunsisi at 2025-08-20 09:53:32")
        
        switch currentStep {
        case .serviceDetails:
            withAnimation {
                currentStep = .customerInfo
            }
            
        case .customerInfo:
            // Do full validation when actually trying to proceed
            print("🔍 Performing full validation before proceeding...")
            if bookingData.validateCustomerInformation() {
                print("✅ Validation passed - proceeding to next step")
                
                // Save customer information
                Task {
                    let customerInfo = bookingData.createCustomerInformation()
                    await customerManager.saveCustomerInformation(customerInfo)
                }
                
                withAnimation {
                    currentStep = .dateTime
                }
            } else {
                print("❌ Validation failed - staying on customer info step")
                print("🚫 Errors: \(bookingData.customerInfoErrors)")
                // The validation errors will be displayed in the UI
            }
            
        case .dateTime:
            withAnimation {
                currentStep = .confirmation
            }
            
        case .confirmation:
            Task {
                await submitBooking()
            }
            
        case .success:
            print("✅ Booking flow completed - User: gamikapunsisi at 2025-08-20 09:53:32")
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func submitBooking() async {
        let booking = ServiceBooking(
            serviceId: service.id ?? "",
            serviceName: service.name,
            servicePrice: service.price,
            estimatedDuration: service.estimatedTime,
            customerName: bookingData.customerName.trimmingCharacters(in: .whitespacesAndNewlines),
            customerEmail: bookingData.customerEmail.trimmingCharacters(in: .whitespacesAndNewlines),
            customerPhone: bookingData.customerPhone.trimmingCharacters(in: .whitespacesAndNewlines),
            customerAddress: bookingData.customerAddress.trimmingCharacters(in: .whitespacesAndNewlines),
            scheduledDate: bookingData.scheduledDate,
            scheduledTime: bookingData.scheduledTime,
            notes: bookingData.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        print("📅 Submitting booking for: \(service.name)")
        print("👤 Customer: \(bookingData.customerName)")
        print("📱 Phone: \(bookingData.customerPhone)")
        print("📍 Address: \(bookingData.customerAddress)")
        print("📅 Date: \(bookingData.scheduledDate)")
        print("⏰ Time: \(bookingData.scheduledTime)")
        print("📝 Notes: \(bookingData.notes)")
        print("👤 Booked by User: gamikapunsisi")
        print("📅 Booking submitted at: 2025-08-20 09:53:32 UTC")
        
        await bookingManager.createBooking(booking)
    }
}

// MARK: - Progress Bar
struct BookingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                    if step < totalSteps - 1 {
                        Rectangle()
                            .fill(step < currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                    }
                }
            }
            
            Text("Step \(currentStep + 1) of \(totalSteps)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Booking Step Views

struct ServiceDetailsStep: View {
    let service: Service
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Service Image
                AsyncImage(url: URL(string: service.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.6),
                                Color.purple.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 48))
                                .foregroundColor(.white.opacity(0.7))
                            Text("No Image Available")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .frame(height: 200)
                .cornerRadius(16)
                
                // Service Details
                VStack(alignment: .leading, spacing: 16) {
                    Text(service.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(service.displayPrice)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Text(service.estimatedTime)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("Description")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(service.description.isEmpty ? "Professional service provided by experienced providers in Sri Lanka. Quality work guaranteed with competitive pricing." : service.description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                    
                    // Service Features
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What's Included")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        ServiceDetailRow(icon: "checkmark.circle", title: "Professional Service", description: "Verified service provider")
                        ServiceDetailRow(icon: "shield", title: "Insured & Safe", description: "Covered by insurance")
                        ServiceDetailRow(icon: "star", title: "Quality Guaranteed", description: "Customer satisfaction assured")
                        ServiceDetailRow(icon: "location", title: "Local Provider", description: "Available in Sri Lanka")
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            print("📋 Service details viewed - User: gamikapunsisi at 2025-08-20 09:53:32")
        }
    }
}

// MARK: - Enhanced Customer Info Step
struct CustomerInfoStep: View {
    @Binding var bookingData: BookingFormData
    @ObservedObject var customerManager: CustomerInformationManager
    @State private var showingValidationErrors = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                
                // Form Fields
                formFieldsSection
                
                // Validation Errors
                if !bookingData.customerInfoErrors.isEmpty {
                    validationErrorsSection
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .keyboardAvoidance()
        .onChange(of: bookingData.customerPhone) { oldValue, newValue in
            // Auto-fill when phone number is complete
            if newValue.count >= 10 && oldValue.count < 10 {
                Task {
                    await customerManager.autoFillCustomerInformation(
                        phoneNumber: newValue,
                        formData: bookingData
                    )
                }
            }
        }
        .onAppear {
            print("👤 Customer info step appeared - User: gamikapunsisi at 2025-08-20 09:53:32")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Please provide your contact information")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("* Required fields")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.orange)
        }
    }
    
    // MARK: - Form Fields Section
    private var formFieldsSection: some View {
        VStack(spacing: 16) {
            // Full Name *
            FormFieldView(
                title: "Full Name *",
                placeholder: "Enter your full name",
                text: $bookingData.customerName,
                keyboardType: .default,
                isRequired: true
            )
            .accessibility(identifier: "customer-name-field")
            
            // Email Address
            FormFieldView(
                title: "Email Address",
                placeholder: "Enter your email (optional)",
                text: $bookingData.customerEmail,
                keyboardType: .emailAddress,
                isRequired: false
            )
            .accessibility(identifier: "customer-email-field")
            
            // Phone Number *
            FormFieldView(
                title: "Phone Number *",
                placeholder: "Enter your phone number",
                text: $bookingData.customerPhone,
                keyboardType: .phonePad,
                isRequired: true
            )
            .accessibility(identifier: "customer-phone-field")
            
            // Service Address *
            FormFieldView(
                title: "Service Address *",
                placeholder: "Enter service location address",
                text: $bookingData.customerAddress,
                keyboardType: .default,
                isRequired: true,
                isMultiline: true
            )
            .accessibility(identifier: "customer-address-field")
        }
    }
    
    // MARK: - Validation Errors Section
    private var validationErrorsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("Please fix the following issues:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
            }
            
            ForEach(bookingData.customerInfoErrors, id: \.self) { error in
                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 4, height: 4)
                    Text(error)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Form Field Component
struct FormFieldView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let isRequired: Bool
    let isMultiline: Bool
    
    init(title: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, isRequired: Bool = false, isMultiline: Bool = false) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.isRequired = isRequired
        self.isMultiline = isMultiline
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            if isMultiline {
                TextEditor(text: $text)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .disableAutocorrection(keyboardType == .emailAddress || keyboardType == .phonePad)
            }
        }
    }
}

struct DateTimeStep: View {
    @Binding var bookingData: BookingFormData
    @FocusState private var isNotesFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("When would you like to schedule this service?")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                
                // Date Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Date")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    DatePicker("Service Date", selection: $bookingData.scheduledDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(.horizontal, 20)
                }
                
                // Time Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Time")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    DatePicker("Service Time", selection: $bookingData.scheduledTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding(.horizontal, 20)
                }
                
                // Notes
                VStack(alignment: .leading, spacing: 12) {
                    Text("Additional Notes (Optional)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    TextEditor(text: $bookingData.notes)
                        .frame(height: 100)
                        .focused($isNotesFieldFocused)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
        .keyboardAvoidance()
        .keyboardToolbar(dismissAction: { isNotesFieldFocused = false })
        .onAppear {
            print("📅 Date/Time selection - User: gamikapunsisi at 2025-08-20 09:53:32")
        }
    }
}

struct ConfirmationStep: View {
    let service: Service
    let bookingData: BookingFormData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Please review your booking details")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                
                // Service Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Service")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(service.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(service.displayPrice)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.blue)
                                Text("Duration: \(service.estimatedTime)")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                // Customer Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Customer Information")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ConfirmationRow(title: "Name", value: bookingData.customerName)
                        if !bookingData.customerEmail.isEmpty {
                            ConfirmationRow(title: "Email", value: bookingData.customerEmail)
                        }
                        ConfirmationRow(title: "Phone", value: bookingData.customerPhone)
                        ConfirmationRow(title: "Address", value: bookingData.customerAddress)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                // Schedule Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Schedule")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ConfirmationRow(title: "Date", value: formatDate(bookingData.scheduledDate))
                        ConfirmationRow(title: "Time", value: formatTime(bookingData.scheduledTime))
                        if !bookingData.notes.isEmpty {
                            ConfirmationRow(title: "Notes", value: bookingData.notes)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .onAppear {
            print("📋 Confirmation review - User: gamikapunsisi at 2025-08-20 09:53:32")
        }
    }
    
    // MARK: - Private Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

struct ConfirmationRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct BookingSuccessStep: View {
    let service: Service
    let bookingData: BookingFormData
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Booking Confirmed!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Your booking for \(service.name) has been successfully submitted.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 8) {
                Text("Scheduled for:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text("\(formatSuccessDate(bookingData.scheduledDate)) at \(formatSuccessTime(bookingData.scheduledTime))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            
            Text("You will receive a confirmation call/message shortly.")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                print("📞 Contact support tapped - User: gamikapunsisi at 2025-08-20 09:53:32")
            }) {
                HStack {
                    Image(systemName: "phone")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Contact Support")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            print("🎉 Booking success displayed - User: gamikapunsisi at 2025-08-20 09:53:32")
        }
    }
    
    // MARK: - Private Helper Methods
    private func formatSuccessDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatSuccessTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

struct ServiceDetailRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.green)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Text("BookingNavigationFlow")
            .font(.title)
            .foregroundColor(.blue)
        Text("Use from ClientMainContainerView")
            .font(.caption)
            .foregroundColor(.secondary)
        Text("User: gamikapunsisi • 2025-08-20 09:53:32")
            .font(.caption2)
            .foregroundColor(.secondary.opacity(0.7))
    }
    .padding()
}
