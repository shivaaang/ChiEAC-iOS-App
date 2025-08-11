//
//  ProgramDetailView.swift
//  ChiEAC
//
//  Extracted from ProgramView for better separation of concerns.
//

import SwiftUI

struct ProgramDetailView: View {
    let program: ProgramInfo
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(program.color.opacity(0.15))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: program.icon)
                            .font(.system(size: 40))
                            .foregroundColor(program.color)
                    }
                    
                    Text(program.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.chieacTextPrimary)
                    
                    Text(program.subtitle)
                        .font(.title2)
                        .foregroundColor(program.color)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Description
                Text(program.description)
                    .font(.body)
                    .foregroundColor(.chieacTextSecondary)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                // Benefits
                VStack(alignment: .leading, spacing: 16) {
                    Text("Program Benefits")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.chieacTextPrimary)
                        .padding(.horizontal, 20)
                    
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(program.benefits, id: \.self) { benefit in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.chieacSuccess)
                                    .font(.system(size: 16))
                                
                                Text(benefit)
                                    .font(.body)
                                    .foregroundColor(.chieacTextSecondary)
                                    .lineSpacing(2)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                // Impact
                if !program.impact.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Program Impact")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.chieacTextPrimary)
                            .padding(.horizontal, 20)
                        
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(program.impact, id: \.self) { impact in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(program.color)
                                        .font(.system(size: 16))
                                    
                                    Text(impact)
                                        .font(.body)
                                        .foregroundColor(.chieacTextSecondary)
                                        .lineSpacing(2)
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                
                // Contact CTA
                VStack(spacing: 16) {
                    Text("Get Involved")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        if let url = URL(string: "mailto:\(program.contactEmail)") {
                            openURL(url)
                        }
                    }) {
                        Text("Contact Us About \(program.title)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [program.color, program.color.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .padding(.horizontal, 20)
                
                Spacer(minLength: 20)
            }
        }
        .background(Color.chieacLightBackground)
        .navigationTitle(program.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
