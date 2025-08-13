//
//  CoreWorkTile.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct CoreWorkTile: View {
    let work: CoreWork
    private let accentColor: Color = .chieacSecondary
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Icon (professional system icon)
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: work.icon)
                    .font(.title2)
                    .foregroundColor(accentColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(work.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.chieacTextPrimary)
                
                Text(work.description)
                    .font(.body)
                    .foregroundColor(.chieacTextSecondary)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(24)
        .background(Color.chieacCardGreen)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

struct CoreWorkTile_Previews: PreviewProvider {
    static var previews: some View {
        CoreWorkTile(work: CoreWork(
            id: "core_work.preview.advocacy",
            title: "Advocacy",
            description: "We advocate for policies that address root causes of educational inequity and create a more just and equitable school system.",
            icon: "scale.3d"
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}