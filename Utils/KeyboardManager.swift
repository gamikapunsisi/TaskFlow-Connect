//
//  KeyboardManager.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-31.
//

import SwiftUI
import UIKit
import Combine

/// Centralized keyboard management to prevent Auto Layout constraint conflicts
/// Addresses SystemInputAssistantView constraint conflicts with _UIKBCompatInputView
class KeyboardManager: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    @Published var isKeyboardVisible: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = KeyboardManager()
    
    private init() {
        setupKeyboardObservers()
    }
    
    private func setupKeyboardObservers() {
        // Use NotificationCenter to observe keyboard events
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                self?.handleKeyboardWillShow(notification: notification)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notification in
                self?.handleKeyboardWillHide()
            }
            .store(in: &cancellables)
    }
    
    private func handleKeyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        DispatchQueue.main.async {
            // Use keyboard frame height minus safe area to prevent constraint conflicts
            let window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
            
            let bottomSafeArea = window?.safeAreaInsets.bottom ?? 0
            
            // Adjust height to account for input assistant view to prevent conflicts
            self.keyboardHeight = max(0, keyboardFrame.height - bottomSafeArea - 45) // 45 is assistant view height
            self.isKeyboardVisible = true
        }
    }
    
    private func handleKeyboardWillHide() {
        DispatchQueue.main.async {
            self.keyboardHeight = 0
            self.isKeyboardVisible = false
        }
    }
    
    /// Dismiss the keyboard programmatically
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Get keyboard avoidance padding for views
    func getKeyboardPadding() -> CGFloat {
        return isKeyboardVisible ? keyboardHeight : 0
    }
}

/// Extension to handle keyboard toolbar management
extension KeyboardManager {
    /// Create a standard "Done" toolbar for keyboard
    static func createDoneToolbar(action: @escaping () -> Void) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: nil,
            action: nil
        )
        
        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        toolbar.items = [flexSpace, doneButton]
        return toolbar
    }
}