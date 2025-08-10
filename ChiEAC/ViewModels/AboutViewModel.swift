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
    @Published var coreTeam: [TeamMember] = []
    @Published var advisoryBoard: [TeamMember] = []
    @Published var selectedTeamType: TeamType = .core
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
    
    var isAnyContentLoading: Bool {
        isLoading
    }
    
    var currentTeamMembers: [TeamMember] {
        switch selectedTeamType {
        case .core:
            return coreTeam
        case .advisory:
            return advisoryBoard
        }
    }
    
    // MARK: - Initialization
    init() {
        listenForTeamMembers()
    }
    
    deinit {
        listenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    func listenForTeamMembers() {
        isLoading = true
        error = nil
        
        listenerTask?.cancel()
        
        listenerTask = Task {
            do {
                for try await updatedMembers in FirebaseService.shared.teamMembersListener() {
                    self.coreTeam = updatedMembers.filter { $0.type == .core }
                    self.advisoryBoard = updatedMembers.filter { $0.type == .advisory }
                    if self.isLoading {
                        self.isLoading = false
                    }
                    // Clear any previous errors on successful data fetch
                    self.error = nil
                }
            } catch {
                self.isLoading = false
                self.error = error
                print("Error listening for team members: \(error.localizedDescription)")
            }
        }
    }
    
    func selectTeamType(_ teamType: TeamType) {
        selectedTeamType = teamType
    }
    
    func retry() {
        listenForTeamMembers()
    }
    
    // MARK: - Helper Methods
    func getTeamMember(byId id: String) -> TeamMember? {
        let allMembers = coreTeam + advisoryBoard
        return allMembers.first { $0.id == id }
    }
    
    func getTeamMember(byName name: String) -> TeamMember? {
        let allMembers = coreTeam + advisoryBoard
        return allMembers.first { $0.name == name }
    }
    
    func getCoreTeamCount() -> Int {
        coreTeam.count
    }
    
    func getAdvisoryBoardCount() -> Int {
        advisoryBoard.count
    }
    
    func getTotalTeamCount() -> Int {
        coreTeam.count + advisoryBoard.count
    }
    
    // MARK: - Contact Actions
    func openEmail(for member: TeamMember) {
        guard !member.email.isEmpty,
              let url = URL(string: "mailto:\(member.email)") else { return }
        UIApplication.shared.open(url)
    }
    
    func openPhone(for member: TeamMember) {
        guard let phone = member.phone,
              !phone.isEmpty,
              let url = URL(string: "tel://\(phone)") else { return }
        UIApplication.shared.open(url)
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