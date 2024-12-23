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
    @State private var participants: [Participant] = [
        Participant(name: "", purchasedDict: [:], participantTotal: 0.0),
        Participant(name: "", purchasedDict: [:], participantTotal: 0.0)
    ]
    @State private var splitTotal: Double = 0.0

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack(spacing: 48) {
                    totalPriceView(totalCostManager: totalCostManager)
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                    SplitTotalView(splitTotal: $splitTotal)
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                }
                .padding(.top, 32)
                
                VStack(spacing: 16) {
                    ForEach(participants.indices, id: \.self) { index in
                        ZStack {
                            ParticipantView(
                                participant: $participants[index],
                                splitTotal: $splitTotal,
                                participantNumber: index + 1
                            )
                                .focused($focusField, equals: .participant)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 64)
                
                Button(
                    action: {
                        // PDF creation logic
                    },
                    label: {
                        Text("Create PDF")
                            .fontWeight(.bold)
                            .font(.system(size: 30))
                            .foregroundStyle(.white)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.pink)
                            )
                    }
                )
                .padding(.bottom, 336)
//#if DEBUG
Button(
    action:{print(participants)},
    label: {
        Text("Print Dict")
            .fontWeight(.bold)
            .font(.system(size: 30))
            .foregroundStyle(.white)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.pink)
            )
    }
)
//#endif
                
                
                AppInformationView()
            }
            .navigationTitle("Bill Splitter")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if participants.count > 2 {
                            withAnimation(.spring(response: 0.2)) { participants.removeLast() }
                        }
                    }) {
                        Image(systemName: "minus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.spring(response: 0.2)) {
                            participants.append(
                                Participant(
                                    name: "",
                                    purchasedDict: [:],
                                    participantTotal: 0.0
                                )
                            )
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onTapGesture {
                focusField = nil
            }
        }
        .fontDesign(.rounded)
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
    
    @Binding var participant: Participant
    @Binding var splitTotal: Double
    @State var participantNumber: Int
    
    @State private var items: [Item] = [Item(name: "", price: "")]
    var dynamicFontSize: CGFloat {
        String(format: "$%.2f", participant.participantTotal).count > 6 ? 14.0 : 18.0
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    TextField(
                        "Person \(participantNumber)",
                        text: $participant.name
                    )
                    .fontWeight(.bold)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.pink)
                    
                    ForEach(items.indices, id: \.self) { index in
                        HStack {
                            TextField(
                                "Item Name",
                                text: Binding(
                                    get: { items[index].name },
                                    set: { items[index].name = $0 }
                                )
                            )
                            .fontWeight(.bold)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
                            
                            Text("$")
                                .offset(x: 4)
                                .fontWeight(.bold)
                            
                            TextField(
                                "Price",
                                text: Binding(
                                    get: { items[index].price },
                                    set: { newValue in
                                        items[index].price = newValue
                                        updateParticipantTotal()
                                    }
                                )
                            )
                            .fontWeight(.bold)
                            .onChange(of: items[index].price) {
                                let doublePrice = Double($1)
                                if doublePrice ?? 0.0 > 9999.99 {
                                    items[index].price = String($1.prefix(4))
                                }
                            }
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                        }
                    }
                    .padding(.bottom, 5)
                    
                    HStack(spacing: 32) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                items.append(Item(name: "", price: ""))
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                            }
                            .foregroundColor(.pink)
                        }
                        
                        Button(action: {
                            guard items.count >= 2 else { return }
                            withAnimation(.spring(response: 0.3)) { items.removeLast() }
                            updateParticipantTotal()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                            }
                            .foregroundColor(.pink)
                        }
                    }
                    .offset(y: 5)
                }
                
                Spacer()
                
                VStack {
                    Text(String(format: "$%.2f", participant.participantTotal))
                        .font(.system(size: dynamicFontSize))
                        .fontWeight(.bold)
                        .frame(width: 70)
                        .offset(x: 5)
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
            
            updateParticipantTotal()
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 6))
                .fill(Color.black)
        )
    }
    
    private func updateParticipantTotal() {
        participant.participantTotal = items.reduce(0.0) { total, item in
            total + (Double(item.price) ?? 0.0)
        }
        participant.purchasedDict = items.reduce(into: [String: Double]()) { dict, item in
            dict[item.name] = Double(item.price) ?? 0.0
        }
        
        
    }
    
    
    
    struct Item: Equatable {
        var name: String
        var price: String
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let view = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return view
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}



extension View {
    /// Converts the current SwiftUI view into a PDF and saves it to the given URL.
    func exportAsPDF(fileName: String, completion: @escaping (URL?) -> Void) {
        let renderer = ImageRenderer(content: self)
        
        // Determine the path for saving the PDF
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pdfURL = documentsURL.appendingPathComponent("\(fileName).pdf")
        
        // Render the view to a PDF
        renderer.render { size, context in
            var mediaBox = CGRect(origin: .zero, size: size)
            guard let dataConsumer = CGDataConsumer(url: pdfURL as CFURL),
                  let pdfContext = CGContext(consumer: dataConsumer, mediaBox: &mediaBox, nil) else {
                completion(nil)
                return
            }
            
            pdfContext.beginPDFPage(nil)
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
        
        completion(pdfURL)
    }
}

struct Participant {
    var name: String
    var purchasedDict: [String : Double]
    var participantTotal: Double
    
    init(name: String, purchasedDict: [String : Double], participantTotal: Double) {
        self.name = name
        self.purchasedDict = [:]
        self.participantTotal = 0.0
    }
}
