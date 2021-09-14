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

func extractBoundary(image: CGImage, rotate: Bool) -> UIImage {
    
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
        if results.count > 0 {
            topLeft = results[0].topLeft
            topRight = results[0].topRight
            bottomLeft = results[0].bottomLeft
            bottomRight = results[0].bottomRight
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
    topLeft.y = CGFloat(image.height) * topLeft.y
    topRight.x = CGFloat(image.width) * topRight.x
    topRight.y = CGFloat(image.height) * topRight.y
    bottomLeft.x = CGFloat(image.width) * bottomLeft.x
    bottomLeft.y = CGFloat(image.height) * bottomLeft.y
    bottomRight.x = CGFloat(image.width) * bottomRight.x
    bottomRight.y = CGFloat(image.height) * bottomRight.y
    
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
    return cells
}

func convertToMLMultiArray(image: UIImage) -> MLMultiArray? {
    let userSketch = try? MLMultiArray(shape:[1, NSNumber(value: 28), NSNumber(value: 28), 1], dataType:.double)
    for i in 0..<28 {
        for j in 0..<28 {
            var color = image.getPixelColor(pos: CGPoint(x: i, y: 28-j))
            if color >= 128.0 && color < 235.0 {
                color = color+20.0
            }
            else if color >= 235.0 {
                color = 255.0
            }
            else if color < 128.0 && color >= 20.0 {
                color = color-20.0
            }
            else {
                color = 0.0
            }
            print(i, j, color)
            userSketch?[[0, i, j, 0] as [NSNumber]] = NSNumber(floatLiteral: Double(color/255.0))
        }
    }
    return userSketch!
}

func detect(arr: MLMultiArray) -> Int {
    
    var prediction = [Double]()
        
    guard let model = try? DigitRecogniser()
    else {
        return 10
    }
    
    let input = DigitRecogniserInput(conv2d_1_input: arr)
    
    if let modelOutput = try? model.prediction(input: input) {
        for index in 0..<11 {
            prediction.append(modelOutput.Identity[index].doubleValue)
        }
    }
    else {
        return 10
    }
    let predID = Int(prediction.firstIndex(of: prediction.max() ?? prediction[9]) ?? 10)
    return predID
}

func extractPuzzle(image: CGImage, rotate: Bool) -> [[Int]] {
    
    let croppedImage = extractBoundary(image: image, rotate: rotate)
    let cells = extractCells(image: croppedImage, rotate: rotate)
    
    var puzzle: [[Int]] = [[0, 0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0, 0],
                           [0, 0, 0, 0, 0, 0, 0, 0, 0]]
    
    for i in 0..<81 {
        var img = UIImage(cgImage: cells[i]).rotate(radians: 1.5708)!
        img = img.noir!
        img = resizeImage(image: img, targetSize: CGSize(width: 28, height: 28))
        let arr = convertToMLMultiArray(image: img)
        var val = detect(arr: arr!)
        if val == 10 {
            val = 0
        }
        puzzle[i%9][i/9] = val
    }
    print(puzzle)
    return puzzle
}
