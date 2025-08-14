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
        VStack(spacing: 0) {
            if !stat.icon.isEmpty {
                Image(systemName: stat.icon)
                    .font(.title2)
                    .foregroundColor(.chieacSecondary)
            }
            Text(stat.number)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.chieacTextPrimary)
            Text(stat.label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.chieacTextSecondary)
                .multilineTextAlignment(.center)
            Text(stat.subtitle)
                .font(.caption2)
                .foregroundColor(.chieacTextSecondary)
                .opacity(0.8)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct ImpactStatCard_Previews: PreviewProvider {
    static var previews: some View {
    ImpactStatCard(stat: ImpactStat(id: "impact.preview.students_served", number: "1,600+", label: "Students Served", subtitle: "since 2020", icon: "graduationcap.fill"))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
