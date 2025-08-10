//
//  ProgramsViewModel.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Programs ViewModel
@MainActor
class ProgramsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var programs: [ProgramInfo] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var listenerTask: Task<Void, Error>?

    // MARK: - Computed Properties
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String {
        error?.localizedDescription ?? "An unknown error occurred"
    }
    
    // MARK: - Initialization
    init() {
        listenForPrograms()
    }
    
    deinit {
        listenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    func listenForPrograms() {
        isLoading = true
        error = nil
        
        listenerTask?.cancel() // Cancel any existing listener
        
        listenerTask = Task {
            do {
                for try await updatedPrograms in FirebaseService.shared.programsListener() {
                    self.programs = updatedPrograms
                    if self.isLoading {
                        self.isLoading = false
                    }
                    // Clear any previous errors on successful data fetch
                    self.error = nil
                }
            } catch {
                self.isLoading = false
                self.error = error
                print("Error listening for programs: \(error.localizedDescription)")
            }
        }
    }
    
    func retry() {
        listenForPrograms()
    }
    
    // MARK: - Helper Methods
    func program(for id: String) -> ProgramInfo? {
        programs.first { $0.id == id }
    }
    
    var featuredPrograms: [ProgramInfo] {
        // Could implement featured logic here
        programs
    }
}

// MARK: - Custom Errors
enum ProgramsError: LocalizedError {
    case networkUnavailable
    case dataCorrupted
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Network connection unavailable. Please check your internet connection."
        case .dataCorrupted:
            return "Unable to load program data. Please try again."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}