//
//  CoreWorkCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct CoreWorkCard: View {
    let work: CoreWork
    private let accentColor: Color = .chieacSecondary
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: work.icon)
                    .font(.title3)
                    .foregroundColor(accentColor)
            }
            .accessibilityHidden(true)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(work.title)
                    .font(.chieacCardTitle)
                    .foregroundColor(.chieacTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Description
                Text(work.description)
                    .font(.chieacCardBody)
                    .foregroundColor(.chieacTextSecondary)
                    .lineSpacing(2)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

struct CoreWorkCard_Previews: PreviewProvider {
    static var previews: some View {
    CoreWorkCard(work: CoreWork(
            id: "core_work.preview.advocacy",
            title: "Advocacy",
            description: "We advocate for policies that address root causes of educational inequity and create a more just and equitable school system.",
            icon: "scale.3d",
            order: 1
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
