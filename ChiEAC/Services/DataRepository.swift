//
//  DataRepository.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/15/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Server Fetch Wrapper
struct ServerFetch<T> {
    let value: T
    let fromServer: Bool
}

/// Async data repository protocol that supports both local and remote data sources
protocol AsyncDataRepository {
    // MARK: - Programs
    func loadPrograms() async throws -> [ProgramInfo]
    
    // MARK: - Teams
    func loadTeams() async throws -> [Team]
    func loadTeamMembers() async throws -> [TeamMember]
    
    // MARK: - Articles
    func loadArticles() async throws -> [Article]
    
    // MARK: - Home Content
    func loadCoreWork() async throws -> [CoreWork]
    func loadImpactStats() async throws -> [ImpactStat]
    func loadOrganizationInfo() async throws -> OrganizationInfo?
    func loadSupportMissionContent() async throws -> SupportMissionContent?
    
    // MARK: - External Links
    func loadExternalLinks() async throws -> [ExternalLink]
    
    // MARK: - Contact Form
    func submitContactForm(_ submission: ContactFormSubmission) async throws
}

/// Additional protocol for Firestore-specific cache operations
protocol FirestoreRepositoryProtocol: AsyncDataRepository {
    func loadOrganizationInfoFromCache() async throws -> OrganizationInfo?
    func loadArticlesFromCache() async throws -> [Article]
    func loadCoreWorkFromCache() async throws -> [CoreWork]
    func loadImpactStatsFromCache() async throws -> [ImpactStat]
    func loadProgramsFromCache() async throws -> [ProgramInfo]
    func loadTeamsFromCache() async throws -> [Team]
    func loadTeamMembersFromCache() async throws -> [TeamMember]
    
    // MARK: - Server Detection Methods
    func loadPrimaryFromServer() async throws -> (
        org: ServerFetch<OrganizationInfo?>,
        articles: ServerFetch<[Article]>,
        core: ServerFetch<[CoreWork]>,
        impact: ServerFetch<[ImpactStat]>
    )
    func loadPrimaryFromCache() async throws -> (
        org: OrganizationInfo?,
        articles: [Article],
        core: [CoreWork],
        impact: [ImpactStat]
    )
}

/// Firestore-backed implementation of AsyncDataRepository
class FirestoreRepository: AsyncDataRepository, FirestoreRepositoryProtocol {
    private let db: Firestore
    
    static let shared = FirestoreRepository()
    
    private init() {
        let settings = Firestore.firestore().settings
        
        // Configure cache settings for better offline performance
        let cacheSettings = PersistentCacheSettings(
            sizeBytes: NSNumber(value: FirestoreCacheSizeUnlimited)
        )
        settings.cacheSettings = cacheSettings
        
        // Reduce timeout for faster offline detection
        settings.dispatchQueue = DispatchQueue.global(qos: .userInitiated)
        
        Firestore.firestore().settings = settings
        
        // Use default database
        db = Firestore.firestore()
    }
    
    // MARK: - Primary Data Loading with Server Detection
    func loadPrimaryFromServer() async throws -> (
        org: ServerFetch<OrganizationInfo?>,
        articles: ServerFetch<[Article]>,
        core: ServerFetch<[CoreWork]>,
        impact: ServerFetch<[ImpactStat]>
    ) {
        async let org = loadOrganizationInfoFromServer()
        async let arts = loadArticlesFromServer()
        async let core = loadCoreWorkFromServer()
        async let impact = loadImpactStatsFromServer()
        
        return try await (org: org, articles: arts, core: core, impact: impact)
    }
    
    func loadPrimaryFromCache() async throws -> (
        org: OrganizationInfo?,
        articles: [Article],
        core: [CoreWork],
        impact: [ImpactStat]
    ) {
        async let org = loadOrganizationInfoFromCache()
        async let arts = loadArticlesFromCache()
        async let core = loadCoreWorkFromCache()
        async let impact = loadImpactStatsFromCache()
        
        return try await (org: org, articles: arts, core: core, impact: impact)
    }
    
    // MARK: - Server-Only Fetch Methods
    private func loadOrganizationInfoFromServer() async throws -> ServerFetch<OrganizationInfo?> {
        do {
            let snapshot = try await db.collection("organization_info")
                .document("main")
                .getDocument(source: .server)
            
            let fromServer = !snapshot.metadata.isFromCache
            
            guard snapshot.exists else {
                return ServerFetch(value: nil, fromServer: fromServer)
            }
            
            let orgInfo = try snapshot.data(as: OrganizationInfo.self)
            return ServerFetch(value: orgInfo, fromServer: fromServer)
            
        } catch {
            // Check if it's an offline error
            if isOfflineError(error) {
                // Try to get from cache as fallback
                let cached = try? await loadOrganizationInfoFromCache()
                return ServerFetch(value: cached, fromServer: false)
            }
            throw error
        }
    }
    
