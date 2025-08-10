
//
//  FirebaseService.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Firebase-specific Error Types
enum FirebaseError: LocalizedError {
    case noNetworkConnection
    case permissionDenied
    case documentNotFound
    case quotaExceeded
    case dataCorrupted
    case serviceUnavailable
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .noNetworkConnection:
            return "No internet connection. Data will sync when connection is restored."
        case .permissionDenied:
            return "Unable to access data. Please check your permissions."
        case .documentNotFound:
            return "The requested information could not be found."
        case .quotaExceeded:
            return "Service temporarily unavailable. Please try again later."
        case .dataCorrupted:
            return "Data format error. Please update the app to the latest version."
        case .serviceUnavailable:
            return "Service temporarily unavailable. Please try again later."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoveryAction: String {
        switch self {
        case .noNetworkConnection:
            return "Check your internet connection and try again."
        case .permissionDenied:
            return "Contact support if this issue persists."
        case .documentNotFound:
            return "This content may have been moved or deleted."
        case .quotaExceeded, .serviceUnavailable:
            return "Please try again in a few minutes."
        case .dataCorrupted:
            return "Update your app from the App Store."
        case .unknown:
            return "Please try again or contact support."
        }
    }
}

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    
    // Connection state tracking
    @Published var isOnline = false
    @Published var connectionError: FirebaseError?
    
    private init() {
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        db.settings = settings
        print("Firestore offline persistence enabled.")
        
        // Monitor connection state
        monitorConnection()
    }
    
    private func monitorConnection() {
        // Simple connection monitoring - you could enhance this
        // For now, we assume online unless we get network errors
        isOnline = true
    }
    
    private func handleFirestoreError(_ error: Error) -> FirebaseError {
        let nsError = error as NSError
        
        switch nsError.code {
        case FirestoreErrorCode.unavailable.rawValue:
            return .noNetworkConnection
        case FirestoreErrorCode.permissionDenied.rawValue:
            return .permissionDenied
        case FirestoreErrorCode.notFound.rawValue:
            return .documentNotFound
        case FirestoreErrorCode.resourceExhausted.rawValue:
            return .quotaExceeded
        case FirestoreErrorCode.dataLoss.rawValue, FirestoreErrorCode.invalidArgument.rawValue:
            return .dataCorrupted
        case FirestoreErrorCode.internal.rawValue, FirestoreErrorCode.unknown.rawValue:
            return .serviceUnavailable
        default:
            return .unknown(error)
        }
    }
    
    // MARK: - Listener for Programs
    func programsListener() -> AsyncThrowingStream<[ProgramInfo], Error> {
        return AsyncThrowingStream { continuation in
            let listener = db.collection("programs").addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    let firebaseError = self?.handleFirestoreError(error) ?? .unknown(error)
                    self?.connectionError = firebaseError
                    continuation.finish(throwing: firebaseError)
                    return
                }
                
                guard let snapshot = querySnapshot else {
                    let unknownError = FirebaseError.unknown(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error fetching programs"]))
                    self?.connectionError = unknownError
                    continuation.finish(throwing: unknownError)
                    return
                }
                
                do {
                    let programs = try snapshot.documents.compactMap { document -> ProgramInfo? in
                        return try document.data(as: ProgramInfo.self)
                    }
                    
                    // Clear any previous errors on successful data fetch
                    self?.connectionError = nil
                    self?.isOnline = true
                    continuation.yield(programs)
                } catch {
                    let dataError = FirebaseError.dataCorrupted
                    self?.connectionError = dataError
                    continuation.finish(throwing: dataError)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    // MARK: - Listener for Team Members
    func teamMembersListener() -> AsyncThrowingStream<[TeamMember], Error> {
        return AsyncThrowingStream { continuation in
            let listener = db.collection("teamMembers").addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    let firebaseError = self?.handleFirestoreError(error) ?? .unknown(error)
                    self?.connectionError = firebaseError
                    continuation.finish(throwing: firebaseError)
                    return
                }
                
                guard let snapshot = querySnapshot else {
                    let unknownError = FirebaseError.unknown(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error fetching team members"]))
                    self?.connectionError = unknownError
                    continuation.finish(throwing: unknownError)
                    return
                }
                
                do {
                    let members = try snapshot.documents.compactMap { document -> TeamMember? in
                        return try document.data(as: TeamMember.self)
                    }
                    
                    self?.connectionError = nil
                    self?.isOnline = true
                    continuation.yield(members)
                } catch {
                    let dataError = FirebaseError.dataCorrupted
                    self?.connectionError = dataError
                    continuation.finish(throwing: dataError)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    // MARK: - Listener for Core Work
    func coreWorkListener() -> AsyncThrowingStream<[CoreWork], Error> {
        return AsyncThrowingStream { continuation in
            let listener = db.collection("coreWork").addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    let firebaseError = self?.handleFirestoreError(error) ?? .unknown(error)
                    self?.connectionError = firebaseError
                    continuation.finish(throwing: firebaseError)
                    return
                }
                
                guard let snapshot = querySnapshot else {
                    let unknownError = FirebaseError.unknown(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error fetching core work"]))
                    self?.connectionError = unknownError
                    continuation.finish(throwing: unknownError)
                    return
                }
                
                do {
                    let workItems = try snapshot.documents.compactMap { document -> CoreWork? in
                        return try document.data(as: CoreWork.self)
                    }
                    
                    self?.connectionError = nil
                    self?.isOnline = true
                    continuation.yield(workItems)
                } catch {
                    let dataError = FirebaseError.dataCorrupted
                    self?.connectionError = dataError
                    continuation.finish(throwing: dataError)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    // MARK: - Listener for Impact Stats
    func impactStatsListener() -> AsyncThrowingStream<[ImpactStat], Error> {
        return AsyncThrowingStream { continuation in
            let listener = db.collection("impactStats").addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    let firebaseError = self?.handleFirestoreError(error) ?? .unknown(error)
                    self?.connectionError = firebaseError
                    continuation.finish(throwing: firebaseError)
                    return
                }
                
                guard let snapshot = querySnapshot else {
                    let unknownError = FirebaseError.unknown(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error fetching impact stats"]))
                    self?.connectionError = unknownError
                    continuation.finish(throwing: unknownError)
                    return
                }
                
                do {
                    let stats = try snapshot.documents.compactMap { document -> ImpactStat? in
                        return try document.data(as: ImpactStat.self)
                    }
                    
                    self?.connectionError = nil
                    self?.isOnline = true
                    continuation.yield(stats)
                } catch {
                    let dataError = FirebaseError.dataCorrupted
                    self?.connectionError = dataError
                    continuation.finish(throwing: dataError)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    // MARK: - Listener for Organization Info (Single Document)
    func organizationInfoListener() -> AsyncThrowingStream<OrganizationInfo?, Error> {
        return AsyncThrowingStream { continuation in
            let listener = db.collection("organizationInfo").document("main").addSnapshotListener { [weak self] documentSnapshot, error in
                if let error = error {
                    let firebaseError = self?.handleFirestoreError(error) ?? .unknown(error)
                    self?.connectionError = firebaseError
                    continuation.finish(throwing: firebaseError)
                    return
                }
                
                guard let snapshot = documentSnapshot else {
                    let unknownError = FirebaseError.unknown(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error fetching organization info"]))
                    self?.connectionError = unknownError
                    continuation.finish(throwing: unknownError)
                    return
                }
                
                do {
                    let orgInfo = try snapshot.data(as: OrganizationInfo.self)
                    self?.connectionError = nil
                    self?.isOnline = true
                    continuation.yield(orgInfo)
                } catch {
                    let dataError = FirebaseError.dataCorrupted
                    self?.connectionError = dataError
                    continuation.finish(throwing: dataError)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    // MARK: - Batch Operations
    func fetchAllDataOnce() async throws -> (programs: [ProgramInfo], team: [TeamMember], coreWork: [CoreWork], impactStats: [ImpactStat], organizationInfo: OrganizationInfo?) {
        async let programs = try await db.collection("programs").getDocuments().documents.compactMap { try $0.data(as: ProgramInfo.self) }
        async let team = try await db.collection("teamMembers").getDocuments().documents.compactMap { try $0.data(as: TeamMember.self) }
        async let coreWork = try await db.collection("coreWork").getDocuments().documents.compactMap { try $0.data(as: CoreWork.self) }
        async let impactStats = try await db.collection("impactStats").getDocuments().documents.compactMap { try $0.data(as: ImpactStat.self) }
        async let organizationInfo = try? await db.collection("organizationInfo").document("main").getDocument().data(as: OrganizationInfo.self)
        
        return try await (programs, team, coreWork, impactStats, organizationInfo)
    }
}


