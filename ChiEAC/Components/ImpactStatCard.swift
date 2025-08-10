//
//  ImpactStatCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct ImpactStatCard: View {
    let stat: ImpactStat
    
    var body: some View {
        VStack(spacing: 8) {
            Text(stat.number)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.chieacSecondary)
            
            Text(stat.label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.chieacTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct ImpactStatCard_Previews: PreviewProvider {
    static var previews: some View {
        ImpactStatCard(stat: ImpactStat(number: "1,600+", label: "Students Served"))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}