    private func loadArticlesFromServer() async throws -> ServerFetch<[Article]> {
        do {
            let snapshot = try await db.collection("articles")
                .order(by: "published_at", descending: true)
                .getDocuments(source: .server)
            
            let fromServer = !snapshot.metadata.isFromCache
            let articles = snapshot.documents.compactMap { document in
                do {
                    return try document.data(as: Article.self)
                } catch {
                    print("Warning: Failed to decode Article document \(document.documentID): \(error)")
                    return nil
                }
            }
            
            return ServerFetch(value: articles, fromServer: fromServer)
            
        } catch {
            if isOfflineError(error) {
                let cached = try await loadArticlesFromCache()
                return ServerFetch(value: cached, fromServer: false)
            }
            throw error
        }
    }
    
    private func loadCoreWorkFromServer() async throws -> ServerFetch<[CoreWork]> {
        do {
            let snapshot = try await db.collection("core_work")
                .getDocuments(source: .server)
            
            let fromServer = !snapshot.metadata.isFromCache
            let coreWork = snapshot.documents.compactMap { document in
                do {
                    return try document.data(as: CoreWork.self)
                } catch {
                    print("Warning: Failed to decode CoreWork document \(document.documentID): \(error)")
                    return nil
                }
            }
            
            return ServerFetch(value: coreWork.sorted { $0.order < $1.order }, fromServer: fromServer)
            
        } catch {
            if isOfflineError(error) {
                let cached = try await loadCoreWorkFromCache()
                return ServerFetch(value: cached, fromServer: false)
            }
            throw error
        }
    }
    
    private func loadImpactStatsFromServer() async throws -> ServerFetch<[ImpactStat]> {
        do {
            let snapshot = try await db.collection("impact_stats")
                .getDocuments(source: .server)
            
            let fromServer = !snapshot.metadata.isFromCache
            let stats = snapshot.documents.compactMap { document in
                do {
                    return try document.data(as: ImpactStat.self)
                } catch {
                    print("Warning: Failed to decode ImpactStat document \(document.documentID): \(error)")
                    return nil
                }
            }
            
            return ServerFetch(value: stats.sorted { $0.order < $1.order }, fromServer: fromServer)
            
        } catch {
            if isOfflineError(error) {
                let cached = try await loadImpactStatsFromCache()
                return ServerFetch(value: cached, fromServer: false)
            }
            throw error
        }
    }
    
