//
//  SplitBillView.swift
//  BillBuddy
//
//  Created by Brody on 12/20/24.
//

import SwiftUI

struct SplitBillView: View {
    @ObservedObject var totalCostManager: TotalCostManager
    @State private var participants: Int = 2
    
    var body: some View {
        NavigationStack {
            ScrollView {
                totalPriceView(totalCostManager: totalCostManager)
                    .padding(.top, 32)
                VStack(spacing: 16) {
                    ForEach(0..<participants, id: \.self) { index in
                        ZStack {
                            ParticipantView(participantNumber: index + 1)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 336)
                AppInformationView()
            }
            .navigationTitle("Bill Splitter")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if participants > 3 { withAnimation(.spring(response: 0.2)){ participants -= 1 } }
                    }) {
                        Image(systemName: "minus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.spring(response: 0.2)){ participants += 1 }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }.fontDesign(.rounded)
    }
    
}

struct totalPriceView: View {
    @ObservedObject var totalCostManager: TotalCostManager
    var body: some View{
        VStack(spacing: 0){
            Text("Total")
                .font(.system(size: 20))
                .fontWeight(.bold)
            Text(String(format: "$%.2f", totalCostManager.totalCost))
                .font(.system(size: 40))
                .fontWeight(.bold)
        }
        
    }
}

#Preview {
    @Previewable @State var totalCostManager = TotalCostManager()
    SplitBillView(totalCostManager: totalCostManager)
}

struct ParticipantView: View {
    @State var individualTotalPrice: Double = 0.0
    @State var participantNumber: Int
    @State var inputName = ""
    @State private var items: [Item] = [Item(name: "", price: "")]
    var body: some View{
        ZStack{
            HStack(alignment: .top){
                VStack(alignment: .leading){
                    TextField(
                        "Person \(participantNumber)",
                        text: $inputName
                    )
                    .textFieldStyle(.plain)
                    .foregroundStyle(.pink)
                    
                    ForEach(0..<items.count, id: \.self) { index in
                        HStack {
                            TextField(
                                "Item Name",
                                text: Binding(
                                    get: { items[index].name },
                                    set: { items[index].name = $0 }
                                )
                            )
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150) // Adjust width for layout
                            HStack(spacing: 2){
                                Text("$")
                                TextField(
                                    "Price",
                                    text: Binding(
                                        get: { items[index].price },
                                        set: { newValue in
                                            if let doubleValue = Double(newValue) {
                                                items[index].price = String(format: "%.2f", doubleValue)
                                            } else {
                                                items[index].price = newValue
                                            }
                                        }
                                    )
                                )
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .frame(width: 80) // Adjust width for layout
                            }
                            
                        }
                    }
                    .padding(.bottom, 5)
                    HStack(spacing: 32){
                        Button(action: {
                            withAnimation(.spring(response: 0.3)){items.append(Item(name: "", price: ""))}
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                            }
                            .foregroundColor(.pink)
                        }
                        
                        Button(action: {
                            guard items.count >= 2 else { return }
                            withAnimation(.spring(response: 0.3)){items.removeLast(1)}
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                
                            }
                            .foregroundColor(.pink)
                        }
                        
                        
                    }
                    
                    
                    Spacer()
                }
                
                .font(.body.bold())
                Spacer()
                VStack{
                    Text(String(format: "$%.2f", individualTotalPrice))
                        .fontWeight(.bold)
                    
                    Image("Venmo Icon")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            .padding()
        }
        .onChange(of: items) { _, newValue in
            individualTotalPrice = newValue.reduce(0.0) { total, item in
                total + (Double(item.price) ?? 0.0)
            }
        }


        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 3))
                .fill(Color.black)
        )
        
        
    }
    
    struct Item: Equatable {
        var name: String
        var price: String
    }
}
