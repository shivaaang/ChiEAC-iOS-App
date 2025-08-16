//
//  SupportMissionView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct SupportMissionView: View {
    @StateObject private var viewModel = SupportMissionViewModel()
    @State private var showDonationView = false
    @State private var callToActionTop: CGFloat = .greatestFiniteMagnitude
    @State private var containerBottom: CGFloat = 0
    
    var body: some View {
        GeometryReader { outer in
            ZStack(alignment: .bottom) {
                if viewModel.isLoading && !viewModel.hasData {
                    // Loading state
                    VStack(spacing: 20) {
                        SupportMissionHeaderSection(title: nil)
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading content...")
                                .font(.chieacBody)
                                .foregroundColor(.chieacTextSecondary)
                        }
                        .frame(height: 200)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            // Header Section
                            SupportMissionHeaderSection(title: viewModel.supportMissionContent?.headerTitle)
                            
                            // Mission Statement
                            if let content = viewModel.supportMissionContent { 
                                MissionStatementSection(copy: content.mission) 
                            }
                            
                            // Impact Numbers
                            if let content = viewModel.supportMissionContent { 
                                ImpactNumbersSection(stats: content.impactNumbers) 
                            }
                            
                            // What Your Gift Provides
                            if let content = viewModel.supportMissionContent { 
                                DonationImpactSection(heading: content.donationLevelsHeading, levels: content.donationLevels) 
                            }
                            
                            // Long-term Solutions
                            if let content = viewModel.supportMissionContent { 
                                LongTermSolutionsSection(section: content.longTermSolutions) 
                            }
                            
                            // Why ChiEAC
                            if let content = viewModel.supportMissionContent { 
                                WhyChiEACSection(section: content.whyChiEAC) 
                            }
                            
                            // Call to Action (tracked for visibility)
                            if let content = viewModel.supportMissionContent {
                                CallToActionSection(showDonationView: $showDonationView, isEnabled: viewModel.donationURL != nil, cta: content.cta)
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear
                                                .preference(key: CallToActionTopKey.self, value: geo.frame(in: .global).minY)
                                        }
                                    )
                            }
                            
                            Spacer(minLength: 20)
                        }
                        .padding(.horizontal, 20)
                        .onAppear {
                            containerBottom = outer.frame(in: .global).maxY
                        }
                    }
                }
                
                // Floating Donate Button
                if shouldShowFloatingButton(globalVisibleBottom: outer.frame(in: .global).maxY) {
                    FloatingDonateButton(isEnabled: viewModel.donationURL != nil) {
                        if viewModel.donationURL != nil { showDonationView = true }
                    }
                    .padding(.bottom, 12)
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .onPreferenceChange(CallToActionTopKey.self) { value in
                callToActionTop = value
            }
        }
        .background(Color.chieacLightBackground)
        .navigationTitle("Support Our Mission")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDonationView) {
            if let url = viewModel.donationURL {
                ExternalLinkWebView(urlString: url, title: "Donate to ChiEAC")
            } else {
                Text("Missing donation link.")
                    .padding()
            }
        }
        .alert("Error Loading Content", isPresented: .constant(viewModel.hasError)) {
            Button("Retry") {
                viewModel.retry()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .refreshable {
            viewModel.retry()
        }
        .task {
            // Ensure data is loaded if needed (fallback)
            await viewModel.loadDataIfNeeded()
        }
    }
    
    private func shouldShowFloatingButton(globalVisibleBottom: CGFloat) -> Bool {
        // Show while top of CallToActionSection is still below (not yet intersecting) visible bottom minus small threshold
        let threshold: CGFloat = 20
        return callToActionTop > (globalVisibleBottom - threshold)
    }
}

// PreferenceKey to track the global minY of the CallToActionSection
private struct CallToActionTopKey: PreferenceKey {
    static var defaultValue: CGFloat = .greatestFiniteMagnitude
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = min(value, nextValue())
    }
}

// Floating Donate Button component
private struct FloatingDonateButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: { if isEnabled { action() } }) {
            HStack(spacing: 10) {
                Image(systemName: "heart.fill")
                    .font(.headline)
                Text("Donate Now")
                    .font(.chieacButtonText)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(LinearGradient(gradient: Gradient(colors: [.chieacSecondary, .chieacPrimary]), startPoint: .leading, endPoint: .trailing))
            )
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.7)
        .accessibilityLabel("Donate Now")
    }
}

