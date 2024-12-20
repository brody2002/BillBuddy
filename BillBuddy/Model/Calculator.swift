//
//  Calculator.swift
//  BillBuddy
//
//  Created by Brody on 12/19/24.
//

import Foundation

struct Calculator {
    
    static func calculateTip(_ inputTotal: Double, tip: Double) -> Double {
        let priceWithTip = inputTotal + (inputTotal * tip / 100)
        return priceWithTip
    }
}
