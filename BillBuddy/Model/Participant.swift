//
//  Participant.swift
//  BillBuddy
//
//  Created by Brody on 12/22/24.
//



import Foundation
import SwiftUI


class Participant: ObservableObject, Equatable {
    @Published var name: String
    @Published var purchasedDict: [String: Double]
    @Published var participantTotal: Double
    
    init(name: String, purchasedDict: [String: Double], participantTotal: Double) {
        self.name = name
        self.purchasedDict = purchasedDict
        self.participantTotal = participantTotal
    }
    
    static func == (lhs: Participant, rhs: Participant) -> Bool {
        if lhs.name == rhs.name && lhs.purchasedDict == rhs.purchasedDict { return true }
        else { return false }
    }
}

//struct Participant: Equatable {
//    var name: String
//    var purchasedDict: [String : Double]
//    var participantTotal: Double
//    
//    init(name: String, purchasedDict: [String : Double], participantTotal: Double = 0.0) {
//        self.name = name
//        self.purchasedDict = purchasedDict
//        self.participantTotal = participantTotal
//    }
//    
//    static func == (lhs: Participant, rhs: Participant) -> Bool {
//        if lhs.name == rhs.name && lhs.purchasedDict == rhs.purchasedDict { return true }
//        else { return false }
//    }
//}


