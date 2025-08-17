//
//  AsyncImageView.swift
//  TaskFlow
//
//  Created by Gamika Punsisi on 2025-08-17.
//

import SwiftUI

struct AsyncImageView: View {
    let url: String
    let placeholder: Image
    
    init(url: String, placeholder: Image = Image(systemName: "photo")) {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        if url.isEmpty {
            placeholder
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
