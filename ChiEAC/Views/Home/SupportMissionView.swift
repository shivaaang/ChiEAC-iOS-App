//
//  SupportMissionView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct SupportMissionView: View {
    @State private var showDonationView = false
    @State private var donationURL: String? = nil
    @State private var callToActionTop: CGFloat = .greatestFiniteMagnitude
    @State private var containerBottom: CGFloat = 0
    @State private var content: SupportMissionContent? = nil
    
    var body: some View {
        GeometryReader { outer in
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 15) {
                        // Header Section
                        SupportMissionHeaderSection(title: content?.headerTitle)
                        
                        // Mission Statement
                        if let c = content { MissionStatementSection(copy: c.mission) }
                        
                        // Impact Numbers
                        if let c = content { ImpactNumbersSection(stats: c.impactNumbers) }
                        
                        // What Your Gift Provides
                        if let c = content { DonationImpactSection(heading: c.donationLevelsHeading, levels: c.donationLevels) }
                        
                        // Long-term Solutions
                        if let c = content { LongTermSolutionsSection(section: c.longTermSolutions) }
                        
                        // Why ChiEAC
                        if let c = content { WhyChiEACSection(section: c.whyChiEAC) }
                        
                        // Call to Action (tracked for visibility)
                        if let c = content {
                            CallToActionSection(showDonationView: $showDonationView, isEnabled: donationURL != nil, cta: c.cta)
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
                
                // Floating Donate Button
                if shouldShowFloatingButton(globalVisibleBottom: outer.frame(in: .global).maxY) {
                    FloatingDonateButton(isEnabled: donationURL != nil) {
                        if donationURL != nil { showDonationView = true }
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
            if let url = donationURL {
                ExternalLinkWebView(urlString: url, title: "Donate to ChiEAC")
            } else {
                Text("Missing donation link.")
                    .padding()
            }
        }
        .onAppear {
            // Load donation URL from fixtures via repository ASAP on appear
            if donationURL == nil {
                let links = LocalRepository.shared.loadExternalLinks()
                donationURL = links.first(where: { $0.name.lowercased() == "donation" })?.address
            }
            if content == nil {
                content = LocalRepository.shared.loadSupportMissionContent()
            }
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
        stats.map { ImpactStat(id: "supportImpact." + $0.id, number: $0.number, label: $0.label, subtitle: $0.subtitle, icon: $0.icon) }
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
