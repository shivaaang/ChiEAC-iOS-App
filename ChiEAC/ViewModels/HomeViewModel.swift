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
    
    @Published var error: Error?
    
    // MARK: - Loading States
    @Published var isLoadingCoreWork = false
    @Published var isLoadingImpactStats = false
    @Published var isLoadingOrganizationData = false
    
    private var coreWorkTask: Task<Void, Error>?
    private var impactStatsTask: Task<Void, Error>?
    private var orgInfoTask: Task<Void, Error>?

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
    init() {
        listenForAllData()
    }
    
    deinit {
        coreWorkTask?.cancel()
        impactStatsTask?.cancel()
        orgInfoTask?.cancel()
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
        coreWorkTask?.cancel()
        coreWorkTask = Task {
            do {
                for try await updatedItems in FirebaseService.shared.coreWorkListener() {
                    self.coreWork = updatedItems
                    if self.isLoadingCoreWork {
                        self.isLoadingCoreWork = false
                    }
                    // Clear any previous errors on successful data fetch
                    self.error = nil
                }
            } catch {
                self.isLoadingCoreWork = false
                self.error = error
                print("Error listening for core work: \(error.localizedDescription)")
            }
        }
    }
    
    private func listenForImpactStats() {
        isLoadingImpactStats = true
        impactStatsTask?.cancel()
        impactStatsTask = Task {
            do {
                for try await updatedItems in FirebaseService.shared.impactStatsListener() {
                    self.impactStats = updatedItems
                    if self.isLoadingImpactStats {
                        self.isLoadingImpactStats = false
                    }
                    self.error = nil
                }
            } catch {
                self.isLoadingImpactStats = false
                self.error = error
                print("Error listening for impact stats: \(error.localizedDescription)")
            }
        }
    }
    
    private func listenForOrganizationInfo() {
        isLoadingOrganizationData = true
        orgInfoTask?.cancel()
        orgInfoTask = Task {
            do {
                for try await updatedInfo in FirebaseService.shared.organizationInfoListener() {
                    self.organizationData = updatedInfo
                    if self.isLoadingOrganizationData {
                        self.isLoadingOrganizationData = false
                    }
                    self.error = nil
                }
            } catch {
                self.isLoadingOrganizationData = false
                self.error = error
                print("Error listening for organization info: \(error.localizedDescription)")
            }
        }
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