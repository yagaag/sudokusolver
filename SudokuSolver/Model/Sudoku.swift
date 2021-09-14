//
//  Sudoku.swift
//  SudokuSolver
//
//  Created by Yagaagowtham P on 06/14/21.
//

import Foundation

func findEmptyLocation(arr: [[Int]], l: [Int]) -> ([Int], Bool) {
    var newL = [0, 0]
    for row in 0..<9 {
        for col in 0..<9 {
            if arr[row][col] == 0 {
                newL[0] = row
                newL[1] = col
                return (newL, true)
            }
        }
    }
    return (newL, false)
}

func usedInRow(arr: [[Int]], row: Int, num: Int) -> Bool {
    for col in 0..<9 {
        if arr[row][col] == num {
            return true
        }
    }
    return false
}

func usedInCol(arr: [[Int]], col: Int, num: Int) -> Bool {
    for row in 0..<9 {
        if arr[row][col] == num {
            return true
        }
    }
    return false
}

func usedInBox(arr: [[Int]], row: Int, col: Int, num: Int) -> Bool {
    for i in 0..<3 {
        for j in 0..<3 {
            if arr[i+row][j+col] == num {
                return true
            }
        }
    }
    return false
}

func checkLocationSafety(arr: [[Int]], row: Int, col: Int, num: Int) -> Bool {
    return usedInRow(arr: arr, row: row, num: num) || usedInCol(arr: arr, col: col, num: num) || usedInBox(arr: arr, row: (row-(row%3)), col: (col-(col%3)), num: num) ? false : true
}

func solveSudoku(arr: [[Int]]) -> ([[Int]], Bool) {
    
    var newArr = arr
    
    let (l, locationAvailable) = findEmptyLocation(arr: newArr, l: [0, 0])
    if !locationAvailable {
        return (newArr, true)
    }
    
    let row = l[0]
    let col = l[1]
    
    for num in 1..<10 {
        if checkLocationSafety(arr: newArr, row: row, col: col, num: num) {
            newArr[row][col] = num
            let (newerArr, solved) = solveSudoku(arr: newArr)
            if solved {
                return (newerArr, true)
            }
            newArr[row][col] = 0
        }
    }
    return (newArr, false)
}

