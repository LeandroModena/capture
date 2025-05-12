//
//  CameraPreview.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import SwiftUI
import AVFoundation

struct CameraCapturePreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    init(session: AVCaptureSession) {
        self.session = session
    }

    func makeUIView(context: Context) -> UIView {
        let view = PreviewView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Nada a atualizar dinamicamente por enquanto
    }

    class PreviewView: UIView {
        private var previewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }

        var session: AVCaptureSession? {
            get { previewLayer.session }
            set { previewLayer.session = newValue }
        }

        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
    }
}
