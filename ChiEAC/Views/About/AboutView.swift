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
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.chieacSecondary)
                        
                        Text("About Us")
                            .font(.chieacSectionHeader)
                            .foregroundColor(.chieacPrimary)
                        
                        Text("Meet the passionate team behind ChiEAC's mission")
                            .font(.chieacBody)
                            .foregroundColor(.chieacTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    
                    // Team Type Selector
                    VStack(spacing: 20) {
                        // Segmented Control
                        Picker("Team Type", selection: Binding(
                            get: { viewModel.selectedTeamType },
                            set: { viewModel.selectTeamType($0) }
                        )) {
                            Text("Core Team").tag(TeamType.core)
                            Text("Advisory Board").tag(TeamType.advisory)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        
                        // Team Members with Loading States
                        if viewModel.isAnyContentLoading {
                            LazyVStack(spacing: 16) {
                                ForEach(0..<3, id: \.self) { _ in
                                    TeamMemberLoadingSkeleton()
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.currentTeamMembers, id: \.id) { member in
                                    TeamMemberCard(
                                        member: member,
                                        onEmailTap: { viewModel.openEmail(for: member) },
                                        onPhoneTap: { viewModel.openPhone(for: member) }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 20)
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
