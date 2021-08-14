//
//  ExtractPuzzle.swift
//  SudokuSolver
//
//  Created by Yagaagowtham P on 06/14/21.
//

import UIKit
import Vision

func cropImg(image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> UIImage {

    let cgimage = image.cgImage!

    let rect: CGRect = CGRect(x: CGFloat(cgimage.width) * topLeft.x, y: CGFloat(cgimage.height) * topLeft.y, width: CGFloat(cgimage.width) * (bottomRight.x-topLeft.x), height: CGFloat(cgimage.height) * (bottomRight.y-topLeft.y))

    // Create bitmap image from context using the rect
    let imageRef: CGImage = cgimage.cropping(to: rect)!

    // Create a new image based on the imageRef and rotate back to the original orientation
    let newImage: UIImage = UIImage(cgImage: imageRef)
    return newImage

}

func detect(image: CIImage) -> UIImage {
    
    var topLeft = CGPoint(x: 0.0, y: 0.0)
    var topRight = CGPoint(x: 0.0, y: 0.0)
    var bottomLeft = CGPoint(x: 0.0, y: 0.0)
    var bottomRight = CGPoint(x: 0.0, y: 0.0)
    
    // Create a request handler.
    let imageRequestHandler = VNImageRequestHandler(ciImage: image)
    let rectDetectRequest = VNDetectRectanglesRequest { request, error in
        guard let results = request.results as? [VNRectangleObservation] else {
            fatalError("Request Failed!")
        }
        print("Reached daw")
        print(results)
        topLeft = results[0].topLeft
        topRight = results[0].topRight
        bottomLeft = results[0].bottomLeft
        bottomRight = results[0].bottomRight
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

//    DispatchQueue.global().async {
//        do {
//            try imageRequestHandler.perform([rectDetectRequest])
//        } catch {
//            print("Error: Rectangle detection failed - vision request failed.")
//        }
//    }
    return cropImg(image: image, topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
}


