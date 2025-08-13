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
    
    private let repository: DataRepository

    // MARK: - Computed Properties
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String {
        error?.localizedDescription ?? "An unknown error occurred"
    }
    
    // MARK: - Initialization
    init(repository: DataRepository = LocalRepository.shared) {
        self.repository = repository
        listenForPrograms()
    }
    
    
    // MARK: - Public Methods
    func listenForPrograms() {
        isLoading = true
        error = nil
        
    let data = repository.loadPrograms()
    self.programs = data
    self.isLoading = false
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