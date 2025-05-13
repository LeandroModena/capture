//
//  PhotosGridView.swift
//  CaptureId
//
//  Created by Leandro Modena on 13/05/25.
//

import SwiftUI

struct PhotosGridView: View {
    @StateObject private var viewModel = PhotosGridViewModel()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.photos) { photo in
                    if let image = photo.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        Color.gray
                            .frame(width: 100, height: 100)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Minhas Capturas")
        .onAppear {
            viewModel.loadImages()
        }
    }
}
