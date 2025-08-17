//
//  ProfilemenuItem.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-18.
//

import SwiftUI

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    let showChevron: Bool
    
    init(icon: String, title: String, showChevron: Bool = true, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                }
                
                // Title
                Text(title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Chevron
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