    // MARK: - Programs
    func loadPrograms() async throws -> [ProgramInfo] {
        let snapshot = try await db.collection("programs").getDocuments()
        let programs = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: ProgramInfo.self)
            } catch {
                print("Warning: Failed to decode ProgramInfo document \(document.documentID): \(error)")
                return nil
            }
        }
        return programs.sorted { $0.order < $1.order }
    }
    
    // MARK: - Teams
    func loadTeams() async throws -> [Team] {
        let snapshot = try await db.collection("teams").getDocuments()
        let teams = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Team.self)
            } catch {
                print("Warning: Failed to decode Team document \(document.documentID): \(error)")
                return nil
            }
        }
        return teams.sorted { $0.order < $1.order }
    }

    func loadTeamMembers() async throws -> [TeamMember] {
        let snapshot = try await db.collection("team_members").getDocuments()
        let teamMembers = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: TeamMember.self)
            } catch {
                print("Warning: Failed to decode TeamMember document \(document.documentID): \(error)")
                return nil
            }
        }
        // Sort by team first, then by order within each team
        return teamMembers.sorted { 
            if $0.team != $1.team {
                // Sort teams by their natural order (core_team first, then advisory_board)
                return $0.team < $1.team
            }
            return $0.order < $1.order
        }
    }
    
    // MARK: - Articles
    func loadArticles() async throws -> [Article] {
        let snapshot = try await db.collection("articles")
            .order(by: "published_at", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Article.self)
            } catch {
                print("Warning: Failed to decode Article document \(document.documentID): \(error)")
                return nil
            }
        }
    }
    
    // MARK: - Home Content
    func loadCoreWork() async throws -> [CoreWork] {
        let snapshot = try await db.collection("core_work").getDocuments()
        let coreWork = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: CoreWork.self)
            } catch {
                print("Warning: Failed to decode CoreWork document \(document.documentID): \(error)")
                return nil
            }
        }
        return coreWork.sorted { $0.order < $1.order }
    }

    func loadImpactStats() async throws -> [ImpactStat] {
        let snapshot = try await db.collection("impact_stats").getDocuments()
        let impactStats = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: ImpactStat.self)
            } catch {
                print("Warning: Failed to decode ImpactStat document \(document.documentID): \(error)")
                return nil
            }
        }
        return impactStats.sorted { $0.order < $1.order }
    }

    func loadOrganizationInfo() async throws -> OrganizationInfo? {
        let snapshot = try await db.collection("organization_info").document("main").getDocument()
        do {
            return try snapshot.data(as: OrganizationInfo.self)
        } catch {
            print("Warning: Failed to decode OrganizationInfo: \(error)")
            return nil
        }
    }
    
    func loadSupportMissionContent() async throws -> SupportMissionContent? {
        let snapshot = try await db.collection("support_mission").document("main").getDocument()
        do {
            return try snapshot.data(as: SupportMissionContent.self)
        } catch {
            print("Warning: Failed to decode SupportMissionContent: \(error)")
            return nil
        }
    }
    
    // MARK: - External Links
    func loadExternalLinks() async throws -> [ExternalLink] {
        let snapshot = try await db.collection("external_links").getDocuments()
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: ExternalLink.self)
            } catch {
                print("Warning: Failed to decode ExternalLink document \(document.documentID): \(error)")
                return nil
            }
        }
    }
    
    // MARK: - Contact Form
    func submitContactForm(_ submission: ContactFormSubmission) async throws {
        // Use auto-generated document ID instead of submission.id
        let docRef = db.collection("contact_form_submissions").document()
        
        // Create submission data without the id field (Firestore will auto-generate)
        let submissionData: [String: Any] = [
            "firstName": submission.firstName,
            "lastName": submission.lastName,
            "email": submission.email,
            "phone": submission.phone,
            "message": submission.message,
            "source": submission.source,
            "submittedAt": submission.submittedAt
        ]
        
        try await docRef.setData(submissionData)
    }
    
    // MARK: - Cache-Only Methods
    func loadOrganizationInfoFromCache() async throws -> OrganizationInfo? {
        let snapshot = try await db.collection("organization_info").document("main").getDocument(source: .cache)
        guard snapshot.exists else { return nil }
        do {
            return try snapshot.data(as: OrganizationInfo.self)
        } catch {
            print("Warning: Failed to decode cached OrganizationInfo: \(error)")
            return nil
        }
    }
    
    func loadArticlesFromCache() async throws -> [Article] {
        let snapshot = try await db.collection("articles")
            .order(by: "published_at", descending: true)
            .getDocuments(source: .cache)
        return snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Article.self)
            } catch {
                print("Warning: Failed to decode cached Article document \(document.documentID): \(error)")
                return nil
            }
        }
    }
    
    func loadCoreWorkFromCache() async throws -> [CoreWork] {
        let snapshot = try await db.collection("core_work").getDocuments(source: .cache)
        let coreWork = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: CoreWork.self)
            } catch {
                print("Warning: Failed to decode cached CoreWork document \(document.documentID): \(error)")
                return nil
            }
        }
        return coreWork.sorted { $0.order < $1.order }
    }
    
    func loadImpactStatsFromCache() async throws -> [ImpactStat] {
        let snapshot = try await db.collection("impact_stats").getDocuments(source: .cache)
        let impactStats = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: ImpactStat.self)
            } catch {
                print("Warning: Failed to decode cached ImpactStat document \(document.documentID): \(error)")
                return nil
            }
        }
        return impactStats.sorted { $0.order < $1.order }
    }
    
    func loadProgramsFromCache() async throws -> [ProgramInfo] {
        let snapshot = try await db.collection("programs").getDocuments(source: .cache)
        let programs = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: ProgramInfo.self)
            } catch {
                print("Warning: Failed to decode cached ProgramInfo document \(document.documentID): \(error)")
                return nil
            }
        }
        return programs.sorted { $0.order < $1.order }
    }
    
    func loadTeamsFromCache() async throws -> [Team] {
        let snapshot = try await db.collection("teams").getDocuments(source: .cache)
        let teams = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Team.self)
            } catch {
                print("Warning: Failed to decode cached Team document \(document.documentID): \(error)")
                return nil
            }
        }
        return teams.sorted { $0.order < $1.order }
    }
    
    func loadTeamMembersFromCache() async throws -> [TeamMember] {
        let snapshot = try await db.collection("team_members").getDocuments(source: .cache)
        let teamMembers = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: TeamMember.self)
            } catch {
                print("Warning: Failed to decode cached TeamMember document \(document.documentID): \(error)")
                return nil
            }
        }
        return teamMembers.sorted { 
            if $0.team != $1.team {
                return $0.team < $1.team
            }
            return $0.order < $1.order
        }
    }
    
    // MARK: - Error Handling
    private func isOfflineError(_ error: Error) -> Bool {
        if let err = error as NSError?,
           err.domain == FirestoreErrorDomain,
           let code = FirestoreErrorCode.Code(rawValue: err.code),
           code == .unavailable {
            return true
        }
        return false
    }
}