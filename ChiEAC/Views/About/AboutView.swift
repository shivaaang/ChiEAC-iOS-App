//
//  AboutView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct AboutView: View {
    @StateObject private var viewModel = AboutViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Header
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [.chieacMintGreen, .white]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        VStack(spacing: 14) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 56))
                                .foregroundColor(.chieacSecondary)
                                .padding(18)
                                .background(Circle().fill(Color.white))
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            
                            Text("About Us")
                                .font(.chieacAppTitle)
                                .foregroundColor(.chieacPrimary)
                            
                            Text("Meet the passionate team behind ChiEAC's mission")
                                .font(.chieacBody)
                                .foregroundColor(.chieacTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Team summary cards
                    VStack(spacing: 16) {
                        if viewModel.isAnyContentLoading {
                            // Simple placeholders
                            ForEach(0..<2, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.chieacCardGreen.opacity(0.5))
                                    .frame(height: 180)
                                    .padding(.horizontal, 20)
                                    .redacted(reason: .placeholder)
                            }
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.teams, id: \.id) { team in
                                    NavigationLink(destination: TeamView(team: team, members: viewModel.members(for: team))) {
                                        TeamCard(
                                            team: team,
                                            members: viewModel.members(for: team)
                                        )
                                        .padding(.horizontal, 20)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                    
                    Spacer(minLength: 24)
                }
            }
            .background(Color.chieacLightBackground)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .accentColor(.chieacPrimary)
        .alert("Error Loading Team", isPresented: .constant(viewModel.hasError)) {
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

// TeamMemberCard and ContactButton components are now in Components/TeamMemberCard.swift

// MARK: - Team Member Loading Skeleton
struct TeamMemberLoadingSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header skeleton
            HStack(alignment: .top, spacing: 16) {
                // Avatar skeleton
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                // Info skeleton
                VStack(alignment: .leading, spacing: 6) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 20)
                        .frame(maxWidth: 150)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                        .frame(maxWidth: 120)
                }
                
                Spacer()
            }
            
            // Bio skeleton
            VStack(alignment: .leading, spacing: 4) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity * 0.8)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .frame(maxWidth: .infinity * 0.6)
            }
            
            // Contact buttons skeleton
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 36)
                
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 36)
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.chieacCardGreen.opacity(0.5))
        .cornerRadius(16)
        .redacted(reason: .placeholder)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
