//
//  AppDataManager.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/15/25.
//

import Foundation
import SwiftUI
import Combine
import Network

// MARK: - Connection State
enum ConnectionState {
    case initial                    // App just launched, checking cache
    case loadingWithCache          // Has cache, trying to connect
    case loadingWithoutCache       // No cache, must connect
    case connected                 // Successfully connected to server
    case offline                   // Failed to connect
    case retrying                  // User triggered retry
}

// MARK: - Connection Trigger
private enum ConnectTrigger {
    case initial  // First app launch - honor 5s grace period
    case retry    // User-initiated retry - show results immediately
}

@MainActor
final class AppDataManager: ObservableObject {
    static let shared = AppDataManager()
    
    // MARK: - Published Properties
    @Published var coreWork: [CoreWork] = []
    @Published var impactStats: [ImpactStat] = []
    @Published var organizationData: OrganizationInfo?
    @Published var articles: [Article] = []
    @Published var programs: [ProgramInfo] = []
    @Published var teams: [Team] = []
    @Published var teamMembers: [TeamMember] = []
    @Published var externalLinks: [ExternalLink] = []
    @Published var supportMissionContent: SupportMissionContent?
    
    // MARK: - Connection State
    @Published private(set) var connectionState: ConnectionState = .initial
    @Published private(set) var isNetworkLoadInFlight = false
    @Published private(set) var hasNetworkPath = true  // From NWPathMonitor
    @Published var error: Error?
    @Published var lastLoadTime: Date?
    
    // MARK: - Private Properties
    private let repository: FirestoreRepositoryProtocol
    private var connectivityTimer: Task<Void, Never>?
    private let connectivityTimeout: TimeInterval = 5.0
    private var currentAttemptID = UUID()
    private var didInitialize = false
    private let pathMonitor = NWPathMonitor()
    private let pathQueue = DispatchQueue(label: "com.chieac.network.monitor")
    
    // MARK: - Computed Properties
    var hasData: Bool {
        organizationData != nil && !articles.isEmpty && !coreWork.isEmpty
    }
    
    var shouldShowLoading: Bool {
        switch connectionState {
        case .initial, .loadingWithoutCache:
            return true
        default:
            return false
        }
    }
    
    var shouldShowConnectivityBanner: Bool {
        switch connectionState {
        case .offline, .retrying:
            return true
        default:
            return false
        }
    }
    
    var isRetrying: Bool {
        connectionState == .retrying
    }
    
    var bannerMessage: String {
        switch connectionState {
        case .retrying:
            return "Attempting to connect..."
        case .offline:
            if !hasNetworkPath {
                return "No network connection"
            } else {
                return "Unable to connect to server"
            }
        default:
            return ""
        }
    }
    
    var shouldShowRetryButton: Bool {
        // Only show retry if we're offline and have a network path
        connectionState == .offline && hasNetworkPath
    }
    
    // MARK: - Initialization
    private init(repository: FirestoreRepositoryProtocol = FirestoreRepository.shared) {
        self.repository = repository
        setupNetworkMonitoring()
    }
    
    // MARK: - Network Monitoring
    private func setupNetworkMonitoring() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.hasNetworkPath = (path.status == .satisfied)
                
