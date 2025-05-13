//
//  CaptureViewModel.swift
//  CaptureId
//
//  Created by Leandro Modena on 11/05/25.
//

import SwiftUI
import AVFoundation

class CaptureViewModel: ObservableObject {
    @Published var identifier: String = ""
    @Published var cameraPermissionDenied = false

    func iniciarCaptura() {
        //switch AVCaptureDevice.authorizationStatus(for: .video) {
       // case .authorized:
            //openCamera()
       // case .notDetermined:
         //   AVCaptureDevice.requestAccess(for: .video) { granted in
         //       DispatchQueue.main.async {
            //        if granted {
                        //self.openCamera()
         //           } else {
         //               self.cameraPermissionDenied = true
        //            }
       //         }
     //       }
      //  default:
     //       cameraPermissionDenied = true
      //  }
    }
}

