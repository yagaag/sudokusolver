//
//  ResultViewController.swift
//  SudokuSolver
//
//  Created by Yagaagowtham P on 06/17/21.
//

import UIKit

class ResultViewController: UIViewController {
    
    var result: [[Int]]?
    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var k1: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        k1.layer.borderColor = UIColor.darkGray.cgColor
        k1.layer.borderWidth = 3.0
    }
    
}
