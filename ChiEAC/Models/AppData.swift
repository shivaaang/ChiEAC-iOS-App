//
//  AppData.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import Foundation
import SwiftUI

// MARK: - Core Work Data
struct CoreWork: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
}

// CoreWorkData - No longer needed as data comes from Firebase
// All core work data is now managed in Firebase Firestore

// MARK: - Program Data (Updated Structure)
struct ProgramInfo: Identifiable, Codable {
    var id: String?
    let title: String
    let subtitle: String
    let description: String
    let benefits: [String]
    let impact: [String]
    let icon: String
    let contactEmail: String
}

// ProgramData - No longer needed as data comes from Firebase
// All program data is now managed in Firebase Firestore

// MARK: - Team Data (revamped)
enum TeamCode: String, Codable, CaseIterable {
    case coreTeam = "core_team"
    case advisoryBoard = "advisory_board"

    // Be lenient with alternative spellings that may appear in content
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = (try? container.decode(String.self)) ?? "core_team"
        switch raw {
        case "core_team": self = .coreTeam
        case "advisory_board", "advisory_team": self = .advisoryBoard
        default: self = .coreTeam
        }
    }

    func displayName() -> String {
        switch self {
        case .coreTeam: return "Core Team"
        case .advisoryBoard: return "Advisory Board"
        }
    }
}

struct Team: Identifiable, Codable {
    let id: String
    let name: String
    let code: TeamCode
    let description: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "team_name"
        case code = "team_code"
        case description = "team_description"
    }
}

struct TeamMember: Identifiable, Codable {
    let id: String
    let name: String
    let title: String
    let bio: String
    let bioShort: String?
    let team: TeamCode
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name = "member_name"
        case title = "member_title"
        case bio = "member_summary"
        case bioShort = "member_summary_short"
        case team = "member_team"
        case imageURL = "member_image_link"
    }

    // Custom decoding to support deterministic ids and legacy payloads
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let name = (try? c.decode(String.self, forKey: .name)) ?? ""
        let title = (try? c.decode(String.self, forKey: .title)) ?? ""
        let bio = (try? c.decode(String.self, forKey: .bio)) ?? ""
        let bioShort = try? c.decode(String.self, forKey: .bioShort)
        let team = (try? c.decode(TeamCode.self, forKey: .team)) ?? .coreTeam
        let imageURL = try? c.decode(String.self, forKey: .imageURL)

        // Deterministic id: use provided id or generate from team+name slug
        if let provided = try? c.decode(String.self, forKey: .id), !provided.isEmpty {
            self.id = provided
        } else {
            self.id = TeamMember.makeSlugId(team: team, name: name)
        }
        self.name = name
        self.title = title
        self.bio = bio
        self.bioShort = bioShort
        self.team = team
        self.imageURL = imageURL
    }

    static func makeSlugId(team: TeamCode, name: String) -> String {
        let ns = name.lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "_", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        return "member.\(team.rawValue).\(ns)"
    }

    // Memberwise initializer for convenience (e.g., fallbacks, previews)
    init(id: String, name: String, title: String, bio: String, bioShort: String? = nil, team: TeamCode, imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.title = title
        self.bio = bio
        self.bioShort = bioShort
        self.team = team
        self.imageURL = imageURL
    }
}

// TeamData - No longer needed as data comes from Firebase
// All team member data is now managed in Firebase Firestore

// OrganizationData - No longer needed as data comes from Firebase
// All organization data including impact stats is now managed in Firebase Firestore

struct ImpactStat: Identifiable, Codable {
    let id: String
    let number: String
    let label: String
    let subtitle: String
    let icon: String
}

// MARK: - Organization Info Model
struct OrganizationInfo: Codable, Identifiable {
    var id: String?
    let mission: String
    let description: String
    let tagline: String
    let contactEmail: String
}

// MARK: - Articles
struct Article: Identifiable, Codable, Equatable {
    var id: String?
    let title: String
    let mediumLink: String
    let imageLink: String
    let articleTags: [String]
    
    enum CodingKeys: String, CodingKey {
        case title
        case mediumLink = "medium_link"
        case imageLink = "image_link"
        case articleTags = "article_tags"
    }
}


// MARK: - External Links
struct ExternalLink: Identifiable, Codable {
    let id: String
    let name: String
    let address: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "link_name"
        case address = "link_address"
    }
}

