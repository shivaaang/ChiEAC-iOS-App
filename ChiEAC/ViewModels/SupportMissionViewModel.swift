//
//  SupportMissionViewModel.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/15/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Support Mission ViewModel
@MainActor
class SupportMissionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var error: Error?
    
    private let appDataManager = AppDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var supportMissionContent: SupportMissionContent? { 
        appDataManager.supportMissionContent 
    }
    
    var donationURL: String? {
        appDataManager.externalLinks.first(where: { $0.name.lowercased() == "donation" })?.address
    }
    
    var hasError: Bool {
        error != nil || appDataManager.error != nil
    }
    
    var errorMessage: String {
        error?.localizedDescription ?? appDataManager.error?.localizedDescription ?? "An unknown error occurred"
    }
    
    var isLoading: Bool {
        appDataManager.shouldShowLoading && supportMissionContent == nil
    }
    
    var hasData: Bool {
        supportMissionContent != nil
    }
    
    // MARK: - Initialization
    init() {
        // Data should already be loading/loaded via AppDataManager
        // No need to trigger additional loads
        
        // Observe AppDataManager changes to trigger UI updates
        appDataManager.objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func retry() {
        error = nil
        Task {
            await appDataManager.forceRefreshAllData()
        }
    }
    
    func loadDataIfNeeded() async {
        // Ensure data is loaded if not already available
        await appDataManager.initializeApp()
    }
}

// MARK: - Support Mission Specific Errors
enum SupportMissionError: LocalizedError {
    case contentLoadFailed
    case externalLinksLoadFailed
    case networkUnavailable
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .contentLoadFailed:
            return "Unable to load support mission content. Please try again."
        case .externalLinksLoadFailed:
            return "Unable to load donation link. Please try again."
        case .networkUnavailable:
            return "Network connection unavailable. Please check your internet connection."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}
