//
//  SharedItem.swift
//  BillBuddy
//
//  Created by Brody on 1/3/25.
//

import Foundation

struct SharedItem: Hashable {
    var name: String
    var price: String
    
    init(name: String = "", price: String = "") {
        self.name = name
        self.price = price
    }
    
    var priceAsDouble: Double {
            Double(price) ?? 0.0
    }
}
