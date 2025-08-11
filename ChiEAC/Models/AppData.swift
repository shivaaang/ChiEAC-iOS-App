
//
//  AppData.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - Core Work Data
struct CoreWork: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let icon: String
    let colorHex: String
    
    var color: Color {
        Color(hex: colorHex)
    }
}

// CoreWorkData - No longer needed as data comes from Firebase
// All core work data is now managed in Firebase Firestore

// MARK: - Program Data (Updated Structure)
struct ProgramInfo: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let subtitle: String
    let description: String
    let benefits: [String]
    let impact: [String]
    let icon: String
    let colorHex: String
    let contactEmail: String
    
    var color: Color {
        Color(hex: colorHex)
    }
}

// ProgramData - No longer needed as data comes from Firebase
// All program data is now managed in Firebase Firestore

// MARK: - Team Data
struct TeamMember: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let title: String
    let bio: String
    let email: String
    let phone: String?
    let type: TeamType
    let imageURL: String? // New: URL for team member photo
}

enum TeamType: String, Codable, CaseIterable {
    case core = "Core Team"
    case advisory = "Advisory Board"
}

// TeamData - No longer needed as data comes from Firebase
// All team member data is now managed in Firebase Firestore

// OrganizationData - No longer needed as data comes from Firebase
// All organization data including impact stats is now managed in Firebase Firestore

struct ImpactStat: Identifiable, Codable {
    @DocumentID var id: String?
    let number: String
    let label: String
}

// MARK: - Organization Info Model
struct OrganizationInfo: Codable, Identifiable {
    @DocumentID var id: String?
    let mission: String
    let description: String
    let tagline: String
    let contactEmail: String
    let contactPhone: String
}

// MARK: - Articles
struct Article: Identifiable, Codable {
    @DocumentID var id: String?
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

extension Article {
    static let seedData: [Article] = [
        Article(
            id: nil,
            title: "Who Gets to Use? What High School Taught Me About Privilege and Drugs",
            mediumLink: "https://medium.com/age-of-awareness/who-gets-to-use-what-high-school-taught-me-about-privilege-and-drugs-be5d26d5beeb",
            imageLink: "https://miro.medium.com/v2/resize:fit:640/format:webp/1*GXmiU7Al2j2lSfCYAUJoeg.jpeg",
            articleTags: ["Social Justice", "Education Equity", "Identity & Culture"]
        ),
        Article(
            id: nil,
            title: "My Mental Health Isn't Invisible to Me. So Why Do Others Look Right Through It?",
            mediumLink: "https://chieac.medium.com/my-mental-health-isnt-invisible-to-me-so-why-do-others-look-right-through-it-225180fbc714",
            imageLink: "https://miro.medium.com/v2/resize:fill:640:427/1*HvFgtA_QwCep68Cj8DrJuw.jpeg",
            articleTags: ["Mental Health", "Social Justice", "Identity & Culture"]
        ),
        Article(
            id: nil,
            title: "What Community Organizations Teach Us About Real Power and Real Limits",
            mediumLink: "https://chieac.medium.com/what-community-organizations-teach-us-about-real-power-and-real-limits-05870525d93b",
            imageLink: "https://miro.medium.com/v2/resize:fill:640:427/1*l07UMr8pvxPErYXjSlCuLQ.jpeg",
            articleTags: ["Social Justice", "Education Equity", "Immigration & Community"]
        ),
        Article(
            id: nil,
            title: "What Students Learned About Trust and Advocacy as Relational Processes by Showing Up and Staying…",
            mediumLink: "https://chieac.medium.com/what-students-learned-about-trust-and-advocacy-as-relational-processes-by-showing-up-and-staying-e37541a8d56d",
            imageLink: "https://miro.medium.com/v2/resize:fill:640:427/1*2Zwvf1csQvo_fXVpoXCeDQ.jpeg",
            articleTags: ["Education Equity", "Social Justice", "Higher Ed Life"]
        ),
        Article(
            id: nil,
            title: "Structural Barriers for Migrant Families, Public Schools, and their Fight for Opportunity",
            mediumLink: "https://chieac.medium.com/structural-barriers-for-migrant-families-public-schools-and-their-fight-for-opportunity-932c21aa0af4",
            imageLink: "https://miro.medium.com/v2/resize:fill:640:427/1*hNCm2o_SAOSlrKOnjYt_uw.jpeg",
            articleTags: ["Education Equity", "Immigration & Community", "Social Justice"]
        ),
        Article(
            id: nil,
            title: "Immigrant Kids in Chicago Carry More Than Books…They Carry Their Families",
            mediumLink: "https://chieac.medium.com/immigrant-kids-in-chicago-carry-more-than-books-they-carry-their-families-3605741a86f8",
            imageLink: "https://miro.medium.com/v2/resize:fill:640:427/1*e1GP7v2x-yt21b0p7byvvQ.jpeg",
            articleTags: ["Immigration & Community", "Education Equity", "Identity & Culture"]
        ),
        Article(
            id: nil,
            title: "What the Media Taught Me About Who Uses Drugs, Who Commits Crime, and Who Stays Poor",
            mediumLink: "https://chieac.medium.com/what-the-media-taught-me-about-who-uses-drugs-who-commits-crime-and-who-stays-poor-f00ea1148c59",
            imageLink: "https://miro.medium.com/v2/resize:fill:640:427/1*P7PoL7znBF_iRZWmQgeYSA.jpeg",
            articleTags: ["Social Justice", "Identity & Culture", "Economic Justice"]
        ),
        Article(
            id: nil,
            title: "My Mom Was Doing Two Jobs…I Only Noticed One",
            mediumLink: "https://chieac.medium.com/my-mom-was-doing-two-jobs-i-only-noticed-one-73f10a91c52b",
            imageLink: "https://miro.medium.com/v2/resize:fill:640:427/1*ekHkUHDEdPsQxRYw5aPW5w.jpeg",
            articleTags: ["Economic Justice", "Identity & Culture", "Social Justice"]
        ),
        Article(
            id: nil,
            title: "I Argued with My Grandfather About Politics Before I Even Knew What Politics Meant",
            mediumLink: "https://chieac.medium.com/i-argued-with-my-grandfather-about-politics-before-i-even-knew-what-politics-meant-531af26f9f80",
            imageLink: "https://miro.medium.com/v2/resize:fill:640:427/1*9lmHUaU2v09jjXTHESjI5A.jpeg",
            articleTags: ["Identity & Culture", "Social Justice"]
        ),
        Article(
            id: nil,
            title: "Coming Back to What I Once Ignored",
            mediumLink: "https://chieac.medium.com/coming-back-to-what-i-once-ignored-94bf1028065f",
            imageLink: "https://miro.medium.com/v2/resize:fill:640:427/1*0YhtRLjfOWm5YlSCqnJbDg.jpeg",
            articleTags: ["Identity & Culture", "Higher Ed Life"]
        )
    ]
}

