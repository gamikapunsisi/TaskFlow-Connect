import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct AddNewServiceView: View {
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focusedField: Field? // Add focus state
    
    @State private var serviceName = ""
    @State private var serviceDescription = ""
    @State private var price = ""
    @State private var estimatedTime = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Add enum for focus management
    enum Field {
        case serviceName, serviceDescription, price, estimatedTime
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Service Image Picker
                    Button(action: {
                        dismissKeyboard() // Dismiss keyboard before showing action sheet
                        showActionSheet = true
                    }) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(radius: 4)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(width: 120, height: 120)
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // Add option to clear image
                    if selectedImage != nil {
                        Button("Remove Image") {
                            selectedImage = nil
                        }
                        .foregroundColor(.red)
                    }
                    
                    // MARK: - Text Fields with Focus Management
                    Group {
                        TextField("Service Name", text: $serviceName)
                            .focused($focusedField, equals: .serviceName)
                            .onSubmit { focusedField = .serviceDescription }
                        
                        TextField("Service Description", text: $serviceDescription, axis: .vertical)
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .serviceDescription)
                            .onSubmit { focusedField = .price }
                        
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .price)
                            .onSubmit { focusedField = .estimatedTime }
                        
                        TextField("Estimated Time (e.g., 30 mins)", text: $estimatedTime)
                            .focused($focusedField, equals: .estimatedTime)
                            .onSubmit { focusedField = nil }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    
                    // MARK: - Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    
                    // MARK: - Save Button
                    Button(action: {
                        dismissKeyboard()
                        saveService()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.6))
                                .cornerRadius(12)
                        } else {
                            Text("Save Service")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    .disabled(isLoading || !isFormValid())
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add New Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismissKeyboard()
                        // Add small delay to ensure keyboard is dismissed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                
                // Add toolbar button to dismiss keyboard
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
            }
            .onTapGesture {
                dismissKeyboard()
            }
            .confirmationDialog("Select Image", isPresented: $showActionSheet) {
                Button("Camera") {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        imagePickerSourceType = .camera
                        showImagePicker = true
                    }
                }
                Button("Photo Library") {
                    imagePickerSourceType = .photoLibrary
                    showImagePicker = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Choose an image source")
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: imagePickerSourceType)
                    .onDisappear {
                        // Ensure keyboard state is reset after image picker dismissal
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            focusedField = nil
                        }
                    }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Form validation
    private func isFormValid() -> Bool {
        return !serviceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !serviceDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !estimatedTime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Enhanced Save to Firebase with Timeout Handling
    func saveService() {
        print("🔄 Starting saveService()")
        
        // Check if user is authenticated
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ No authenticated user")
            errorMessage = "You must be logged in to add services"
            return
        }
        print("✅ User authenticated: \(currentUser.uid)")
        
        // Clean and validate data
        let cleanServiceName = serviceName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = serviceDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPrice = price.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEstimatedTime = estimatedTime.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("📝 Clean form data - Name: '\(cleanServiceName)', Description: '\(cleanDescription)', Price: '\(cleanPrice)', Time: '\(cleanEstimatedTime)'")
        print("🖼️ Selected image: \(selectedImage != nil ? "Yes" : "No")")
        
        guard !cleanServiceName.isEmpty && !cleanDescription.isEmpty && !cleanPrice.isEmpty && !cleanEstimatedTime.isEmpty else {
            print("❌ Form validation failed")
            errorMessage = "All fields are required."
            return
        }
        print("✅ Form validation passed")
        
        // Validate price format
        guard let priceValue = Double(cleanPrice) else {
            print("❌ Price validation failed: '\(cleanPrice)'")
            errorMessage = "Please enter a valid price."
            return
        }
        print("✅ Price validation passed: \(priceValue)")
        
        isLoading = true
        errorMessage = nil
        
        // Set timeout for the entire operation
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { _ in
            DispatchQueue.main.async {
                if self.isLoading {
                    self.isLoading = false
                    self.errorMessage = "Operation timed out. Please try again."
                    print("⏰ Save operation timed out")
                }
            }
        }
        
        // If no image is selected, save without image
        if selectedImage == nil {
            saveServiceWithoutImage(
                userId: currentUser.uid,
                priceValue: priceValue,
                serviceName: cleanServiceName,
                description: cleanDescription,
                price: cleanPrice,
                estimatedTime: cleanEstimatedTime,
                timeoutTimer: timeoutTimer
            )
            return
        }
        
        // Save with image
        saveServiceWithImage(
            userId: currentUser.uid,
            priceValue: priceValue,
            serviceName: cleanServiceName,
            description: cleanDescription,
            price: cleanPrice,
            estimatedTime: cleanEstimatedTime,
            timeoutTimer: timeoutTimer
        )
    }
    
    // MARK: - Save without image
    private func saveServiceWithoutImage(userId: String, priceValue: Double, serviceName: String, description: String, price: String, estimatedTime: String, timeoutTimer: Timer) {
        print("💾 Saving service without image...")
        
        let serviceData: [String: Any] = [
            "name": serviceName,
            "description": description,
            "price": priceValue,
            "priceString": price,
            "estimatedTime": estimatedTime,
            "userId": userId,
            "imageUrl": "",
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
            "isActive": true
        ]
        
        print("💾 Saving to Firestore: \(serviceData)")
        
        Firestore.firestore().collection("services").addDocument(data: serviceData) { error in
            timeoutTimer.invalidate()
            
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("❌ Firestore save failed: \(error.localizedDescription)")
                    self.errorMessage = "Failed to save service: \(error.localizedDescription)"
                } else {
                    print("✅ Service saved successfully without image!")
                    // Add small delay before dismissing to ensure UI updates
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Save with image
    private func saveServiceWithImage(userId: String, priceValue: Double, serviceName: String, description: String, price: String, estimatedTime: String, timeoutTimer: Timer) {
        print("🔄 Starting image upload...")
        
        let storageRef = Storage.storage().reference().child("services/\(userId)/\(UUID().uuidString).jpg")
        
        guard let selectedImage = selectedImage,
              let imageData = selectedImage.jpegData(compressionQuality: 0.7) else { // Reduced compression for better performance
            print("❌ Failed to convert image to data")
            timeoutTimer.invalidate()
            DispatchQueue.main.async {
                self.errorMessage = "Failed to process image data"
                self.isLoading = false
            }
            return
        }
        
        print("📤 Uploading image data size: \(imageData.count) bytes")
        
        // Create metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            print("📤 Upload completion handler called")
            
            if let error = error {
                print("❌ Image upload failed: \(error.localizedDescription)")
                timeoutTimer.invalidate()
                DispatchQueue.main.async {
                    self.errorMessage = "Image upload failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            print("✅ Image uploaded successfully")
            print("📥 Getting download URL...")
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Failed to get download URL: \(error.localizedDescription)")
                    timeoutTimer.invalidate()
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to get image URL: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                    return
                }
                
                guard let imageUrl = url?.absoluteString else {
                    print("❌ Invalid image URL")
                    timeoutTimer.invalidate()
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid image URL."
                        self.isLoading = false
                    }
                    return
                }
                
                print("✅ Got download URL: \(imageUrl)")
                
                // Save service data with image URL
                let serviceData: [String: Any] = [
                    "name": serviceName,
                    "description": description,
                    "price": priceValue,
                    "priceString": price,
                    "estimatedTime": estimatedTime,
                    "userId": userId,
                    "imageUrl": imageUrl,
                    "createdAt": FieldValue.serverTimestamp(),
                    "updatedAt": FieldValue.serverTimestamp(),
                    "isActive": true
                ]
                
                print("💾 Saving to Firestore: \(serviceData)")
                
                Firestore.firestore().collection("services").addDocument(data: serviceData) { error in
                    timeoutTimer.invalidate()
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if let error = error {
                            print("❌ Firestore save failed: \(error.localizedDescription)")
                            print("❌ Firestore error details: \(error)")
                            self.errorMessage = "Failed to save service: \(error.localizedDescription)"
                        } else {
                            print("✅ Service saved successfully with image!")
                            // Add small delay before dismissing to ensure UI updates
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ImagePicker with enhanced dismissal handling
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            
            // Dismiss with proper timing
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    AddNewServiceView()
}
