//
//  SplitBillView.swift
//  BillBuddy
//
//  Created by Brody on 12/20/24.
//
import Foundation
import SwiftUI

struct SplitBillView: View {
    @FocusState var focusField: FocusView?
    @ObservedObject var totalCostManager: TotalCostManager
    @State private var participants: [Participant] = [
        Participant(name: "", purchasedDict: [:], participantTotal: 0.0),
        Participant(name: "", purchasedDict: [:], participantTotal: 0.0)
    ]
    @State private var splitTotal: Double = 0.0
    @State private var pdfURL: URL?
    @State private var showShareSheet: Bool = false
    @State private var participantCount: Int = 2
    @State private var pdfName: String = ""
    
    @State private var sharedItems: [SharedItem] = []
    
    var body: some View {
        NavigationStack {
            
            ScrollView {
                HStack(spacing: 48) {
                    totalPriceView(totalCostManager: totalCostManager)
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                    SplitTotalView(splitTotal: $splitTotal, totalCostManager: totalCostManager)
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                }
                .padding(.top, 32)
                
                ShareItemsView(sharedItems: $sharedItems)
                    .focused($focusField, equals: .shareItems)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    ForEach(participants.indices, id: \.self) { index in
                        ZStack {
                            ParticipantView(
                                participant: $participants[index],
                                splitTotal: $splitTotal,
                                participantNumber: index + 1,
                                participantCount: $participantCount,
                                totalCostManager: totalCostManager,
                                sharedItems: $sharedItems
                            )
                            .focused($focusField, equals: .participant)
                        }
                    }
                }
                .padding()
                
                    .padding(.bottom, 64)
                
                TextField("PDF Name: ", text: $pdfName)
                    .focused($focusField, equals: FocusView.pdfName)
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 2))
                            .foregroundStyle(.black)
                        
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                Button(
                    action: {
                        render(
                            title: pdfName,
                            view: PDFView(
                                title: pdfName,
                                participants: participants,
                                totalCostManager: totalCostManager,
                                splitTotal: splitTotal
                            )
                        ) { url in
                            guard let url = url else { return }
                            pdfURL = url
                            print("PDF generated at: \(pdfURL!)")
                            // Ensure the state update is synchronized
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showShareSheet = true
                            }
                        }
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
                .sheet(isPresented: Binding(
                    get: { showShareSheet && pdfURL != nil },
                    set: { showShareSheet = $0 }
                )) {
                    if let pdfURL = pdfURL {
                        ShareSheet(activityItems: [pdfURL])
                    } else {
                        Text("No PDF available")
                            .onAppear {
                                print("pdfURL: \(pdfURL ?? URL(fileURLWithPath: ""))")
                            }
                    }
                }
                
                
#if targetEnvironment(simulator)
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
#endif
                
                
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
            .onChange(of: participants){ _, newVal in
                withAnimation(.spring(response: 0.3)) { participantCount = newVal.count }
            }
        }
        .fontDesign(.rounded)
        
        
    }
    
    // Function from Paul Hudson's Hacking with swift
    
    func render(title: String, view: some View, completion: @escaping (URL?) -> Void){
        // 1: Render Hello World with some modifiers
        let renderer = ImageRenderer(content: view)
        
        // 2: Save it to our documents directory
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = documentsURL.appendingPathComponent("\(title).pdf")
        
        
        // 3: Start the rendering process
        renderer.render { size, context in
            // 4: Tell SwiftUI our PDF should be the same size as the views we're rendering
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            // 5: Create the CGContext for our PDF pages
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            
            // 6: Start a new PDF page
            pdf.beginPDFPage(nil)
            
            // 7: Render the SwiftUI view data onto the page
            context(pdf)
            
            // 8: End the page and close the file
            pdf.endPDFPage()
            pdf.closePDF()
            
            
        }
        
        print("returning URL")
        print("url: \(url)")
        completion(url)
    }
    
    
    
    
}


