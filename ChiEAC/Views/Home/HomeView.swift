//
//  HomeVIEW.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let orgData = viewModel.organizationData {
                    VStack(spacing: 0) {
                        // Header Section
                        HeaderSection(tagline: orgData.tagline)
                        
                        // Content
                        VStack(spacing: 30) {
                            // Mission Statement
                            MissionSection(
                                organizationData: orgData,
                                isLoading: viewModel.isLoadingOrganizationData
                            )
                            
                            // Our Core Work
                            CoreWorkSection(
                                coreWork: viewModel.coreWork,
                                isLoading: viewModel.isLoadingCoreWork
                            )
                            
                            // Our Impact Stats
                            ImpactStatsSection(
                                impactStats: viewModel.impactStats,
                                isLoading: viewModel.isLoadingImpactStats
                            )
                            
                            // Learn More CTA
                            LearnMoreSection()
                            
                            Spacer(minLength: 20)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        .background(Color.chieacLightBackground)
                    }
                } else {
                    // Show a loading indicator while the main organization data is loading
                    ProgressView()
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
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    let tagline: String
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Logo section
            VStack(spacing: 16) {
                // Logo
                Image("chieac-logo-icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .padding(20)
                    .background(Circle().fill(Color.white))
                    .shadow(color: .chieacPrimary.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Text("ChiEAC")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.chieacPrimary)
                
                Text("Chicago Education Advocacy Cooperative")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.chieacTextPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)
            
            // Tagline (using ViewModel)
            Text(tagline)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.chieacTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.chieacCardGreen)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.bottom, 30)
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
                    .font(.title2)
                    .fontWeight(.bold)
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
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Our Core Work")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.chieacTextPrimary)
            
            if isLoading {
                // Loading state for core work
                VStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { _ in
                        CoreWorkLoadingSkeleton()
                    }
                }
            } else {
                // Using ViewModel data
                VStack(spacing: 20) {
                    ForEach(coreWork, id: \.title) { work in
                        CoreWorkTile(work: work)
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
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.chieacSecondary)
                
                Text("Our Impact")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.chieacTextPrimary)
            }
            
            if isLoading {
                // Loading state for impact stats
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(0..<4, id: \.self) { _ in
                        ImpactStatLoadingSkeleton()
                    }
                }
            } else {
                // Using ViewModel data for stats
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(impactStats, id: \.label) { stat in
                        ImpactStatCard(stat: stat)
                    }
                }
            }
        }
        .padding(24)
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

// MARK: - Loading Skeletons
struct CoreWorkLoadingSkeleton: View {
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Icon skeleton
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
            
            // Content skeleton
            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                    .frame(maxWidth: 120)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity * 0.7)
            }
            
            Spacer()
        }
        .padding(24)
        .background(Color.chieacCardGreen.opacity(0.5))
        .cornerRadius(16)
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
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
        .redacted(reason: .placeholder)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}