//
//  PDFView.swift
//  BillBuddy
//
//  Created by Brody on 12/22/24.
//

import SwiftUI


struct PDFView: View {
    var totalCost: Double
    var splitTotal: Double
    var participants: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bill Splitter Summary")
                .font(.title)
                .bold()

            Text("Total Cost: \(String(format: "$%.2f", totalCost))")
                .font(.headline)

            Text("Split Total: \(String(format: "$%.2f", splitTotal))")
                .font(.headline)

            Text("Participants: \(participants)")
                .font(.headline)

            ForEach(1...participants, id: \.self) { participant in
                Text("Participant \(participant): \(String(format: "$%.2f", splitTotal / Double(participants)))")
                    .font(.body)
            }
        }
        .padding()
    }
}

#Preview {
    PDFView(totalCost: 100.00, splitTotal: 100.00, participants: 3)
}
