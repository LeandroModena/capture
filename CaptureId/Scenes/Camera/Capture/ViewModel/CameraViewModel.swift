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
    
    func configure() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.beginConfiguration()
            
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
            // self.capturedImage = image
            print("Foto capturada com sucesso")
        }
    }
}
