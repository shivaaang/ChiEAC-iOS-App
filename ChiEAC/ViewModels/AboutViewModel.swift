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
    @Published var teams: [Team] = []
    @Published var members: [TeamMember] = []
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
    
    var isAnyContentLoading: Bool { isLoading }
    
    var coreTeamMembers: [TeamMember] {
        members.filter { $0.team == .coreTeam && !$0.name.isEmpty }
    }
    
    var advisoryBoardMembers: [TeamMember] {
        members.filter { $0.team == .advisoryBoard && !$0.name.isEmpty }
    }
    
    // MARK: - Initialization
    init(repository: DataRepository = LocalRepository.shared) {
        self.repository = repository
    load()
    }
    
    deinit {}
    
    // MARK: - Public Methods
    func load() {
        isLoading = true
        error = nil
        
        self.teams = repository.loadTeams()
        self.members = repository.loadTeamMembers()
        self.isLoading = false
    }
    
    func retry() {
        load()
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