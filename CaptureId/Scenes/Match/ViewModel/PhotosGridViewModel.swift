//
//  PhotosGridViewModel.swift
//  CaptureId
//
//  Created by Leandro Modena on 13/05/25.
//

import SwiftUI
import Vision

class PhotosGridViewModel: ObservableObject {
    @Published var allImages: [URL] = []
    @Published var selectedImages: [URL] = []

    // Resultados da detecção
    @Published var referenceFacesCount: Int = 0
    @Published var matchedFacesCount: Int = 0
    @Published var detectionMessage: String = ""

    // Threshold de similaridade
    private let similarityThreshold: Float = 0.25 // ajuste conforme testes

    init() {
        loadImagesFromCaptureFolder()
    }

    private func loadImagesFromCaptureFolder() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let captureFolderURL = documentsURL.appendingPathComponent("capture_images")

        do {
            let files = try fileManager.contentsOfDirectory(at: captureFolderURL, includingPropertiesForKeys: nil)
            allImages = files.filter { ["jpg", "jpeg", "png"].contains($0.pathExtension.lowercased()) }
        } catch {
            print("Erro ao listar imagens:", error)
            allImages = []
        }
    }

    func toggleSelection(for url: URL) {
        if let first = selectedImages.first, first == url {
            selectedImages.removeFirst()
        } else if selectedImages.contains(url) {
            selectedImages.removeAll { $0 == url }
        } else {
            selectedImages.append(url)
        }
    }

    func isReferenceImage(_ url: URL) -> Bool {
        return selectedImages.first == url
    }

    func isSelected(_ url: URL) -> Bool {
        return selectedImages.contains(url)
    }

    // Corrige orientação e retorna CGImagePropertyOrientation correspondente
    private func fixedOrientation(image: UIImage) -> UIImage {
        if image.imageOrientation == .up { return image }
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = image.scale
        rendererFormat.opaque = false
        let renderer = UIGraphicsImageRenderer(size: image.size, format: rendererFormat)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    // Detecta landmarks e retorna face recortada, rotacionada e padronizada
    private func detectAndNormalizeFace(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        let oriented = fixedOrientation(image: image)
        guard let cgImage = oriented.cgImage else {
            completion(nil)
            return
        }

        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: CGImagePropertyOrientation(oriented.imageOrientation), options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                guard let faceObs = (request.results?.first as? VNFaceObservation),
                      let landmarks = faceObs.landmarks,
                      let leftEye = landmarks.leftEye?.normalizedPoints,
                      let rightEye = landmarks.rightEye?.normalizedPoints else {
                    completion(nil)
                    return
                }

                // Calcular centro dos olhos em coordenadas de imagem
                let bounding = faceObs.boundingBox
                let imgW = oriented.size.width
                let imgH = oriented.size.height

                func pointInImage(_ normPoint: CGPoint) -> CGPoint {
                    let x = bounding.origin.x * imgW + normPoint.x * bounding.size.width * imgW
                    let y = (1 - bounding.origin.y - bounding.size.height) * imgH + (1 - normPoint.y) * bounding.size.height * imgH
                    return CGPoint(x: x, y: y)
                }

                // Média dos pontos do olho esquerdo e direito
                let leftEyePoints = leftEye.map { pointInImage(CGPoint(x: CGFloat($0.x), y: CGFloat($0.y))) }
                let rightEyePoints = rightEye.map { pointInImage(CGPoint(x: CGFloat($0.x), y: CGFloat($0.y))) }
                let leftCenter = leftEyePoints.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) } / CGFloat(leftEyePoints.count)
                let rightCenter = rightEyePoints.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) } / CGFloat(rightEyePoints.count)

                // Ângulo entre olhos
                let dy = rightCenter.y - leftCenter.y
                let dx = rightCenter.x - leftCenter.x
                let angle = atan2(dy, dx)

                // Rotacionar imagem para nivelar olhos
                let rotatedImage = self.rotate(image: oriented, by: -angle)
                guard let rotatedCG = rotatedImage.cgImage else {
                    completion(nil)
                    return
                }

                // Atualizar bounding box em imagem rotacionada: redetectar face rápido sem landmarks
                let faceRectRequest = VNDetectFaceRectanglesRequest()
                let faceHandler = VNImageRequestHandler(cgImage: rotatedCG, orientation: .up, options: [:])
                try faceHandler.perform([faceRectRequest])
                guard let faceRectObs = (faceRectRequest.results?.first as? VNFaceObservation) else {
                    completion(nil)
                    return
                }
                let bb = faceRectObs.boundingBox
                let x = bb.origin.x * rotatedImage.size.width
                let y = (1 - bb.origin.y - bb.height) * rotatedImage.size.height
                let w = bb.width * rotatedImage.size.width
                let h = bb.height * rotatedImage.size.height

                // Padding extra (20%)
                let paddingFactor: CGFloat = 0.2
                let padX = w * paddingFactor
                let padY = h * paddingFactor
                let cropX = max(0, x - padX/2)
                let cropY = max(0, y - padY/2)
                let cropW = min(rotatedImage.size.width - cropX, w + padX)
                let cropH = min(rotatedImage.size.height - cropY, h + padY)
                let cropRect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)

                guard let croppedCG = rotatedCG.cropping(to: cropRect) else {
                    completion(nil)
                    return
                }
                let cropped = UIImage(cgImage: croppedCG, scale: rotatedImage.scale, orientation: .up)
                // Redimensionar para tamanho fixo
                let standardized = self.resize(image: cropped, targetSize: CGSize(width: 256, height: 256))
                completion(standardized)
            } catch {
                print("Erro ao detectar landmarks ou recortar rosto:", error)
                completion(nil)
            }
        }
    }

    // Rotaciona UIImage em radianos
    private func rotate(image: UIImage, by radians: CGFloat) -> UIImage {
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = image.scale
        rendererFormat.opaque = false
        let renderer = UIGraphicsImageRenderer(size: image.size, format: rendererFormat)
        return renderer.image { ctx in
            ctx.cgContext.translateBy(x: image.size.width/2, y: image.size.height/2)
            ctx.cgContext.rotate(by: radians)
            image.draw(in: CGRect(x: -image.size.width/2, y: -image.size.height/2, width: image.size.width, height: image.size.height))
        }
    }

    // Redimensiona UIImage para targetSize
    private func resize(image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    // Gera feature print de UIImage padronizada
    private func generateFeaturePrint(for image: UIImage, completion: @escaping (VNFeaturePrintObservation?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        let request = VNGenerateImageFeaturePrintRequest { request, error in
            if let error = error {
                print("Erro ao gerar feature print:\(error)")
                completion(nil)
                return
            }
            let results = request.results as? [VNFeaturePrintObservation]
            completion(results?.first)
        }
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        do { try handler.perform([request]) } catch { print("Erro ao executar request Vision:\(error)"); completion(nil) }
    }

    // Compara duas imagens recortadas e padronizadas
    private func compareFaces(refImage: UIImage, otherImage: UIImage) -> (Bool, Float) {
        var result: (Bool, Float) = (false, Float.infinity)
        let semaphore = DispatchSemaphore(value: 0)

        generateFeaturePrint(for: refImage) { refFeature in
            guard let refFeature = refFeature else { semaphore.signal(); return }
            self.generateFeaturePrint(for: otherImage) { otherFeature in
                guard let otherFeature = otherFeature else { semaphore.signal(); return }
                var distance: Float = 0
                do {
                    try refFeature.computeDistance(&distance, to: otherFeature)
                    let similar = distance < self.similarityThreshold
                    result = (similar, distance)
                } catch {
                    print("Erro ao calcular distância:\(error)")
                }
                semaphore.signal()
            }
        }
        semaphore.wait()
        return result
    }

    // Função principal de detecção e matching
    func detectAndCompareFacesWithMatching() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let refURL = self.selectedImages.first,
                  let refImage = UIImage(contentsOfFile: refURL.path) else {
                DispatchQueue.main.async { self.detectionMessage = "Selecione uma foto de referência válida." }
                return
            }
            self.detectAndNormalizeFace(from: refImage) { croppedRef in
                guard let croppedRef = croppedRef else {
                    DispatchQueue.main.async { self.detectionMessage = "Não foi possível recortar o rosto da referência." }
                    return
                }
                var summaryResults: [String] = []
                var countMatches = 0
                var index = 1
                for url in self.selectedImages.dropFirst() {
                    if let otherImage = UIImage(contentsOfFile: url.path) {
                        self.detectAndNormalizeFace(from: otherImage) { croppedOther in
                            guard let croppedOther = croppedOther else {
                                summaryResults.append("Imagem \(index): sem rosto detectado.")
                                index += 1
                                return
                            }
                            let (similar, distance) = self.compareFaces(refImage: croppedRef, otherImage: croppedOther)
                            if similar {
                                summaryResults.append("Imagem \(index): Faces semelhantes (dist: \(String(format: "%.3f", distance))).")
                                countMatches += 1
                            } else {
                                summaryResults.append("Imagem \(index): Face detectada, matching falhou (dist: \(String(format: "%.3f", distance))).")
                            }
                            index += 1
                        }
                    } else {
                        summaryResults.append("Imagem \(index): falha ao carregar imagem.")
                        index += 1
                    }
                }
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    DispatchQueue.main.async {
                        self.matchedFacesCount = countMatches
                        let total = self.selectedImages.count - 1
                        self.detectionMessage = "\(countMatches)/\(total) matches encontrados:\n" + summaryResults.joined(separator: "\n")
                    }
                }
            }
        }
    }
}

// Extensão helper para converter UIImage.Orientation → CGImagePropertyOrientation
extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}

extension CGPoint {
    static func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x / scalar, y: point.y / scalar)
    }
}

