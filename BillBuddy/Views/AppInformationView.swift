//
//  AppInformationView.swift
//  BillBuddy
//
//  Created by Brody on 12/20/24.
//

import SwiftUI

struct AppInformationView: View {
    private let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    
    var body: some View {
        HStack(spacing: 16) {
            Image("AppIcon")
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(width: 64, height: 64)
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                Text("BillBuddy")
                    .font(.subheadline.weight(.semibold))
                Text("v\(version)")
                    .fontWeight(.medium)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                Text("Pay the easy way")
                    .font(.caption2)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                Spacer()
            }
            .font(.caption)
            .foregroundColor(.primary)
        }
        .fixedSize()
    }
}

#Preview {
    AppInformationView()
}