private struct totalPriceView: View {
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

private struct SplitTotalView: View {
    @Binding var splitTotal : Double
    @ObservedObject var totalCostManager: TotalCostManager
    var dynamicFont: CGFloat {
        if String(format: "$%.2f", splitTotal).count > 7 { return 20.0 }
        else { return 30.0}
    }
    
    var body : some View{
        VStack(spacing: 0){
            Text("Input Total")
                .font(.system(size: 20))
                .fontWeight(.bold)
            Text(String(format: "$%.2f", splitTotal + totalCostManager.tax + totalCostManager.tip))
                .font(.system(size: dynamicFont))
                .fontWeight(.bold)
        }
    }
}

private struct ParticipantView: View {
    @State var individualTotalPrice: Double = 0.0
    @State var previousTotalPrice: Double = 0.0
    
    @Binding var participant: Participant
    @Binding var splitTotal: Double
    @State var participantNumber: Int
    
    @State private var items: [Item] = [Item(name: "", price: "")]
    var dynamicFontSize: CGFloat {
        String(format: "$%.2f", individualTotalPrice + (totalCostManager.tax / Double(participantCount)) + (totalCostManager.tip / Double(participantCount))).count > 6 ? 12.0 : 18.0
    }
    @Binding var participantCount: Int
    @ObservedObject var totalCostManager: TotalCostManager
    @Binding var sharedItems: [SharedItem]
    
    func calculateIndividualPrice() -> Double {
        var starting = 0.0
        for item in sharedItems {
            if let priceD = Double(item.price) {
                starting += priceD
            }
        }
        return starting
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
                    
                    // SharedItems Content
                    if !sharedItems.isEmpty{
                        VStack(alignment: .leading){
                            
                            ForEach(sharedItems, id: \.self){ sharedItem in
                                HStack{
                                    if !sharedItem.name.isEmpty{
                                        Text("\(sharedItem.name)")
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.leading)
                                            .offset(x: 5)
                                            .frame(width: 150, alignment: .leading)
                                    } else {
                                        Text("Unnamed Item")
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.leading)
                                            .offset(x: 5)
                                            .frame(width: 150, alignment: .leading)
                                    }
                                   
                                    
                                    Text("$")
                                        .offset(x: 5)
                                        .fontWeight(.bold)
                                    
                                    if let priceValue = Double(sharedItem.price) {
                                        Text(String(format: "%.2f", priceValue / Double(participantCount)))
                                            .fontWeight(.bold)
                                            .offset(x: 7)
                                    } else {
                                        Text("0.00")
                                            .fontWeight(.bold)
                                            .offset(x: 7)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.bottom, 5)
                                
                            }
                            
                        }
                        .padding(.bottom, 5)
                    }
                    
