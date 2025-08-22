//  ProgramDetailView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct ProgramDetailView: View {
    let program: ProgramInfo
    @State private var showingContactForm = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Hero Header Section
                HeroHeader(
                    title: program.title,
                    subtitle: program.subtitle,
                    systemImage: program.icon,
                    gradientColors: [.chieacMintGreen, .white],
                    showDecorativeWaves: true,
                )
                
                // Main Content
                VStack(spacing: 20) {
                    // Program Overview Card
                    ProgramOverviewCard(description: program.description)
                    
                    // Benefits Section
                    ProgramBenefitsCard(benefits: program.benefits)
                    
                    // Impact Section (if available)
                    if !program.impact.isEmpty {
                        ProgramImpactCard(impact: program.impact)
                    }
                    
                    // Call to Action Card
                    ProgramCTACard(
                        programTitle: program.title,
                        showingContactForm: $showingContactForm,
                        program: program
                    )
                    
                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .background(Color.chieacLightBackground)
            }
        }
        .background(Color.chieacLightBackground)
        .ignoresSafeArea(edges: .top)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingContactForm) {
            ContactFormView(
                source: program.contactFormSource,
                sourceString: program.programSourceString,
                customTitle: "Contact Us About \(program.title)"
            )
        }
    }
}

// MARK: - Program Overview Card
struct ProgramOverviewCard: View {
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(.chieacPrimary)
                
                Text("Program Overview")
                    .font(.chieacCardTitle)
                    .foregroundColor(.chieacTextPrimary)
                
                Spacer()
            }
            
            Text(description)
                .font(.chieacBody)
                .foregroundColor(.chieacTextSecondary)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Program Impact Card
struct ProgramImpactCard: View {
    let impact: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3)
                    .foregroundColor(.chieacPrimary)
                
                Text("Program Impact")
                    .font(.chieacCardTitle)
                    .foregroundColor(.chieacTextPrimary)
                
                Spacer()
            }
            
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(Array(impact.enumerated()), id: \.offset) { index, impactItem in
                    HStack(alignment: .center, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.chieacPrimary.opacity(0.15))
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.chieacPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(impactItem)
                                .font(.chieacBody)
                                .foregroundColor(.chieacTextSecondary)
                                .lineSpacing(2)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}
// MARK: - Program Benefits Card
struct ProgramBenefitsCard: View {
    let benefits: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundColor(.chieacSuccess)
                
                Text("Program Benefits")
                    .font(.chieacCardTitle)
                    .foregroundColor(.chieacTextPrimary)
                
                Spacer()
            }
            
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                    HStack(alignment: .center, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.chieacSuccess.opacity(0.15))
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.chieacSuccess)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(benefit)
                                .font(.chieacBody)
                                .foregroundColor(.chieacTextSecondary)
                                .lineSpacing(2)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Program CTA Card
struct ProgramCTACard: View {
    let programTitle: String
    @Binding var showingContactForm: Bool
    let program: ProgramInfo
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("Ready to Get Involved?")
                    .font(.chieacHero)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Connect with us to learn more about \(programTitle) and how you can participate.")
                    .font(.chieacBody)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            
            Button(action: {
                showingContactForm = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.headline)
                    
                    Text("Contact Us About \(programTitle)")
                        .font(.chieacCardTitle)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.chieacPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.chieacPrimary,
                            Color.chieacSecondary
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color.chieacPrimary.opacity(0.3), radius: 12, x: 0, y: 6)
    }
}
