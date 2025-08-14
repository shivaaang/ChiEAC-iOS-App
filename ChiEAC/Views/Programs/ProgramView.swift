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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero Header
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [.chieacMintGreen, .white]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        VStack(spacing: 12) {
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 56))
                                .foregroundColor(.chieacSecondary)
                                .padding(18)
                                .background(Circle().fill(Color.white))
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                            
                            Text("Our Programs")
                                .font(.chieacAppTitle)
                                .foregroundColor(.chieacPrimary)
                            
                            Text("Empowering Chicago students through education, advocacy, and opportunity")
                                .font(.chieacBody)
                                .foregroundColor(.chieacTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                    }
                    .frame(maxWidth: .infinity)
                    
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
                                    ProgramCard(program: program)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    }
                    
                    Spacer(minLength: 24)
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

// ProgramCard component is now in Components/ProgramCard.swift

// ProgramDetailView moved to its own file: Views/Programs/ProgramDetailView.swift

struct ProgramsView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramsView()
    }
}