// MARK: - Header Section
struct SupportMissionHeaderSection: View {
    let title: String?
    var body: some View {
        VStack(spacing: 10) {
            // Logo
            Image("chieac-logo-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .padding(20)
                .background(Circle().fill(Color.white))
                .shadow(color: .chieacPrimary.opacity(0.2), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 12) {
                Text(title ?? "")
                    .font(.chieacSectionHeader)
                    .foregroundColor(.chieacPrimary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - Mission Statement Section
struct MissionStatementSection: View {
    let copy: MissionCopy
    var body: some View {
        VStack(spacing: 10) {
            Text(copy.intro)
                .font(.chieacHero)
                .foregroundColor(.chieacTextPrimary)
                .multilineTextAlignment(.center)
            
            Text(copy.support)
                .font(.chieacBody)
                .foregroundColor(.chieacTextSecondary)
                .multilineTextAlignment(.center)
            
            Text(copy.change)
                .font(.chieacBodySecondary)
                .foregroundColor(.chieacSecondary)
                .multilineTextAlignment(.center)
                .italic()
    }
    .padding(20)
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Impact Numbers Section (reusing ImpactStatCard)
struct ImpactNumbersSection: View {
    let stats: [ImpactNumberContent]
    
    private var mapped: [ImpactStat] {
        stats.enumerated().map { index, stat in 
            ImpactStat(id: "supportImpact." + stat.id, number: stat.number, label: stat.label, subtitle: stat.subtitle, icon: stat.icon, order: index)
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(mapped) { stat in
                    ImpactStatCard(stat: stat)
                }
            }
        }
    }
}

// MARK: - Donation Impact Section
struct DonationImpactSection: View {
    let heading: String
    let levels: [DonationLevelContent]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(heading)
                    .font(.chieacHero)
                    .foregroundColor(.chieacTextPrimary)
                Spacer()
            }
            VStack(spacing: 16) {
                ForEach(levels) { level in
                    DonationLevelCard(level: level)
                }
            }
        }
    }
}
struct DonationLevelCard: View {
    let level: DonationLevelContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: level.icon)
                    .font(.chieacCardTitle)
                    .foregroundColor(.chieacSecondary)
                Text(level.amount)
                    .font(.chieacCardTitle)
                    .foregroundColor(.chieacTextPrimary) // no special color now
                Text(level.title)
                    .font(.chieacCardSubtitle)
                    .foregroundColor(.chieacTextPrimary)
                Spacer(minLength: 0)
            }
            Text(level.description)
                .font(.chieacBody)
                .foregroundColor(.chieacTextSecondary)
                .lineSpacing(3)
    }
    .padding(20)
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Long Term Solutions Section
struct LongTermSolutionsSection: View {
    let section: SectionWithParagraphs
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.title)
                .font(.chieacHero)
                .foregroundColor(.chieacTextPrimary)
                .padding(.bottom, 4)
            ForEach(section.paragraphs.indices, id: \.self) { idx in
                let text = section.paragraphs[idx]
                Text(text)
                    .font(idx == 0 ? .chieacBodySecondary : .chieacBody)
                    .foregroundColor(idx == 0 ? .chieacTextPrimary : .chieacTextSecondary)
                    .lineSpacing(3)
            }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Why ChiEAC Section
struct WhyChiEACSection: View {
    let section: SectionWithParagraphs
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section.title)
                .font(.chieacHero)
                .foregroundColor(.chieacTextPrimary)
                .padding(.bottom, 4)
            ForEach(section.paragraphs.indices, id: \.self) { idx in
                let text = section.paragraphs[idx]
                Text(text)
                    .font(idx == 1 ? .chieacBodySecondary : (idx == section.paragraphs.count - 1 ? .chieacCardTitle : .chieacBody))
                    .foregroundColor(idx == 1 ? .chieacPrimary : (idx == section.paragraphs.count - 1 ? .chieacSecondary : .chieacTextSecondary))
                    .lineSpacing(3)
                    .padding(.top, idx == section.paragraphs.count - 1 ? 8 : 0)
            }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(Color.white)
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Call to Action Section
struct CallToActionSection: View {
    @Binding var showDonationView: Bool
    let isEnabled: Bool
    let cta: SupportCTAContent
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 12) {
                Text(cta.headline)
                    .font(.chieacHero)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
//                    .lineSpacing(4)
                
                Text(cta.subheadline)
                    .font(.chieacBody)
                    .foregroundColor(.white)
                    .opacity(0.95)
                    .multilineTextAlignment(.center)
//                    .lineSpacing(3)
            }
            
            Button(action: { if isEnabled { showDonationView = true } }) {
                HStack(spacing: 12) {
                    if let heart = cta.badges.first(where: { $0.label.lowercased().contains("secure") == false })?.emoji {
                        Text(heart)
                            .font(.headline)
                    }
                    
                    Text(cta.buttonLabel)
                        .font(.chieacButtonText)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.chieacPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1.0 : 0.7)
            
            Text(isEnabled ? cta.reassuranceText : "Loading donation link…")
                .font(.chieacBody)
                .foregroundColor(.white)
                .opacity(0.95)
                .multilineTextAlignment(.center)
//                .padding(.top, 8)
            
            HStack(spacing: 16) {
                ForEach(cta.badges) { badge in
                    VStack(spacing: 4) {
                        Text(badge.emoji)
                            .font(.caption)
                        Text(badge.label)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .opacity(0.9)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.chieacPrimary, .chieacSecondary]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: .chieacPrimary.opacity(0.25), radius: 7, x: 0, y: 3)
    }
}

struct SupportMissionView_Previews: PreviewProvider {
    static var previews: some View {
        SupportMissionView()
    }
}
