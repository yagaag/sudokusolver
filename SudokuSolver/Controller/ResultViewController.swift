//
//  ResultViewController.swift
//  SudokuSolver
//
//  Created by Yagaagowtham P on 06/17/21.
//

import UIKit

class ResultViewController: UIViewController {
    
    var result: [[Int]]?
    
    @IBOutlet var collectionOfLabels:[UILabel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<81 {
            collectionOfLabels?[i].layer.borderColor = UIColor.systemIndigo.cgColor
            collectionOfLabels?[i].layer.borderWidth = 2.0
            collectionOfLabels?[i].text = String(result![i/9][i%9])
        }
    }
    
}
