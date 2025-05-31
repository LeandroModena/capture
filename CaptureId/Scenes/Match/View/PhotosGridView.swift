//
//  PhotosGridView.swift
//  CaptureId
//
//  Created by Leandro Modena on 13/05/25.
//

import SwiftUI

struct PhotosGridView: View {
    @StateObject private var viewModel = PhotosGridViewModel()

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.allImages, id: \.self) { url in
                        PhotoThumbnailView(imageURL: url, viewModel: viewModel)
                            .onTapGesture {
                                viewModel.toggleSelection(for: url)
                            }
                    }
                }
                .padding()
            }
            
            Button(action: {
                viewModel.detectAndCompareFacesWithMatching()
            }) {
                Text("Detectar Faces e Comparar")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Text(viewModel.detectionMessage)
                .padding()
                .foregroundColor(.gray)
        }
    }
}

struct PhotoThumbnailView: View {
    let imageURL: URL
    @ObservedObject var viewModel: PhotosGridViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(contentsOfFile: imageURL.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 4)
                    )
            } else {
                Color.gray
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
            }

            if viewModel.isReferenceImage(imageURL) {
                Text("REF")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.blue.opacity(0.8))
                    .clipShape(Circle())
                    .offset(x: -5, y: 5)
            } else if viewModel.isSelected(imageURL),
                      let index = viewModel.selectedImages.firstIndex(of: imageURL) {
                Text("\(index)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Color.green.opacity(0.8))
                    .clipShape(Circle())
                    .offset(x: -5, y: 5)
            }
        }
    }

    private var borderColor: Color {
        if viewModel.isReferenceImage(imageURL) {
            return .blue
        } else if viewModel.isSelected(imageURL) {
            return .green
        } else {
            return .clear
        }
    }
}
