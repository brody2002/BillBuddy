//
//  Participant.swift
//  BillBuddy
//
//  Created by Brody on 12/22/24.
//

import Foundation


struct Participant {
    var name: String
    var purchasedDict: [String : Double]
    var participantTotal: Double
    
    init(name: String, purchasedDict: [String : Double], participantTotal: Double = 0.0) {
        self.name = name
        self.purchasedDict = purchasedDict
        self.participantTotal = participantTotal
    }
}
