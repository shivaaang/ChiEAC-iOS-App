//
//  AppData.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - Support Mission Page Models
struct SupportMissionContent: Decodable {
    let headerTitle: String
    let mission: MissionCopy
    let impactNumbers: [ImpactNumberContent]
    let donationLevelsHeading: String
    let donationLevels: [DonationLevelContent]
    let longTermSolutions: SectionWithParagraphs
    let whyChiEAC: SectionWithParagraphs
    let cta: SupportCTAContent
}

struct MissionCopy: Decodable {
    let intro: String
    let support: String
    let change: String
}

struct ImpactNumberContent: Decodable, Identifiable {
    var id: String { number + label }
    let number: String
    let label: String
    let subtitle: String
    let icon: String
}

struct DonationLevelContent: Decodable, Identifiable {
    var id: String { amount + title }
    let icon: String
    let amount: String
    let title: String
    let description: String
}

struct SectionWithParagraphs: Decodable {
    let title: String
    let paragraphs: [String]
}

struct SupportCTAContent: Decodable {
    let headline: String
    let subheadline: String
    let buttonLabel: String
    let reassuranceText: String
    let badges: [SupportCTABadge]
}

struct SupportCTABadge: Decodable, Identifiable {
    var id: String { label }
    let emoji: String
    let label: String
}


// MARK: - Core Work Data
struct CoreWork: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let order: Int
}

// CoreWorkData - No longer needed as data comes from Firebase
// All core work data is now managed in Firebase Firestore

// MARK: - Program Data (Updated Structure)
struct ProgramInfo: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let benefits: [String]
    let impact: [String]
    let icon: String
    let contactEmail: String
    let order: Int

    // Convenience initializer for testing and local data
    init(id: String, title: String, subtitle: String, description: String, benefits: [String], impact: [String], icon: String, contactEmail: String, order: Int = 0) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.benefits = benefits
        self.impact = impact
        self.icon = icon
        self.contactEmail = contactEmail
        self.order = order
    }
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
    let order: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name = "team_name"
        case code = "team_code"
        case description = "team_description"
        case order
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
    let order: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name = "member_name"
        case title = "member_title"
        case bio = "member_summary"
        case bioShort = "member_summary_short"
        case team = "member_team"
        case imageURL = "member_image_link"
        case order
    }

    // Convenience initializer for testing and local data
    init(id: String, name: String, title: String, bio: String, bioShort: String? = nil, team: TeamCode, imageURL: String? = nil, order: Int = 0) {
        self.id = id
        self.name = name
        self.title = title
        self.bio = bio
        self.bioShort = bioShort
        self.team = team
        self.imageURL = imageURL
        self.order = order
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
    let order: Int
}

// MARK: - Organization Info Model
struct OrganizationInfo: Codable, Identifiable {
    let id: String
    let mission: String
    let description: String
    let tagline: String
    let contactEmail: String

    // Convenience initializer for testing and local data
    init(id: String, mission: String, description: String, tagline: String, contactEmail: String) {
        self.id = id
        self.mission = mission
        self.description = description
        self.tagline = tagline
        self.contactEmail = contactEmail
    }
}

// MARK: - Articles
struct Article: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let mediumLink: String
    let imageLink: String
    let articleTags: [String]
    let publishedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case mediumLink = "medium_link"
        case imageLink = "image_link"
        case articleTags = "article_tags"
        case publishedAt = "published_at"
    }

    // Custom decoding to parse Firestore Timestamps and ISO8601 dates
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(String.self, forKey: .id)
        self.title = try c.decode(String.self, forKey: .title)
        self.mediumLink = try c.decode(String.self, forKey: .mediumLink)
        self.imageLink = try c.decode(String.self, forKey: .imageLink)
        self.articleTags = try c.decode([String].self, forKey: .articleTags)
        
        // Handle both Firestore Timestamp and String dates
        if let timestamp = try? c.decode(Timestamp.self, forKey: .publishedAt) {
            // Firestore Timestamp
            self.publishedAt = timestamp.dateValue()
        } else if let dateString = try? c.decode(String.self, forKey: .publishedAt) {
            // String date (from JSON)
            self.publishedAt = Article.iso8601Formatter.date(from: dateString) ?? Article.fallbackFormatter.date(from: dateString)
        } else {
            self.publishedAt = nil
        }
    }

    // Convenience initializer for testing and previews
    init(id: String, title: String, mediumLink: String, imageLink: String, articleTags: [String], publishedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.mediumLink = mediumLink
        self.imageLink = imageLink
        self.articleTags = articleTags
        self.publishedAt = publishedAt
    }
    
    // Date formatters
    private static let iso8601Formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX" // handles Z / offset
        return f
    }()
    private static let fallbackFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd" // fallback simple date
        return f
    }()
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

