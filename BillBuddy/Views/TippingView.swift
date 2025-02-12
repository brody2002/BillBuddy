//
//  TippingView.swift
//  BillPal
//
//  Created by Brody on 12/19/24.
//

import SwiftUI

struct TippingView: View {
    @ObservedObject var totalCostManager: TotalCostManager
    @State private var totalNumber: Double = 0.0
    @State private var tip: Int = 0
    @State private var tax: Double = 0.0
    
    @FocusState var focusField: FocusView?
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                   
                    // Total and Tip
                    VStack(spacing: 16) {
                        HStack {
                            InfoCardView(
                                title: "Subtotal",
                                value: $totalNumber,
                                fontSize: 30,
                                placeholder: "$10.00",
                                focusField: _focusField
                            )
                            .focused($focusField, equals: .totalFocus)
                            
                            InfoCardView(
                                title: "Tax",
                                value: $tax,
                                fontSize: 30,
                                placeholder: "$10.00",
                                focusField: _focusField
                            )
                            .focused($focusField, equals: .tax)
                            
                            
                        }
                        .padding(.top, 32)
                        
                       
                        
                        TipGaugeView(totalNumber: $totalNumber, tip: $tip, tax: $tax)
//                            .padding(.top, 16)
                        
                        InfoCardView(
                            title: "Tip",
                            value: $tip,
                            fontSize: 30,
                            placeholder: "10%",
                            focusField: _focusField
                        )
                        .focused($focusField, equals: .tipFocus)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                    .onChange(of: totalNumber){ _, newTotalNumber in
                        totalCostManager.totalCost = Calculator.calculateTip(newTotalNumber, tip: Double(tip), tax: tax)
                        print("totalCost: \(totalCostManager.totalCost)")
                    }
                    .onChange(of: tip){ _, newTip in
                        totalCostManager.totalCost = Calculator.calculateTip(totalNumber, tip: Double(newTip), tax: tax)
                        print("totalCost: \(totalCostManager.totalCost)")
                        let tipPercent: Double = Double(newTip) / 100
                        totalCostManager.tip = (totalNumber + tax) * tipPercent
                        print("tip is now \(totalCostManager.tip)")
                    }
                    .onChange(of: tax){ _, newTax in
                        totalCostManager.totalCost = Calculator.calculateTip(totalNumber, tip: Double(tip), tax: newTax)
                        totalCostManager.tax = newTax
                    }
                    
                    
                    Divider()
                        .opacity(0.0)
                        .padding(.bottom, 144)
                    
                    AppInformationView()
                    
                    
                }
            }
            .fontDesign(.rounded)
            .navigationTitle("Tip Calculator")
            .navigationBarTitleDisplayMode(.automatic)
        }
        .onTapGesture {
            focusField = nil // Dismiss the keyboard
        }
    }
    
}



#Preview {
    @Previewable @State var totalCostManager = TotalCostManager()
    TippingView(totalCostManager: totalCostManager)
}


struct TipGaugeView: View {
    @Binding var totalNumber: Double
    @Binding var tip: Int
    @Binding var tax: Double
    
    private var dynamicFont: CGFloat {
        let stringCount = String(format: "$%.2f", Calculator.calculateTip(totalNumber, tip: Double(tip), tax: tax)).count
        if stringCount < 7 { return 38 }
        else if stringCount < 9 { return 34}
        else { return 24 }
    }

    
    var body: some View {
        VStack{
            ZStack{
                Text(String("$9999.99")) // PlaceHolder
                    .font(.system(size: 44))
                    .fontWeight(.bold)
                    .frame(width: 200)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                    .padding(64)
                    .hidden()
                Text(String(format: "$%.2f", Calculator.calculateTip(totalNumber, tip: Double(tip), tax: tax)))
                    .font(.system(size: dynamicFont))
                    .fontWeight(.bold)
                    .frame(width: 200)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                    .padding(64)
            }
            .padding()
            .background {
                Circle()
                    .foregroundStyle(Color(uiColor: .systemGray4))
                    .opacity(0.35)
            }
            .overlay(
                Text("Total")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .offset(y: -40)
            )
            .padding(5)
            .padding(34)
            .background {
                CircularProgressView(progress: CGFloat(tip))
            }
        }
        .frame(width: 300, height: 300)
        
    }
}

struct CircularProgressView: View {
    var progress: CGFloat
    var backgroundColor: Color = Color(uiColor: .systemGray4)
    private let lineWidth: Double = 20.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(backgroundColor)
                .opacity(0.6)
            Circle()
                .trim(from: 0, to: progress / 100 * (1.0 / 0.30))

                .stroke(style: StrokeStyle(lineWidth: lineWidth,
                                           lineCap: .round))
                .foregroundColor(.pink)
                .rotationEffect(.degrees(-90))
                .animation(.spring, value: progress)
        }
        .padding()
    }
}

struct InfoCardView<T: Numeric & LosslessStringConvertible>: View {
    let title: String
    @Binding var value: T
    let fontSize: CGFloat
    var placeholder: String
    @FocusState var focusField: FocusView?

    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 20))
                .fontWeight(.bold)
            HStack {
                
                ZStack {
                    Text(placeholder)
                        .font(.system(size: fontSize))
                        .fontWeight(.bold)
                        .hidden()
                    TextField(
                        placeholder,
                        text: Binding(
                            get: { formattedValue },
                            set: { newValue in updateValue(from: newValue) }
                        )
                    )
//                    .focused($focusField, equals: focusField)
                    .keyboardType(T.self == Double.self ? .decimalPad : .numberPad)
                    .font(.system(size: fontSize))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    private var formattedValue: String {
        if T.self == Double.self {
            return String(format: "$%.2f", value as! Double)
        } else if T.self == Int.self {
            return "\(value)%"
        } else {
            return "\(value)"
        }
    }
    
    private func updateValue(from newValue: String) {
        let sanitizedValue = newValue.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        
        if T.self == Double.self, let doubleValue = Double(sanitizedValue) {
            value = doubleValue as! T
        } else if T.self == Int.self, let intValue = Int(sanitizedValue) {
            value = intValue as! T
        }
    }
}