                if path.status == .satisfied {
                    // Network came back - auto-retry if we're offline
                    if self?.connectionState == .offline {
                        await self?.retryConnection()
                    }
                } else {
                    // Network went away - show offline banner immediately
                    if self?.connectionState == .connected {
                        self?.connectionState = .offline
                        print("📡 Network lost - showing offline banner")
                    }
                }
            }
        }
        pathMonitor.start(queue: pathQueue)
    }
    
    deinit {
        pathMonitor.cancel()
    }
    
    // MARK: - Public Methods
    func initializeApp() async {
        guard !didInitialize else { return }
        didInitialize = true
        
        // Step 1: Load cached data
        await loadCachedData()
        
        // Step 2: Set initial state based on cache
        connectionState = hasData ? .loadingWithCache : .loadingWithoutCache
        
        // Step 3: Check network path and show banner immediately if offline
        if !hasNetworkPath {
            // No network - show banner immediately
            connectionState = .offline
        } else {
            // Has network - start timer (shows banner after 5s if can't reach server)
            startConnectivityTimer()
        }
        
        // Step 4: Attempt network connection
        await attemptNetworkConnection(trigger: .initial)
    }
    
    func retryConnection() async {
        guard !isNetworkLoadInFlight else { return }
        
        // Cancel any existing timer
        connectivityTimer?.cancel()
        
        // Set retrying state
        connectionState = .retrying
        
        // Attempt connection
        await attemptNetworkConnection(trigger: .retry)
    }
    
    func forceRefreshAllData() async {
        guard !isNetworkLoadInFlight else { return }
        
        // Skip if no network path
        guard hasNetworkPath else {
            print("⚠️ No network path available for refresh")
            connectionState = .offline
            return
        }
        
        isNetworkLoadInFlight = true
        defer { isNetworkLoadInFlight = false }
        
        error = nil
        
        do {
            // Force load all data from server with timeout
            let fetched = try await withTimeout(seconds: 10.0) {
                try await self.repository.loadPrimaryFromServer()
            }
            
            // Update primary data regardless of server detection
            self.organizationData = fetched.org.value
            self.articles = fetched.articles.value
            self.coreWork = fetched.core.value
            self.impactStats = fetched.impact.value
            self.lastLoadTime = Date()
            
            // Check if we hit the server
            let hitServer = fetched.org.fromServer || 
                           fetched.articles.fromServer ||
                           fetched.core.fromServer ||
                           fetched.impact.fromServer
            
            if hitServer {
                self.connectionState = .connected
                print("✅ Force refresh: Successfully connected to server")
            } else {
                print("⚠️ Force refresh: Got cached data")
            }
            
            // Always refresh secondary data when user explicitly refreshes
            await self.loadSecondaryData()
            
        } catch {
            self.error = error
            self.connectionState = .offline
            print("❌ Force refresh failed: \(error)")
        }
    }
    
    func handleAppBecameActive() {
        // Only retry if we're offline and have network
        if connectionState == .offline && hasNetworkPath {
            Task {
                await retryConnection()
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadCachedData() async {
        do {
            // Load primary data from cache
            let cached = try await repository.loadPrimaryFromCache()
            
            // Load secondary data from cache (programs, teams, etc.)
            async let cachedPrograms = repository.loadProgramsFromCache()
            async let cachedTeams = repository.loadTeamsFromCache()
            async let cachedTeamMembers = repository.loadTeamMembersFromCache()
            
            // Update with cached data
            self.organizationData = cached.org
            self.articles = cached.articles
            self.coreWork = cached.core
            self.impactStats = cached.impact
            
            // Update secondary data
            do {
                self.programs = try await cachedPrograms
                self.teams = try await cachedTeams
                self.teamMembers = try await cachedTeamMembers
                print("✅ Loaded cached secondary data")
            } catch {
                print("ℹ️ Some cached secondary data not available: \(error)")
            }
            
            print("✅ Loaded cached data: hasData = \(hasData)")
            
        } catch {
            print("ℹ️ No cached data available: \(error)")
        }
    }
    
    private func attemptNetworkConnection(trigger: ConnectTrigger) async {
        guard !isNetworkLoadInFlight else {
            print("⚠️ Network load already in flight, skipping")
            return
        }
        
        // Skip connection attempt if no network path
        guard hasNetworkPath else {
            print("⚠️ No network path available, skipping connection attempt")
            connectionState = .offline
            return
        }
        
        isNetworkLoadInFlight = true
        let attemptID = UUID()
        currentAttemptID = attemptID
        defer { isNetworkLoadInFlight = false }
        
        error = nil
        
        do {
            // Load data with server detection - THIS IS THE CRITICAL FIX
            let fetched = try await withTimeout(seconds: 10.0) {
                try await self.repository.loadPrimaryFromServer()
            }
            
            // Check if this attempt is still current
            guard attemptID == currentAttemptID else {
                print("⚠️ Stale network attempt completed, ignoring")
                return
            }
            
            // Check if ANY call hit the server - THIS IS THE KEY CHECK
            let hitServer = fetched.org.fromServer || 
                           fetched.articles.fromServer ||
                           fetched.core.fromServer || 
                           fetched.impact.fromServer
            
            if hitServer {
                // Real server connection - update data and mark connected
                self.organizationData = fetched.org.value
                self.articles = fetched.articles.value
                self.coreWork = fetched.core.value
                self.impactStats = fetched.impact.value
                self.lastLoadTime = Date()
                self.connectionState = .connected
                self.connectivityTimer?.cancel()
                
                print("✅ Successfully connected to server")
                
                // Load secondary data in background
                Task { await self.loadSecondaryData() }
                
            } else {
                // Got cached data but no server connection
                print("⚠️ Got cached data but no server connection")
                
                if trigger == .retry {
                    // User retry - show offline state immediately
                    self.connectionState = .offline
                } else {
                    // Initial launch - let timer handle it (5s grace period)
                    // Keep current loading state
                }
            }
            
        } catch {
            // Check if this attempt is still current
            guard attemptID == currentAttemptID else {
                print("⚠️ Stale network failure, ignoring")
                return
            }
            
            self.error = error
            print("❌ Network connection failed: \(error)")
            
            if trigger == .retry {
                // User retry - show offline state immediately
                self.connectionState = .offline
            } else {
                // Initial launch - honor 5s grace period
                // Timer will set .offline after delay
            }
        }
    }
    
    private func startConnectivityTimer() {
        connectivityTimer?.cancel()
        connectivityTimer = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(connectivityTimeout * 1_000_000_000))
                
                // If we're still not connected after timeout, update state
                if !Task.isCancelled && connectionState != .connected {
                    await MainActor.run {
                        if self.connectionState != .retrying {
                            self.connectionState = .offline
                        }
                    }
                }
            } catch {
                // Task was cancelled, which is expected
            }
        }
    }
    
    private func loadSecondaryData() async {
        do {
            async let programs = repository.loadPrograms()
            async let teams = repository.loadTeams()
            async let teamMembers = repository.loadTeamMembers()
            async let externalLinks = repository.loadExternalLinks()
            async let supportContent = repository.loadSupportMissionContent()
            
            let results = try await (programs, teams, teamMembers, externalLinks, supportContent)
            
            self.programs = results.0
            self.teams = results.1
            self.teamMembers = results.2
            self.externalLinks = results.3
            self.supportMissionContent = results.4
            
            // Notify UI components to refresh images when new data is loaded
            NotificationCenter.default.post(name: .refreshImages, object: nil)
            
        } catch {
            print("Error loading secondary data: \(error)")
        }
    }
    
    // MARK: - Utility Functions
    private func withTimeout<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            // Add the main operation
            group.addTask {
                try await operation()
            }
            
            // Add timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            // Return the first result (either success or timeout)
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

// MARK: - Timeout Error
struct TimeoutError: LocalizedError {
    var errorDescription: String? {
        "Operation timed out"
    }
}
