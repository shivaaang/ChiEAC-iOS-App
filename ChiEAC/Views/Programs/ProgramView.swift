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
                    // Hero Header (refactored)
                    HeroHeader(
                        title: "Our Programs",
                        subtitle: "Empowering Chicago students through education, advocacy, and opportunity",
                        systemImage: "graduationcap.fill"
                    )
                    
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
