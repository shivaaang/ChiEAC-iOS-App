//
//  HomeVIEW.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI
import WebKit

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                if let orgData = viewModel.organizationData {
                    VStack(spacing: 0) {
                        // Hero Header
                        HeaderSection(organization: orgData)
                        
                        // Main Content
                        VStack(spacing: 40) {
                            // Mission Statement
                            MissionSection(
                                organizationData: orgData,
                                isLoading: viewModel.isLoadingOrganizationData
                            )
                            
                            // Our Core Work (grid)
                            CoreWorkSection(
                                coreWork: viewModel.coreWork,
                                isLoading: viewModel.isLoadingCoreWork
                            )
                            
                            // Our Impact Stats
                            ImpactStatsSection(
                                impactStats: viewModel.impactStats,
                                isLoading: viewModel.isLoadingImpactStats
                            )
                            
                            // Articles - horizontally scrollable cards
                            ArticlesSection(articles: viewModel.articles)
                            
                            // Learn More CTA
                            LearnMoreSection()
                            
                            Spacer(minLength: 24)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .background(Color.chieacLightBackground)
                    }
                } else {
                    // Show a loading indicator while the main organization data is loading
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading ChiEAC…")
                            .font(.chieacCaption)
                            .foregroundColor(.chieacTextSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color.chieacLightBackground)
            .ignoresSafeArea(edges: .top)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .accentColor(.chieacPrimary)
        .alert("Error Loading Content", isPresented: .constant(viewModel.hasError)) {
            Button("Retry") { viewModel.retry() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .refreshable { viewModel.retry() }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    let organization: OrganizationInfo
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ZStack {
            // Gradient hero background
            LinearGradient(
                gradient: Gradient(colors: [.chieacMintGreen, .white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                // Decorative circles for subtle depth
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 240, height: 240)
                        .offset(x: -140, y: -60)
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 180, height: 180)
                        .offset(x: 160, y: 10)
                }
            )
            
            VStack(spacing: 15) {
                // Logo + Name
                VStack(spacing: 5) {
                    Image("chieac-logo-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding(20)
                        .background(Circle().fill(Color.white))
                        .shadow(color: .chieacPrimary.opacity(0.15), radius: 10, x: 0, y: 6)
                    
                    Text("ChiEAC")
                        .font(.chieacAppTitle)
                        .foregroundColor(.chieacPrimary)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Chicago Education Advocacy Cooperative")
                        .font(.title3.weight(.medium))
                        .foregroundColor(.chieacTextPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)
                
                // Tagline chip
                HStack(spacing: 8) {
//                    Image(systemName: "heart.fill")
//                        .foregroundColor(.chieacSecondary)
                    Text(organization.tagline)
//                        .font(.system(size: 12, weight: .light))
                        .font(.chieacTagline)
                        .foregroundColor(.chieacTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                )
                .padding(.horizontal, 30)
                
                // CTA buttons
                HStack(spacing: 14) {
                    NavigationLink(destination: SupportMissionView()) {
                        HStack(spacing: 8) {
                            Text("Support Us")
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryCTAButtonStyle())
                    
                    Button(action: {
                        if let url = URL(string: "mailto:\(organization.contactEmail)") {
                            openURL(url)
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Refer a Student")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(OutlineCTAButtonStyle())
                }
                .padding(.horizontal, 30)
                .padding(.top, 2)
            }
            .padding(.bottom, 26)
            .padding(.top, 64)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

// MARK: - Mission Section
struct MissionSection: View {
    let organizationData: OrganizationInfo
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                // Loading state for mission section
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading mission...")
                        .font(.chieacCaption)
                        .foregroundColor(.chieacTextSecondary)
                }
                .frame(height: 120)
            } else {
                // Mission statement using ViewModel data
                Text(organizationData.mission)
                    .font(.chieacHero)
                    .foregroundColor(.chieacTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                
                // Description using ViewModel data
                Text(organizationData.description)
                    .font(.body)
                    .foregroundColor(.chieacTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 10)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
        .background(Color.chieacCardGreen)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Core Work Section
struct CoreWorkSection: View {
    let coreWork: [CoreWork]
    let isLoading: Bool
    
    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Our Core Work")
                .font(.chieacSectionHeader)
                .foregroundColor(.chieacTextPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 6)
            
            if isLoading {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(0..<4, id: \.self) { _ in
                        CoreWorkLoadingSkeleton()
                    }
                }
            } else {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(coreWork, id: \.title) { work in
                        CoreWorkCard(work: work)
                    }
                }
            }
        }
    }
}

// CoreWorkTile component is now in Components/CoreWorkTile.swift

// MARK: - Impact Stats Section
struct ImpactStatsSection: View {
    let impactStats: [ImpactStat]
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.chieacSecondary)
                Text("Our Impact")
                    .font(.chieacSectionHeader)
                    .foregroundColor(.chieacTextPrimary)
            }
            
            if isLoading {
                // Loading state for impact stats
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 14) {
                    ForEach(0..<4, id: \.self) { _ in
                        ImpactStatLoadingSkeleton()
                    }
                }
            } else {
                // Using ViewModel data for stats
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 14) {
                    ForEach(impactStats, id: \.label) { stat in
                        ImpactStatCard(stat: stat)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.chieacCardGreen)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// ImpactStatCard component is now in Components/ImpactStatCard.swift

// MARK: - Learn More Section
struct LearnMoreSection: View {
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Text("Support Our Mission")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Help us build a better future for Chicago's students and families. Learn how your support creates lasting change in our community.")
                    .font(.body)
                    .foregroundColor(.white)
                    .opacity(0.95)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            
            NavigationLink(destination: SupportMissionView()) {
                HStack(spacing: 8) {
                    Text("Know More")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.chieacPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .padding(28)
        .background(
            ZStack {
                // New photo background for richer look
                Image("support-mission-photo")
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.05)) // slight contrast normalization

                // Brand gradient overlay for legibility
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.chieacPrimary.opacity(0.25),
                        Color.chieacPrimary.opacity(0.85)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
        .shadow(color: .chieacPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Articles Section
struct ArticlesSection: View {
    let articles: [Article]
    @State private var selectedArticle: Article?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Articles")
                .font(.chieacSectionHeader)
                .foregroundColor(.chieacTextPrimary)
                .padding(.horizontal, 2)
                Spacer()
                NavigationLink(destination: ArticlesView(articles: articles)) {
                    HStack(spacing: 4) {
                        Text("See all")
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline)
                    .foregroundColor(.chieacSecondary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    // Show only top 5 articles
                    ForEach(Array(articles.prefix(5)), id: \.mediumLink) { article in
                        ArticleHomeCard(article: article)
                            .onTapGesture { selectedArticle = article }
                    }

                    // Sixth card: Explore More Articles
                    NavigationLink(destination: ArticlesView(articles: articles)) {
                        ExploreMoreArticlesCard()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 2)
            }
        }
        .sheet(item: $selectedArticle, content: { article in
            ArticleWebView(urlString: article.mediumLink, title: "Article")
        })
    }
}

// Special CTA card for exploring more articles
private struct ExploreMoreArticlesCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image from assets
            Image("team-photo")
                .resizable()
                .scaledToFill()
                .frame(width: 260, height: 150)
                .clipped()
                .cornerRadius(16)

            // Brand gradient overlay for legibility
            LinearGradient(
                gradient: Gradient(colors: [Color.chieacPrimary.opacity(0.0), Color.chieacPrimary.opacity(0.85)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(16)
            .frame(width: 260, height: 150)

            // Text content
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Explore More Articles")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text("Browse 200+ stories")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .opacity(0.95)
            }
            .padding(12)
        }
        .frame(width: 260, height: 150)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Explore more articles")
    }
}

// MARK: - Loading Skeletons
struct CoreWorkLoadingSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 46, height: 46)
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 18)
                .frame(maxWidth: 120)
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 14)
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 14)
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color.chieacCardGreen.opacity(0.6))
        .cornerRadius(14)
        .redacted(reason: .placeholder)
    }
}

struct ImpactStatLoadingSkeleton: View {
    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 24)
                .frame(maxWidth: 80)
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 16)
                .frame(maxWidth: 60)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.7))
        .cornerRadius(12)
        .redacted(reason: .placeholder)
    }
}

// MARK: - New UI Components

// Inline web components removed in favor of dedicated ArticleView
struct CoreWorkCard: View {
    let work: CoreWork
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle()
                    .fill(work.color.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: work.icon)
                    .foregroundColor(work.color)
            }
            
            Text(work.title)
                .font(.chieacCardTitle)
                .foregroundColor(.chieacTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
            
            Text(work.description)
                .font(.chieacCardBody)
                .foregroundColor(.chieacTextSecondary)
                .lineSpacing(2)
                .lineLimit(4)
            
            HStack(spacing: 6) {
                Text("Learn more")
                    .font(.chieacCaption)
                    .foregroundColor(.chieacSecondary)
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.chieacSecondary)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
    }
}

struct PrimaryCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.chieacButtonText)
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.chieacPrimary.opacity(configuration.isPressed ? 0.85 : 1.0))
            )
            .shadow(color: .chieacPrimary.opacity(0.25), radius: 6, x: 0, y: 4)
            .contentShape(Rectangle())
    }
}

struct OutlineCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.chieacButtonSecondary)
            .foregroundColor(.chieacPrimary)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.chieacPrimary, lineWidth: 1.5)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .contentShape(Rectangle())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
