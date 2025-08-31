//
//  KeyboardAvoidanceModifier.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-31.
//

import SwiftUI

/// SwiftUI ViewModifier to handle keyboard avoidance and prevent constraint conflicts
struct KeyboardAvoidanceModifier: ViewModifier {
    @StateObject private var keyboardManager = KeyboardManager.shared
    let enableDismissOnTap: Bool
    let ignoreKeyboardSafeArea: Bool
    
    init(enableDismissOnTap: Bool = true, ignoreKeyboardSafeArea: Bool = false) {
        self.enableDismissOnTap = enableDismissOnTap
        self.ignoreKeyboardSafeArea = ignoreKeyboardSafeArea
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardManager.getKeyboardPadding())
            .animation(.easeInOut(duration: 0.3), value: keyboardManager.keyboardHeight)
            .onTapGesture {
                if enableDismissOnTap {
                    KeyboardManager.dismissKeyboard()
                }
            }
            .modifier(ConditionalKeyboardSafeArea(ignore: ignoreKeyboardSafeArea))
    }
}

/// Conditional modifier for keyboard safe area handling
private struct ConditionalKeyboardSafeArea: ViewModifier {
    let ignore: Bool
    
    func body(content: Content) -> some View {
        if ignore {
            content.ignoresSafeArea(.keyboard)
        } else {
            content
        }
    }
}

/// Extension to make the modifier easy to use
extension View {
    /// Apply keyboard avoidance to prevent Auto Layout constraint conflicts
    /// - Parameters:
    ///   - enableDismissOnTap: Whether to dismiss keyboard when tapping outside text fields
    ///   - ignoreKeyboardSafeArea: Whether to ignore keyboard safe area (use for full-screen forms)
    /// - Returns: View with keyboard avoidance applied
    func keyboardAvoidance(
        enableDismissOnTap: Bool = true,
        ignoreKeyboardSafeArea: Bool = false
    ) -> some View {
        self.modifier(
            KeyboardAvoidanceModifier(
                enableDismissOnTap: enableDismissOnTap,
                ignoreKeyboardSafeArea: ignoreKeyboardSafeArea
            )
        )
    }
}

/// Toolbar modifier for consistent keyboard toolbar management
struct KeyboardToolbarModifier<T: Hashable>: ViewModifier {
    let dismissAction: () -> Void
    
    init(dismissAction: @escaping () -> Void) {
        self.dismissAction = dismissAction
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            dismissAction()
                        }
                        .font(.system(size: 16, weight: .medium))
                    }
                }
            }
    }
}

extension View {
    /// Add a consistent "Done" button to the keyboard toolbar
    /// - Parameter dismissAction: Action to perform when Done is tapped
    /// - Returns: View with keyboard toolbar
    func keyboardToolbar(dismissAction: @escaping () -> Void) -> some View {
        self.modifier(KeyboardToolbarModifier(dismissAction: dismissAction))
    }
}