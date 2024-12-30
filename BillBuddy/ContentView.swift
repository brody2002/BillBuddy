//
//  ContentView.swift
//  BillPal
//
//  Created by Brody on 12/19/24.
//

import SwiftUI

struct ContentView: View {
    @State var totalCost: Double = 0.0
    @StateObject var totalCostManager = TotalCostManager()
    var body: some View {
        TabView{
            // Tipping View
            TippingView(totalCostManager: totalCostManager)
                .tabItem {
                    TabIconView(symbolName: "dollarsign.square.fill", text: "Tip")
                }
            SplitBillView(totalCostManager: totalCostManager)
                .tabItem{
                    TabIconView(symbolName: "chart.bar.doc.horizontal.fill", text: "Split")
                }
            // Bill Splitting View
        }
        .tabViewStyle(.tabBarOnly)
        
    }
    
}

class TotalCostManager: ObservableObject {
    @Published var totalCost: Double
    @Published var tax: Double
    @Published var tip: Double
    
    init(totalCost: Double = 0.0, tax: Double = 0.0, tip: Double = 0.0) {
        self.totalCost = totalCost
        self.tax = tax
        self.tip = tip // As calculated value not percentage
    }
}

#Preview {
    ContentView()
}
