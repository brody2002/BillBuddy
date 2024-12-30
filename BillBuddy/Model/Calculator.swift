//
//  Calculator.swift
//  BillBuddy
//
//  Created by Brody on 12/19/24.
//

import Foundation

struct Calculator {
    
    static func calculateTip(_ inputTotal: Double, tip: Double, tax: Double) -> Double {
        let totalWithTax = inputTotal + tax
        let priceWithTip = totalWithTax + (totalWithTax * tip / 100)
        return priceWithTip
    }
}
