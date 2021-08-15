//
//  ExtractPuzzle.swift
//  SudokuSolver
//
//  Created by Yagaagowtham P on 06/14/21.
//

import UIKit
import Vision

func cropImage(image: UIImage, withinPoints points:[CGPoint], rotate: Bool) -> UIImage {
    
    let ofImageView = UIImageView(image: image)
        
    //Check if there is start and end points exists
    let path = UIBezierPath()
    let shapeLayer = CAShapeLayer()
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineWidth = 2
    var croppedImage: UIImage = image
    
    for (index,point) in points.enumerated() {
        
        //Origin
        if index == 0 {
            path.move(to: point)
            
        //Endpoint
        } else if index == points.count-1 {
            path.addLine(to: point)
            path.close()
            shapeLayer.path = path.cgPath
            
            ofImageView.layer.addSublayer(shapeLayer)
            shapeLayer.fillColor = UIColor.black.cgColor
            ofImageView.layer.mask = shapeLayer
            UIGraphicsBeginImageContextWithOptions(ofImageView.frame.size, false, 1)
            
            if let currentContext = UIGraphicsGetCurrentContext() {
                ofImageView.layer.render(in: currentContext)
            }
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()
            
            croppedImage = newImage!
            
            //Move points
        } else {
            path.addLine(to: point)
        }
    }
    
    if rotate {
        print("rotating")
        let cgImage = croppedImage.cgImage!
        return UIImage(cgImage: cgImage, scale: croppedImage.scale, orientation: .right)
    }
    return croppedImage
}

//func cropImg(image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> UIImage {
//
//    let imageSize = changedImage.extent.size
//
//        // Verify detected rectangle is valid.
//        let boundingBox = detectedRectangle.boundingBox.scaled(to: imageSize)
//        guard changedImage.extent.contains(boundingBox)
//            else { return }
//
//        let newTopLeft = topLeft.scaled(to: imageSize)
//        let newTopRight = detectedRectangle.topRight.scaled(to: imageSize)
//        let newBottomLeft = detectedRectangle.bottomLeft.scaled(to: imageSize)
//        let newBottomRight = detectedRectangle.bottomRight.scaled(to: imageSize)
//
//            let correctedImage = changedImage
//            .cropped(to: boundingBox)
//
//
//    let cgimage = image.cgImage!
//
//    let rect: CGRect = CGRect(x: CGFloat(cgimage.width) * topLeft.x, y: CGFloat(cgimage.height) * topLeft.y, width: CGFloat(cgimage.width) * (bottomRight.x-topLeft.x), height: CGFloat(cgimage.height) * (bottomRight.y-topLeft.y))
//
//    // Create bitmap image from context using the rect
//    let imageRef: CGImage = cgimage.cropping(to: rect)!
//
//    // Create a new image based on the imageRef and rotate back to the original orientation
//    let newImage: UIImage = UIImage(cgImage: imageRef)
//    return newImage
//
//}

func detect(image: CGImage, imgView: UIImageView, rotate: Bool) -> UIImage {
    
    //let portraitImage = UIImage(cgImage: image, scale: UIImage(cgImage: image).scale, orientation: .right)
    //let newImage = portraitImage.cgImage!
    
    var topLeft = CGPoint(x: 0.0, y: 0.0)
    var topRight = CGPoint(x: 0.0, y: 0.0)
    var bottomLeft = CGPoint(x: 0.0, y: 0.0)
    var bottomRight = CGPoint(x: 0.0, y: 0.0)
    
    // Create a request handler.
    let imageRequestHandler = VNImageRequestHandler(cgImage: image)
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
    
    var newTopLeft = CGPoint(x: 0.0, y: 0.0)
    var newTopRight = CGPoint(x: 0.0, y: 0.0)
    var newBottomLeft = CGPoint(x: 0.0, y: 0.0)
    var newBottomRight = CGPoint(x: 0.0, y: 0.0)
    
    newTopLeft.x = CGFloat(image.width) * topLeft.x
    newTopLeft.y = CGFloat(image.height) * (1-topLeft.y)
    newTopRight.x = CGFloat(image.width) * topRight.x
    newTopRight.y = CGFloat(image.height) * (1-topRight.y)
    newBottomLeft.x = CGFloat(image.width) * bottomLeft.x
    newBottomLeft.y = CGFloat(image.height) * (1-bottomLeft.y)
    newBottomRight.x = CGFloat(image.width) * bottomRight.x
    newBottomRight.y = CGFloat(image.height) * (1-bottomRight.y)

//    DispatchQueue.global().async {
//        do {
//            try imageRequestHandler.perform([rectDetectRequest])
//        } catch {
//            print("Error: Rectangle detection failed - vision request failed.")
//        }
//    }
    let coords = [newTopLeft, newTopRight, newBottomRight, newBottomLeft]
    print(coords)
    //return UIImage(cgImage: image)
    return cropImage(image: UIImage(cgImage: image), withinPoints: coords, rotate: rotate)
}


