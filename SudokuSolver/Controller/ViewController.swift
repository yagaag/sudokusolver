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

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false

    }
    
    func solve(arr: [[Int]]) {
        
        let (newArr, solved) = solveSudoku(arr: arr)
        if solved {
            result = newArr
            self.performSegue(withIdentifier: "presentResult", sender: self)
        }
        else {
            print("Could not solve the puzzle")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var puzzle: [[Int]] = [[0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0],
                               [0, 0, 0, 0, 0, 0, 0, 0, 0]]
        
        imagePicker.dismiss(animated: true) {
            //self.performSegue(withIdentifier: "presentResult", sender: self)
        }
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            guard let cgimage = userPickedImage.cgImage else {
                fatalError("Could not convert to CIImage!")
            }
            var rotate: Bool = true
            if Int(userPickedImage.size.height) == cgimage.height {
                rotate = false
            }
            puzzle = extractPuzzle(image: cgimage, rotate: rotate)
        }
        
        solve(arr: puzzle)
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
