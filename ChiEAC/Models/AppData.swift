
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

