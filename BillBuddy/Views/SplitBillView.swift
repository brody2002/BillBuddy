//
//  SplitBillView.swift
//  BillBuddy
//
//  Created by Brody on 12/20/24.
//

import SwiftUI

struct SplitBillView: View {
    @FocusState var focusField: FocusView?
    @ObservedObject var totalCostManager: TotalCostManager
    @State private var participants: Int = 2
    @State var splitTotal: Double = 0.0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack(spacing: 48){
                    totalPriceView(totalCostManager: totalCostManager)
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                    SplitTotalView(splitTotal: $splitTotal)
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                    
                }
                .padding(.top, 32)
                VStack(spacing: 16) {
                    ForEach(0..<participants, id: \.self) { index in
                        ZStack {
                            ParticipantView(participantNumber: index + 1, splitTotal: $splitTotal)
                                .focused($focusField, equals: .participant)
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
                        if participants > 2 { withAnimation(.spring(response: 0.2)){ participants -= 1 } }
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
            .onTapGesture {
                focusField = nil
            }
        }.fontDesign(.rounded)
    }
    
}

struct totalPriceView: View {
    @ObservedObject var totalCostManager: TotalCostManager
    var dynamicFont: CGFloat {
        if String(format: "$%.2f", totalCostManager.totalCost).count > 7 { return 20.0 }
        else { return 30.0}
    }
    var body: some View{
        VStack(spacing: 0){
            Text("Total")
                .font(.system(size: 20))
                .fontWeight(.bold)
            Text(String(format: "$%.2f", totalCostManager.totalCost))
                .font(.system(size: dynamicFont))
                .fontWeight(.bold)
        }
        
    }
}

struct SplitTotalView: View {
    @Binding var splitTotal : Double
    var dynamicFont: CGFloat {
        if String(format: "$%.2f", splitTotal).count > 7 { return 20.0 }
        else { return 30.0}
    }
    
    var body : some View{
        VStack(spacing: 0){
            Text("Spit Total")
                .font(.system(size: 20))
                .fontWeight(.bold)
            Text(String(format: "$%.2f", splitTotal))
                .font(.system(size: dynamicFont))
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
    @State var previousTotalPrice: Double = 0.0
    @State var participantNumber: Int
    @State var inputName = ""
    @State private var items: [Item] = [Item(name: "", price: "")]
    @Binding var splitTotal: Double
    var dynamicFontSize: CGFloat { if String(format: "$%.2f", individualTotalPrice).count > 6 { return 14.0 } else {return 18.0} }
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
                            
                                Text("$")
                                .offset(x: 4)
                            
                                TextField(
                                    "Price",
                                    text: Binding(
                                        get: { items[index].price },
                                        set: { items[index].price = $0 }
                                    )
                                )
                                .onChange(of: items[index].price) {
                                    let doublePrice = Double($1)
                                    if doublePrice ?? 0.0  > 9999.99 {
                                        items[index].price = String($1.prefix(4))
                                    }
                                }
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                            
                            
                        }
                    }
                    .padding(.bottom, 5)
                    Spacer()
                        .frame(height: 10)
                    
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
                    .offset(y: 5)
                    
                    
                    Spacer()
                }
                
                .font(.body.bold())
                Spacer()
                VStack{
                    Text(String(format: "$%.2f", individualTotalPrice))
                        .font(.system(size: dynamicFontSize).bold())
                        .frame(width: 70)
                        .offset(x:5)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image("Venmo Icon")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .padding(.leading, 20)
                    
                }
            }
            .padding()
        }
        .onChange(of: items) { _, newValue in
            individualTotalPrice = newValue.reduce(0.0) { total, item in
                total + (Double(item.price) ?? 0.0)
            }
            splitTotal += individualTotalPrice - previousTotalPrice
            previousTotalPrice = individualTotalPrice
            
            
            
        }
        
        
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 6))
                .fill(Color.black)
        )
        
        
    }
    
    struct Item: Equatable {
        var name: String
        var price: String
    }
}
