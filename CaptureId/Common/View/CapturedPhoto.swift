//
//  CapturedPhoto.swift
//  CaptureId
//
//  Created by Leandro Modena on 13/05/25.
//

import Foundation
import UIKit

struct CapturedPhoto: Identifiable {
    let id = UUID()
    let url: URL
    var image: UIImage? {
        UIImage(contentsOfFile: url.path)
    }
}
