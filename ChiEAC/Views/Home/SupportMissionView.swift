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
    
    var body: some View {
        ScrollView {
                VStack(spacing: 15) {
                    // Header Section
                    SupportMissionHeaderSection()
                    
                    // Mission Statement
                    MissionStatementSection()
                    
                    // Impact Numbers
                    ImpactNumbersSection()
                    
                    // What Your Gift Provides
                    DonationImpactSection()
                    
                    // Long-term Solutions
                    LongTermSolutionsSection()
                    
                    // Why ChiEAC
                    WhyChiEACSection()
                    
                    // Call to Action
                    CallToActionSection(showDonationView: $showDonationView, isEnabled: donationURL != nil)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
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
        }
    }
}

// MARK: - Header Section
struct SupportMissionHeaderSection: View {
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
                Text("Make a Real Difference in Chicago Communities")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.chieacPrimary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - Mission Statement Section
struct MissionStatementSection: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("When you give to the ChiEAC Community Impact Fund, you are changing lives.")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.chieacTextPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Text("Your gift supports migrant students and families, first generation college students, and underserved communities across Chicago with direct assistance, trusted programs, and lasting opportunities.")
                .font(.body)
                .foregroundColor(.chieacTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            Text("This is not just charity. This is how change begins...person to person, family to family.")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.chieacSecondary)
                .multilineTextAlignment(.center)
                .italic()
                .padding(.top, 12)
        }
        .padding(24)
        .background(Color.chieacCardGreen)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Impact Numbers Section
struct ImpactNumbersSection: View {
    let stats = [
        ImpactNumber(number: "500+", label: "Families Served", subtitle: "since 2020", icon: "house.fill"),
        ImpactNumber(number: "1,600+", label: "Students Supported", subtitle: "across Chicago", icon: "graduationcap.fill"),
        ImpactNumber(number: "100%", label: "Community Trust", subtitle: "volunteer powered", icon: "heart.fill"),
        ImpactNumber(number: "$1 = $5", label: "Impact Multiplier", subtitle: "through partnerships", icon: "dollarsign.circle.fill")
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.chieacSecondary)
                    .font(.title2)
                
                Text("Our Proven Impact")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.chieacTextPrimary)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(stats, id: \.number) { stat in
                    ImpactNumberCard(stat: stat)
                }
            }
        }
    }
}

struct ImpactNumber {
    let number: String
    let label: String
    let subtitle: String
    let icon: String
}

struct ImpactNumberCard: View {
    let stat: ImpactNumber
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: stat.icon)
                .font(.title2)
                .foregroundColor(.chieacSecondary)
            
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
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Donation Impact Section
struct DonationImpactSection: View {
    let donationLevels = [
        DonationLevel(
            emoji: "📱",
            amount: "$65",
            title: "gives a lifeline",
            description: "Provides a newly arrived migrant family with a phone, unlimited data, and hotspot access for one month. This allows them to stay in touch with caseworkers, apply for school and work, and connect with loved ones.",
            color: Color.chieacPrimary
        ),
        DonationLevel(
            emoji: "🚍",
            amount: "$25",
            title: "opens a door",
            description: "Covers public transit for students and parents to get to school, legal appointments, or medical care. A ride should never be the reason someone is left behind.",
            color: Color(hex: "#28a745")
        ),
        DonationLevel(
            emoji: "📚",
            amount: "$100",
            title: "empowers a student",
            description: "Supports a young person in our ELEVATE Program, giving them access to mentorship, tutoring, and culturally grounded college and career guidance.",
            color: Color(hex: "#17a2b8")
        ),
        DonationLevel(
            emoji: "💼",
            amount: "$150",
            title: "prepares for the future",
            description: "Funds career readiness training through our IMPACT Program, including resume support, job search coaching, and financial literacy tools that change economic futures.",
            color: Color(hex: "#6f42c1")
        ),
        DonationLevel(
            emoji: "🧠",
            amount: "$200",
            title: "brings healing",
            description: "Supports trauma-informed mental health sessions for families who have endured displacement, poverty, or violence. These small group sessions offer connection, coping tools, and peace of mind.",
            color: Color(hex: "#fd7e14")
        ),
        DonationLevel(
            emoji: "⚖️",
            amount: "$500",
            title: "provides hope through legal help",
            description: "Helps us grow our volunteer legal clinic, where families receive trusted guidance on asylum cases, work permits, and school enrollment—free of charge.",
            color: Color.chieacSecondary
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("💡")
                    .font(.title2)
                
                Text("What Your Gift Provides")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.chieacTextPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 16) {
                ForEach(donationLevels, id: \.amount) { level in
                    DonationLevelCard(level: level)
                }
            }
        }
    }
}

