//
//  CameraViewModel.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import AVFoundation
import SwiftUI

class CameraViewModel: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()

    @Published var capturedImage: UIImage?
    @Published var savedImageURL: URL?
    @Published var shouldDismiss = false


    func configure() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                print("Erro ao configurar entrada da câmera")
                return
            }
            
            self.session.addInput(input)
            
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            } else {
                print("Erro ao adicionar saída de foto")
                return
            }
            
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    func captureImage() {
        let settings = AVCapturePhotoSettings()
        DispatchQueue.global(qos: .userInitiated).async {
            guard let connection = self.photoOutput.connection(with: .video),
                  connection.isActive, connection.isEnabled else {
                print("Conexão de vídeo inválida")
                return
            }
            
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    private func saveImageToAppDirectory(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            print("Falha ao converter UIImage para JPEG")
            return
        }

        let folderName = "capture_images"
        let fileName = UUID().uuidString + ".jpg"

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderURL = documentsURL.appendingPathComponent(folderName)

        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Erro ao criar diretório \(folderName): \(error)")
                return
            }
        }

        let fileURL = folderURL.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            DispatchQueue.main.async {
                self.savedImageURL = fileURL
                self.shouldDismiss = true
                print("Imagem salva com sucesso em: \(fileURL)")
            }
        } catch {
            print("Erro ao salvar imagem: \(error)")
        }
    }

}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            print("Erro ao capturar foto: \(error.localizedDescription)")
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            print("Erro ao processar os dados da foto")
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }

        saveImageToAppDirectory(image)
    }
}
