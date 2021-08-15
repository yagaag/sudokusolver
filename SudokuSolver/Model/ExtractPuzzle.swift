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

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    
    let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
    
    let renderer = UIGraphicsImageRenderer(size: targetSize)
    let scaledImage = renderer.image { _ in
        image.draw(in: rect)
    }
    
    return scaledImage
}

func detect(image: CGImage, imgView: UIImageView, rotate: Bool) -> UIImage {
    
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
        topLeft = results[0].topLeft
        topRight = results[0].topRight
        bottomLeft = results[0].bottomLeft
        bottomRight = results[0].bottomRight
        print(topLeft, topRight, bottomLeft, bottomRight)

    }
    // Customize & configure the request to detect only certain rectangles.
    rectDetectRequest.maximumObservations = 8 // Vision currently supports up to 16.
    rectDetectRequest.minimumConfidence = 0.6 // Be confident.
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
