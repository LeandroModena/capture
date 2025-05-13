//
//  CaptureViewModel.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import SwiftUI
import AVFoundation

class CaptureViewModel: ObservableObject {
    @Published var authorized = false
    @Published var permissionChecked = false

    func iniciarCaptura() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorized = true
            permissionChecked = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.authorized = granted
                    self.permissionChecked = true
                }
            }
        default:
            authorized = false
            permissionChecked = true
        }
    }
}