                    VStack(alignment: .leading){
                        HStack{
                            Text("Split Tax")
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .offset(x: 5)
                                .frame(width: 150, alignment: .leading)
                            
                            Text("$")
                                .offset(x: 5)
                                .fontWeight(.bold)
                            
                            Text(String(format: "%.2f", totalCostManager.tax / Double(participantCount)))
                                .fontWeight(.bold)
                                .offset(x: 7)
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        
                        HStack{
                            Text("Split Tip")
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .offset(x: 5)
                                .frame(width: 150, alignment: .leading)
                            
                            Text("$")
                                .offset(x: 5)
                                .fontWeight(.bold)
                            
                            Text(String(format: "%.2f", totalCostManager.tip / Double(participantCount)))
                                .fontWeight(.bold)
                                .offset(x: 7)
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        
                        
                        
                    }
                    
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
                
                // Individual Total
                VStack {
                    Text(String(format: "$%.2f", individualTotalPrice + (totalCostManager.tax / Double(participantCount)) + (totalCostManager.tip / Double(participantCount)) ))
                        .font(.system(size: dynamicFontSize))
                        .foregroundStyle(.pink)
                        .fontWeight(.bold)
                        .frame(width: 70)
                        .offset(x: 5)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                }
                .onChange(of: sharedItems) { _, _ in
                    individualTotalPrice = items.reduce(0.0) { total, item in
                        total + (Double(item.price) ?? 0.0)
                    }

                    // Add shared items to individual total
                    let sharedTotal = sharedItems.reduce(0.0) { total, sharedItem in
                        total + ((Double(sharedItem.price) ?? 0.0) / Double(participantCount))
                    }

                    individualTotalPrice += sharedTotal
                    splitTotal += (individualTotalPrice - previousTotalPrice)
                    previousTotalPrice = individualTotalPrice

                    updateParticipantTotal()
                }

            }
            .padding()
        }
        .onChange(of: items) { _, newValue in
            // help the previous help comment work with this as well
            print("Changing item")
            individualTotalPrice = newValue.reduce(0.0) { total, item in
                total + (Double(item.price) ?? 0.0)
            }
            splitTotal += individualTotalPrice - previousTotalPrice
            previousTotalPrice = individualTotalPrice
            
            updateParticipantTotal()
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 2))
                .fill(Color.black)
        )
    }
    
    private func updateParticipantTotal() {
        // Calculate personal items
        participant.participantTotal = items.reduce(0.0) { total, item in
            total + (Double(item.price) ?? 0.0)
        }
        
        let sharedTotal = sharedItems.reduce(0.0) { total, sharedItem in
            total + ((Double(sharedItem.price) ?? 0.0) / Double(participantCount))
        }

        participant.participantTotal += sharedTotal

        
        
        // Update purchased dictionary
        participant.purchasedDict = items.reduce(into: [String: Double]()) { dict, item in
            dict[item.name] = Double(item.price) ?? 0.0
        }

        // Optionally add shared items to purchasedDict
        for sharedItem in sharedItems {
            let pricePerParticipant = (Double(sharedItem.price) ?? 0.0) / Double(participantCount)
            participant.purchasedDict["(Shared) \(sharedItem.name)"] = pricePerParticipant
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

struct ShareItemsView: View {
    @Binding var sharedItems: [SharedItem]
    
    var body: some View {
        HStack(alignment: .top){
            VStack(alignment: .leading){
                
                Text("Shared Items")
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                
                // List of Shared Items
                
                
                ForEach(sharedItems.indices, id: \.self) { index in
                    HStack {
                        // Editable Item Name
                        TextField(
                            "Item Name",
                            text: Binding(
                                get: { sharedItems[index].name},
                                set: { sharedItems[index].name = $0 }
                            )
                        )
                        .fontWeight(.bold)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 150)
                        
                        Text("$")
                            .fontWeight(.bold)
                        
                        TextField(
                            "Price",
                            text: Binding(
                                get: { sharedItems[index].price }, // Directly bind the price string
                                set: { sharedItems[index].price = $0}
                                
//                                set: { newValue in
//                                    items[index].price = newValue
//                                    updateParticipantTotal()
//                                }
                            )
                        )
                        .fontWeight(.bold)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    }
                    .padding(.bottom, 5)
                }
                
                // Add and Remove Buttons
                HStack(spacing: 32) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            sharedItems.append(SharedItem())
                        }
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.pink)
                    }
                    
                    Button(action: {
                        withAnimation {
                            if !sharedItems.isEmpty {
                                sharedItems.removeLast()
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.pink)
                    }
                }
                .padding(.top, sharedItems.count > 0 ? 0 : 5)
                
            }
            Spacer()
            
            VStack {
                Text("Total")
                    .font(.system(size: 24))
                    .foregroundStyle(.clear)
                    .fontWeight(.bold)
                    .frame(width: 70)
                    .offset(x: 5)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 2))
                .foregroundColor(.black)
        )
    }
}






#Preview {
    @Previewable @State var totalCostManager = TotalCostManager(totalCost: 9.00, tax: 1.00, tip: 1.00)
    SplitBillView(totalCostManager: totalCostManager)
}
