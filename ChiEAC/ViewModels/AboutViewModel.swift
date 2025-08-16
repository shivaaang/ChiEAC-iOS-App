//
//  AboutViewModel.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - About ViewModel
@MainActor
class AboutViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var error: Error?
    
    private let appDataManager = AppDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var teams: [Team] { appDataManager.teams }
    var members: [TeamMember] { appDataManager.teamMembers }
    
    var hasError: Bool {
        error != nil || appDataManager.error != nil
    }
    
    var errorMessage: String {
        error?.localizedDescription ?? appDataManager.error?.localizedDescription ?? "An unknown error occurred"
    }
    
    var isLoading: Bool {
        appDataManager.shouldShowLoading
    }
    
    var hasDataLoaded: Bool {
        !appDataManager.teams.isEmpty && !appDataManager.teamMembers.isEmpty
    }
    
    var coreTeamMembers: [TeamMember] {
        members.filter { $0.team == .coreTeam && !$0.name.isEmpty }
    }
    
    var advisoryBoardMembers: [TeamMember] {
        members.filter { $0.team == .advisoryBoard && !$0.name.isEmpty }
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
    
    // MARK: - Helper Methods
    func getTeamMember(byId id: String) -> TeamMember? {
        members.first { $0.id == id }
    }
    
    func getTeamMember(byName name: String) -> TeamMember? {
        members.first { $0.name == name }
    }
    
    func getCoreTeamCount() -> Int {
        coreTeamMembers.count
    }
    
    func getAdvisoryBoardCount() -> Int {
        advisoryBoardMembers.count
    }
    
    func getTotalTeamCount() -> Int {
        members.count
    }
    
    // MARK: - Contact Actions removed (no email/phone in new team member schema)

    func members(for team: Team) -> [TeamMember] {
        members.filter { $0.team == team.code && !$0.name.isEmpty }
    }
}

// MARK: - About Specific Errors
enum AboutError: LocalizedError {
    case coreTeamLoadFailed
    case advisoryBoardLoadFailed
    case teamMemberNotFound
    case networkUnavailable
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .coreTeamLoadFailed:
            return "Unable to load core team information. Please try again."
        case .advisoryBoardLoadFailed:
            return "Unable to load advisory board information. Please try again."
        case .teamMemberNotFound:
            return "Team member information not found."
        case .networkUnavailable:
            return "Network connection unavailable. Please check your internet connection."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}