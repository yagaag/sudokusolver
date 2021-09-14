# Sudoku Solver

An iOS application that extracts and solves sudoku puzzles from images.

## Version 

1.0.0

## Availability

iOS 11.0+

## Demo

Here is a demo video of the application -> [Demo](https://youtu.be/5tjhwkz-fkw)

## Usage

![home](https://github.com/yagaag/sudokusolver/blob/main/images/home.png)

Step #1: Take an image of the puzzle you wish to solve

![take_photo](https://github.com/yagaag/sudokusolver/blob/main/images/take_photo.png)

Step #2: Click on 'Use photo'

![use_photo](https://github.com/yagaag/sudokusolver/blob/main/images/use_photo.png)

Step #3: The solved puzzle will be displayed. If there is no solution, you will be informed.

![solved_puzzle](https://github.com/yagaag/sudokusolver/blob/main/images/solved_puzzle.png)

## Working

### 1. Rectangle Detection

The outer rectangle of the puzzle is extracted using the Vision API's VNDetectRectanglesRequest.

![rectangle_detection](https://github.com/yagaag/sudokusolver/blob/main/images/rectangle_detection.png)

```swift
import Vision

// Create a request handler
let imageRequestHandler = VNImageRequestHandler(cgImage: image)
let rectDetectRequest = VNDetectRectanglesRequest { request, error in
    guard let results = request.results as? [VNRectangleObservation] else {
        fatalError("Request Failed!")
    }
    if results.count > 0 {
        print(results)
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
```

### 2. Prespective Correction

The extracted rectangle's perspective is corrected using the CIFilter - perspectiveCorrection().

![perspective_correction](https://github.com/yagaag/sudokusolver/blob/main/images/perspective_correction.png)

```swift
import CoreImage
import CoreImage.CIFilterBuiltins

let perspectiveCorrection = CIFilter.perspectiveCorrection()
perspectiveCorrection.inputImage = CIImage(cgImage: image)
perspectiveCorrection.topLeft = topLeft
perspectiveCorrection.topRight = topRight
perspectiveCorrection.bottomRight = bottomRight
perspectiveCorrection.bottomLeft = bottomLeft

let context = CIContext(options: nil)
let correctedImage = perspectiveCorrection.outputImage!
```

### 3. Cells Extraction

Individual cells are seperated from the resized, corrected rectangle based on coordinates.

![cell_extraction](https://github.com/yagaag/sudokusolver/blob/main/images/cell_extraction.png)

### 4. Digit Recognition

A custom CoreML model trained on the MNIST dataset + Blank cells generated randomly is used to classify the extracted cells into one of 10 classes (0-9, nil).

```swift
import CoreML

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
```

### 5. Solving the puzzle

After the digits are populated into an array, a backtracking algorithm is used to find the solution to the puzzle.

## Author

Yagaagowtham Palanikumar (gowthamyagaa@gmail.com)
