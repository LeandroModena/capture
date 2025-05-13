//
//  PhotosGridViewModel.swift
//  CaptureId
//
//  Created by Leandro Modena on 13/05/25.
//

import Foundation

class PhotosGridViewModel: ObservableObject {
    @Published var photos: [CapturedPhoto] = []

    func loadImages() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let captureFolderURL = documentsURL.appendingPathComponent("capture_images")

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: captureFolderURL, includingPropertiesForKeys: nil)
            let imageFiles = fileURLs.filter { $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "jpeg" }
            let capturedPhotos = imageFiles.map { CapturedPhoto(url: $0) }

            DispatchQueue.main.async {
                self.photos = capturedPhotos
            }
        } catch {
            print("Erro ao carregar imagens: \(error)")
        }
    }
}
