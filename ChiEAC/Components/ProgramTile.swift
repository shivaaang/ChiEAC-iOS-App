//
//  ProgramTile.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct ProgramTile: View {
    let program: ProgramInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with icon
            HStack(alignment: .top, spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(program.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: program.icon)
                        .font(.title2)
                        .foregroundColor(program.color)
                }
                
                // Title section
                VStack(alignment: .leading, spacing: 6) {
                    Text(program.title)
                        .font(.chieacCardTitle)
                        .foregroundColor(.chieacTextPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(program.subtitle)
                        .font(.chieacCardSubtitle)
                        .foregroundColor(program.color)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.chieacBodySecondary)
                    .foregroundColor(.chieacTextSecondary)
            }
            
            // Description
            Text(program.description)
                .font(.chieacBody)
                .foregroundColor(.chieacTextSecondary)
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
            
            // Key stats (first 2 benefits)
            if program.benefits.count >= 2 {
                HStack(spacing: 20) {
                    ForEach(program.benefits.prefix(2), id: \.self) { benefit in
                        Text(benefit)
                            .font(.chieacCaption)
                            .foregroundColor(program.color)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.chieacCardGreen)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(program.color.opacity(0.3), lineWidth: 2)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

struct ProgramTile_Previews: PreviewProvider {
    static var previews: some View {
        ProgramTile(program: ProgramInfo(
            title: "ELEVATE",
            subtitle: "Professional Development",
            description: "Custom professional development opportunities tailored to the unique needs and aspirations of rising scholars.",
            benefits: ["85 custom internships created since 2020", "90%+ participants gain career-relevant skills"],
            impact: ["Rising scholars connected with opportunities"],
            icon: "star.fill",
            colorHex: "#12614d",
            contactEmail: "elevate@chieac.org"
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}