struct DonationLevel {
    let emoji: String
    let amount: String
    let title: String
    let description: String
    let color: Color
}

struct DonationLevelCard: View {
    let level: DonationLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(level.emoji)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(level.amount)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(level.color)
                        
                        Text(level.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.chieacTextPrimary)
                    }
                }
                
                Spacer()
            }
            
            Text(level.description)
                .font(.body)
                .foregroundColor(.chieacTextSecondary)
                .lineSpacing(3)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Long Term Solutions Section
struct LongTermSolutionsSection: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("📊")
                    .font(.title2)
                
                Text("Your gift also fuels long-term solutions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.chieacTextPrimary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("ChiEAC's Data Science Alliance transforms family stories into insight.")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.chieacTextPrimary)
                    .lineSpacing(3)
                
                Text("We analyze real-time feedback to improve our services, influence policy, and hold institutions accountable. Your support helps us lead with data and heart.")
                    .font(.body)
                    .foregroundColor(.chieacTextSecondary)
                    .lineSpacing(3)
            }
        }
        .padding(20)
        .background(Color.chieacCardGreen)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Why ChiEAC Section
struct WhyChiEACSection: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("💙")
                    .font(.title2)
                
                Text("Why Now? Why ChiEAC?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.chieacTextPrimary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Since 2020, ChiEAC has served over 500 families—stretching every dollar through volunteer power, partnerships, and deep trust in the community.")
                    .font(.body)
                    .foregroundColor(.chieacTextSecondary)
                    .lineSpacing(3)
                
                Text("We do more with less, because we listen more, care more, and show up where others do not.")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.chieacPrimary)
                    .lineSpacing(3)
                
                Text("Give today. Be part of something that matters.")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.chieacSecondary)
                    .padding(.top, 8)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Call to Action Section
struct CallToActionSection: View {
    @Binding var showDonationView: Bool
    let isEnabled: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Together, we can build a Chicago where every family has a fair chance.")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                Text("Join hundreds of supporters who believe in creating lasting change through direct action and community-driven solutions.")
                    .font(.body)
                    .foregroundColor(.white)
                    .opacity(0.95)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            
            Button(action: { if isEnabled { showDonationView = true } }) {
                HStack(spacing: 12) {
                    Text("❤️")
                        .font(.headline)
                    
                    Text("Donate Now")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.chieacPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1.0 : 0.7)
            
            Text(isEnabled ? "You'll receive a tax receipt for making a donation" : "Loading donation link…")
                .font(.body)
                .foregroundColor(.white)
                .opacity(0.95)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("🔒")
                        .font(.caption)
                    Text("Secure")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .opacity(0.9)
                }
                
                VStack(spacing: 4) {
                    Text("🏆")
                        .font(.caption)
                    Text("501(c)(3)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .opacity(0.9)
                }
                
                VStack(spacing: 4) {
                    Text("💯")
                        .font(.caption)
                    Text("Tax Deductible")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .opacity(0.9)
                }
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.chieacPrimary, .chieacSecondary]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: .chieacPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct SupportMissionView_Previews: PreviewProvider {
    static var previews: some View {
        SupportMissionView()
    }
}
