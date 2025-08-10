//
//  ProgramView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct ProgramsView: View {
    @StateObject private var viewModel = ProgramsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Our Programs")
                            .font(.chieacSectionHeader)
                            .foregroundColor(.chieacTextPrimary)
                        
                        Text("Empowering Chicago students through education, advocacy, and opportunity")
                            .font(.chieacBody)
                            .foregroundColor(.chieacTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    
                    // Program Tiles - NOW USES VIEWMODEL WITH LOADING STATES
                    if viewModel.isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading programs...")
                                .font(.chieacBody)
                                .foregroundColor(.chieacTextSecondary)
                        }
                        .frame(height: 200)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(viewModel.programs, id: \.id) { program in
                                NavigationLink(destination: ProgramDetailView(program: program)) {
                                    ProgramTile(program: program)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .background(Color.chieacLightBackground)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .accentColor(.chieacPrimary)
        .alert("Error Loading Programs", isPresented: .constant(viewModel.hasError)) {
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

// ProgramTile component is now in Components/ProgramTile.swift

// MARK: - Program Detail View
struct ProgramDetailView: View {
    let program: ProgramInfo
    
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
                            UIApplication.shared.open(url)
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

struct ProgramsView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramsView()
    }
}
