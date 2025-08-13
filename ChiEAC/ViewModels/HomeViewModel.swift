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
    @Published var coreWork: [CoreWork] = []
    @Published var impactStats: [ImpactStat] = []
    @Published var organizationData: OrganizationInfo? // Can be nil before loading
    @Published var articles: [Article] = []
    
    @Published var error: Error?
    
    // MARK: - Loading States
    @Published var isLoadingCoreWork = false
    @Published var isLoadingImpactStats = false
    @Published var isLoadingOrganizationData = false
    
    private let repository: DataRepository

    // MARK: - Computed Properties
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String {
        error?.localizedDescription ?? "An unknown error occurred"
    }
    
    var isAnyContentLoading: Bool {
        isLoadingCoreWork || isLoadingImpactStats || isLoadingOrganizationData
    }
    
    // MARK: - Initialization
    init(repository: DataRepository = LocalRepository.shared) {
        self.repository = repository
        listenForAllData()
    }
    
    deinit {
    // no async tasks to cancel in local mode
    }
    
    // MARK: - Public Methods
    func listenForAllData() {
    listenForCoreWork()
    listenForImpactStats()
    listenForOrganizationInfo()
    }
    
    func retry() {
        error = nil
        listenForAllData()
    }
    
    // MARK: - Private Listener Methods
    private func listenForCoreWork() {
        isLoadingCoreWork = true
        let items = repository.loadCoreWork()
        self.coreWork = items
        self.isLoadingCoreWork = false
    }
    
    private func listenForImpactStats() {
        isLoadingImpactStats = true
        let items = repository.loadImpactStats()
        self.impactStats = items
        self.isLoadingImpactStats = false
    }
    
    private func listenForOrganizationInfo() {
        isLoadingOrganizationData = true
        let info = repository.loadOrganizationInfo()
        self.organizationData = info
        self.isLoadingOrganizationData = false
        self.articles = repository.loadArticles()
    }
    
    // MARK: - Helper Methods
    func getCoreWorkByTitle(_ title: String) -> CoreWork? {
        coreWork.first { $0.title == title }
    }
    
    func getImpactStatByLabel(_ label: String) -> ImpactStat? {
        impactStats.first { $0.label == label }
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