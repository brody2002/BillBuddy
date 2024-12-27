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
    @State var totalCost: Double
    @State var splitTotal: Double
    
    var body: some View {
        VStack {
            
            Text("\(title.isEmpty ? "Split Bill" : title)")
                .font(.system(size: 30).bold())
                .fontWeight(.bold)
                .padding(.top, 16)
            
            HStack(spacing: 48) {
                PDFTotalPriceView(totalCost: totalCost)
                    .frame(width: UIScreen.main.bounds.width * 0.4)
                PDFSplitTotalView(splitTotal: splitTotal)
                    .frame(width: UIScreen.main.bounds.width * 0.4)
            }
            .padding(.top, 16)
            .onAppear{
                print("participants: \(participants)")
            }
            
            VStack(spacing: 16) {
                ForEach(participants.indices, id: \.self) { index in
                    ZStack {
                        PDFParticipantView(
                            participant: participants[index],
                            index: index
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
            Text("Total")
                .font(.system(size: 20))
                .fontWeight(.bold)
            Text(String(format: "$%.2f", totalCost))
                .font(.system(size: dynamicFont))
                .fontWeight(.bold)
        }
        
    }
}

private struct PDFSplitTotalView: View {
    @State var splitTotal : Double
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

private struct PDFParticipantView: View {
    
    let participant: Participant
    let index: Int
    
    var dynamicFontSize: CGFloat {
        String(format: "$%.2f", participant.participantTotal).count > 6 ? 14.0 : 18.0
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(participant.name.isEmpty ? "Person \(index)" : participant.name)
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.black)
                    
                    ForEach(Array(participant.purchasedDict.keys), id: \.self) { item in
                        if let value = participant.purchasedDict[item] {
                            HStack(alignment: .top) { // Use HStack for each item
                                Text(item) // Item name
                                   
                                    .frame(width: 150, alignment: .leading) // Ensure .leading alignment
                                    .multilineTextAlignment(.leading)
                                
                                Text(String(format: "$%.2f", value).isEmpty ? "0.00" : String(format: "$%.2f", value)) // Item price
                                   
                                    .frame(maxWidth: .infinity, alignment: .leading) // Align to .leading
                                    
                            }
                            .padding(.vertical, 2) // Add vertical padding
                        }
                    }
                    .padding(.bottom, 5)

                }
                
                Spacer()
                
                VStack {
                    Text(String(format: "$%.2f", participant.participantTotal))
                        .font(.system(size: dynamicFontSize))
                        .fontWeight(.bold)
                        .frame(width: 70)
                        .offset(x: 5)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.pink)
                }
            }
            .padding()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 2))
                .fill(Color.gray.opacity(0.5))
        )
//        .background(
//            ZStack{
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(.gray.opacity(0.2))
//                
//            }
//            
//        )
    }
}

#Preview {
    let participants : [Participant] = [
        Participant(name: "Brody", purchasedDict: ["Roast Chicken": 4.99], participantTotal: 4.99),
        Participant(name: "Kai", purchasedDict: ["Hotdog": 1.99, "Mocha Freeze": 3.5], participantTotal: 5.49)
    ]
    
    PDFView(title: "Costco Bill", participants: participants, totalCost: 10.48, splitTotal: 10.48)
}
