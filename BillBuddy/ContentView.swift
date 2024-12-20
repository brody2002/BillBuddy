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
    @Published var totalCost: Double = 0.0
}

#Preview {
    ContentView()
}
