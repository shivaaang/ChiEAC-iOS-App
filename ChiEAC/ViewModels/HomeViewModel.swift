//
//  HomeViewModel.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Home ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var error: Error?
    
    private let appDataManager = AppDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var coreWork: [CoreWork] { appDataManager.coreWork }
    var impactStats: [ImpactStat] { appDataManager.impactStats }
    var organizationData: OrganizationInfo? { appDataManager.organizationData }
    var articles: [Article] { appDataManager.articles }
    
    var hasError: Bool {
        error != nil || appDataManager.error != nil
    }
    
    var errorMessage: String {
        error?.localizedDescription ?? appDataManager.error?.localizedDescription ?? "An unknown error occurred"
    }
    
    var isAnyContentLoading: Bool {
        appDataManager.shouldShowLoading
    }
    
    var hasDataLoaded: Bool {
        appDataManager.hasData
    }
    
    // MARK: - Initialization
    init() {
        // No need to load data here - AppDataManager handles it
        
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
}



// MARK: - Home Specific Errors
enum HomeError: LocalizedError {
    case coreWorkLoadFailed
    case impactStatsLoadFailed
    case organizationDataLoadFailed
    case networkUnavailable
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .coreWorkLoadFailed:
            return "Unable to load our core work information. Please try again."
        case .impactStatsLoadFailed:
            return "Unable to load impact statistics. Please try again."
        case .organizationDataLoadFailed:
            return "Unable to load organization information. Please try again."
        case .networkUnavailable:
            return "Network connection unavailable. Please check your internet connection."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}