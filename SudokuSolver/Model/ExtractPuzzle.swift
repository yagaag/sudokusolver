//
//  ExtractPuzzle.swift
//  SudokuSolver
//
//  Created by Yagaagowtham P on 06/14/21.
//

import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreML

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    
    let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
    
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let scaledImage = renderer.image { _ in
        image.draw(in: rect)
    }
    
    return scaledImage
}

func extractBoundary(image: CGImage, imgView: UIImageView, rotate: Bool) -> UIImage {
    
    var topLeft = CGPoint(x: 0.0, y: 0.0)
    var topRight = CGPoint(x: 0.0, y: 0.0)
    var bottomLeft = CGPoint(x: 0.0, y: 0.0)
    var bottomRight = CGPoint(x: 0.0, y: 0.0)
    
    // #1: ID Rectangle
    // Create a request handler
    let imageRequestHandler = VNImageRequestHandler(cgImage: image)
    let rectDetectRequest = VNDetectRectanglesRequest { request, error in
        guard let results = request.results as? [VNRectangleObservation] else {
            fatalError("Request Failed!")
        }
        print(results)
        if results.count > 0 {
        topLeft = results[0].topLeft
        topRight = results[0].topRight
        bottomLeft = results[0].bottomLeft
        bottomRight = results[0].bottomRight
        print(topLeft, topRight, bottomLeft, bottomRight)
        }

    }
    // Customize & configure the request to detect only certain rectangles.
    rectDetectRequest.maximumObservations = 8 // Vision currently supports up to 16.
    rectDetectRequest.minimumConfidence = 0.4 // Be confident.
    rectDetectRequest.minimumAspectRatio = 0.3 // height / width
    
    rectDetectRequest.usesCPUOnly = false //allow Vision to utilize the GPU
    
    do {
        try imageRequestHandler.perform([rectDetectRequest])
    } catch {
        print("Error: Rectangle detection failed - vision request failed.")
    }
    
    // #2: Change perspective
    topLeft.x = CGFloat(image.width) * topLeft.x
    topLeft.y = CGFloat(image.height) * (topLeft.y)
    topRight.x = CGFloat(image.width) * topRight.x
    topRight.y = CGFloat(image.height) * (topRight.y)
    bottomLeft.x = CGFloat(image.width) * bottomLeft.x
    bottomLeft.y = CGFloat(image.height) * (bottomLeft.y)
    bottomRight.x = CGFloat(image.width) * bottomRight.x
    bottomRight.y = CGFloat(image.height) * (bottomRight.y)
    
    let perspectiveCorrection = CIFilter.perspectiveCorrection()
    perspectiveCorrection.inputImage = CIImage(cgImage: image)
    perspectiveCorrection.topLeft = topLeft
    perspectiveCorrection.topRight = topRight
    perspectiveCorrection.bottomRight = bottomRight
    perspectiveCorrection.bottomLeft = bottomLeft
    
    let context = CIContext(options: nil)
    let correctedImage = perspectiveCorrection.outputImage!
    let imageRef = context.createCGImage(correctedImage, from: correctedImage.extent)
    
    // #3: Resize to square
    let targetSize = CGSize(width: 900, height: 900)
    let sizedImage = resizeImage(image: UIImage(cgImage: imageRef!), targetSize: targetSize)
    
    // #4: If it has been rotated, rotate back and return
    if rotate {
        print("rotating")
        let cgImage = sizedImage.cgImage!
        return UIImage(cgImage: cgImage, scale: sizedImage.scale, orientation: .right)
    }
    
    return sizedImage
}

func extractCells(image: UIImage, rotate: Bool) -> [CGImage] {
    
    let newImage = image
    var cells =  [CGImage]()
    var x: Double = 0.0
    var y: Double = 0.0
    var tric_x: Double = 0.0
    var tric_y: Double = 0.0
    for i in 0..<9 {
        if i==3 || i==6 {
            tric_x += 3.0
        }
        for j in 0..<9 {
            if j==3 || j==6 {
                tric_y += 3.0
            }
            x = -450.0+11.0+(Double(i)*97.0)+tric_x
            y = 0.0+11.0+(Double(j)*97.0)+tric_y
            let rect = CGRect(x: x, y: y, width: 94.0, height: 94.0)
            cells.append(newImage.croppedInRect(rect: rect).cgImage!)
        }
    }
//    let rect = CGRect(x: -450.0+11.0, y: 0.0+11.0+97.0, width: 94.0, height: 94.0)
//    return newImage.croppedInRect(rect: rect)
    return cells
}

func extractText(image: CGImage) {
    
    print("Text...")
    
    // #1: ID Rectangle
    // Create a request handler
    let imageRequestHandler = VNImageRequestHandler(cgImage: image)
    let textDetectRequest = VNDetectTextRectanglesRequest { request, error in
        guard let results = request.results as? [VNRectangleObservation] else {
            fatalError("Request Failed!")
        }
        print(results)
        print(results.count)

    }
    
    textDetectRequest.usesCPUOnly = false //allow Vision to utilize the GPU
    
    do {
        try imageRequestHandler.perform([textDetectRequest])
    } catch {
        print("Error: Text detection failed - vision request failed.")
    }
    
}

extension UIImage {
    func croppedInRect(rect: CGRect) -> UIImage {
        func rad(_ degree: Double) -> CGFloat {
            return CGFloat(degree / 180.0 * .pi)
        }

        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height)
        default:
            rectTransform = .identity
        }
        rectTransform = rectTransform.scaledBy(x: self.scale, y: self.scale)

        let imageRef = self.cgImage!.cropping(to: rect.applying(rectTransform))
//        return imageRef!
        let result = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return result
    }
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

func detect(image: CGImage) {
        
    guard let model = try? VNCoreMLModel(for: MNISTClassifier().model) else {
        fatalError("Maybe loading CoreML Model failed")
    }
    
    let request = VNCoreMLRequest(model: model) { (request, error) in
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError("Classification Failed!")
        }
        
        print(results)
    }
    let handler = VNImageRequestHandler(cgImage: image)
    
    do {
        try handler.perform([request])
    }
    catch {
        print(error)
    }
}

func extractPuzzle(image: CGImage, imgView: UIImageView, rotate: Bool) -> UIImage {
    
    let croppedImage = extractBoundary(image: image, imgView: imgView, rotate: rotate)
    let cells = extractCells(image: croppedImage, rotate: rotate)
    for i in 0..<81 {
        let rotimg = UIImage(cgImage: cells[i]).rotate(radians: 1.5708)!
        let newimg = rotimg.cgImage!
        detect(image: newimg)
//        if i == 6 {
//            return UIImage(cgImage: newimg)
//        }
    }
    return croppedImage
//    extractText(image: cells[6])
}
