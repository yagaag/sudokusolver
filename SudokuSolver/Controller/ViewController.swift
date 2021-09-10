//
//  ViewController.swift
//  SudokuSolver
//
//  Created by Yagaagowtham P on 06/14/21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    var result: [[Int]] = [[0]]
    
    @IBOutlet weak var imgDisplay: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false

    }
    
    func solve() {
        let arr: [[Int]] = [[0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0]]
        
        
        let (newArr, solved) = solveSudoku(arr: arr)
        if solved {
            print(newArr)
            result = newArr
//            self.performSegue(withIdentifier: "presentResult", sender: self)
        }
        else {
            print("Could not solve")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            guard let cgimage = userPickedImage.cgImage else {
                fatalError("Could not convert to CIImage!")
            }
            var rotate: Bool = true
            if Int(userPickedImage.size.height) == cgimage.height {
                rotate = false
            }
            let newImg = extractPuzzle(image: cgimage, imgView: imgDisplay, rotate: rotate)
//            let newImg = extractBoundary(image: cgimage, imgView: imgDisplay, rotate: rotate)
//            let newerImg = extractCells(image: newImg, rotate: rotate)
            imgDisplay.image = newImg
            
            //detect(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true) {
            //self.performSegue(withIdentifier: "presentResult", sender: self)
        }
    }
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }

}

extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "presentResult" {
            let destinationVC = segue.destination as! ResultViewController
            destinationVC.result = result
            
            let vc = UIViewController();
            vc.modalPresentationStyle = .fullScreen
        }
    }
}

