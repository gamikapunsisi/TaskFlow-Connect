//
//  AddServiceButton.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-15.
//

import SwiftUI

struct AddServiceButton: View {
    @State private var showingAddService = false

    var body: some View {
        Button {
            showingAddService = true
        } label: {
            HStack {
                Image(systemName: "plus")
                Text("Add Service")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color.black)
            .cornerRadius(16)
        }
        .fullScreenCover(isPresented: $showingAddService) {
            AddNewServiceView()
        }
    }
}
