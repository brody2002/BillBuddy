//
//  PDFView.swift
//  BillBuddy
//
//  Created by Brody on 12/22/24.
//

import SwiftUI


struct PDFView: View {
    @State var title: String
    @State var participants: [Participant]
    @State var totalCostManager: TotalCostManager
    @State var splitTotal: Double
    
    var body: some View {
        VStack {
            
            Text("\(title.isEmpty ? "Split Bill" : title)")
                .font(.system(size: 24).bold())
                .fontWeight(.bold)
                .padding(.top, 16)
            
            
            PDFTotalPriceView(totalCost: totalCostManager.totalCost)
            .frame(width: UIScreen.main.bounds.width * 0.4)
            .padding(.top, 16)
            .onAppear{
                print("participants: \(participants)")
            }
            
            VStack(spacing: 16) {
                ForEach(participants.indices, id: \.self) { index in
                    ZStack {
                        PDFParticipantView(
                            participant: participants[index],
                            index: index,
                            participantCount: participants.count,
                            totalCostManager: totalCostManager
                        )
                    }
                }
            }
            .padding()
            .padding(.bottom, 64)
            
            AppInformationView()
            
        }.fontDesign(.rounded)
    }
        

}


private struct PDFTotalPriceView: View {
    @State var totalCost: Double
    var dynamicFont: CGFloat {
        if String(format: "$%.2f", totalCost).count > 7 { return 20.0 }
        else { return 30.0}
    }
    var body: some View{
        VStack(spacing: 0){
            Text("Bill Total")
                .font(.system(size: 20))
                .fontWeight(.bold)
            Text(String(format: "$%.2f", totalCost))
                .font(.system(size: dynamicFont))
                .fontWeight(.bold)
        }
        
    }
}



private struct PDFParticipantView: View {
    
    let participant: Participant
    let index: Int
    
    var dynamicFontSize: CGFloat {
        String(format: "$%.2f", participant.participantTotal).count > 6 ? 14.0 : 18.0
    }
    @State var participantCount: Int
    @State var totalCostManager: TotalCostManager
    
    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(participant.name.isEmpty ? "Person \(index)" : participant.name)
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.black)
                        .padding(.bottom, 10)
                    
                    ForEach(Array(participant.purchasedDict.keys), id: \.self) { item in
                        if let value = participant.purchasedDict[item] {
                            HStack(alignment: .top) { // Use HStack for each item
                                if !item.isEmpty {
                                    Text(item) // Item name
                                        .frame(width: 150, alignment: .leading) // Ensure .leading alignment
                                        .multilineTextAlignment(.leading)
                                } else { Text("Unnamed Item")
                                        .frame(width: 150, alignment: .leading)
                                        .multilineTextAlignment(.leading)}
                                
                                
                                Text(String(format: "$%.2f", value).isEmpty ? "0.00" : String(format: "$%.2f", value)) // Item price
                                   
                                    .frame(maxWidth: .infinity, alignment: .leading) // Align to .leading
                                    
                            }
                        }
                    }
                    .padding(.bottom, 5)
                    
                    HStack{
                        Text("Split Tax")
                            .multilineTextAlignment(.leading)
                            .frame(width: 150, alignment: .leading)
                        
                        Text(String(format: "$%.2f", totalCostManager.tax / Double(participantCount) ))
                        
                        Spacer()
                    }
                    .padding(.bottom, 5)
                    
                    
                    HStack{
                        Text("Split Tip")
                            .multilineTextAlignment(.leading)
                            .frame(width: 150, alignment: .leading)
                        
                        Text(String(format: "$%.2f", totalCostManager.tip / Double(participantCount) ))
                        
                        Spacer()
                    }

                }
                
                Spacer()
                
                VStack {
                    Text(String(format: "$%.2f", participant.participantTotal + (totalCostManager.tax / Double(participantCount)) + (totalCostManager.tip / Double(participantCount)) ))
                        .font(.system(size: dynamicFontSize))
                        .fontWeight(.bold)
                        .frame(width: 70)
                        .offset(x: 5)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.pink)
                        .onAppear{
                            print("participant.participantTotal: \(participant.participantTotal)")
                            print("(totalCostManager.tax / Double(participantCount)): \((totalCostManager.tax / Double(participantCount)) )")
                            print("(totalCostManager.tip / Double(participantCount)): \((totalCostManager.tip / Double(participantCount)))")
                            
                        }
                }
            }
            .padding()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 2))
                .fill(Color.gray.opacity(0.5))
        )
    }
}

#Preview {
    @Previewable @StateObject var totalCostManager = TotalCostManager(totalCost: 20.48, tax: 10.0, tip: 11.00)
    let participants : [Participant] = [
        Participant(name: "Brody", purchasedDict: ["Roast Chicken": 4.99], participantTotal: 4.99),
        Participant(name: "Kai", purchasedDict: ["Hotdog": 1.99, "Mocha Freeze": 3.5], participantTotal: 5.49)
    ]
    
    PDFView(title: "Costco Bill", participants: participants, totalCostManager: totalCostManager, splitTotal: 10.48)
}
