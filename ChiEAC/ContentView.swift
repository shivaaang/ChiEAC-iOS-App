//
//  ContentView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appDataManager: AppDataManager
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            Group {
                if appDataManager.shouldShowLoading {
                    LoadingView()
                } else {
                    MainTabView()
                }
            }
            
            // Connectivity Banner - positioned above tab bar
            if appDataManager.shouldShowConnectivityBanner {
                VStack {
                    Spacer()
                    ConnectivityBanner()
                        .padding(.bottom, 60) // Just above programs tab
                }
                .animation(.easeInOut(duration: 0.3), value: appDataManager.shouldShowConnectivityBanner)
            }
        }
        .task {
            await appDataManager.initializeApp()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                appDataManager.handleAppBecameActive()
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image("chieac-logo-icon")
                .resizable()
                .frame(width: 80, height: 80)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
            
            VStack(spacing: 8) {
                Text("ChiEAC")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.chieacPrimary)
                
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.chieacTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.chieacLightBackground)
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ProgramsView()
                .tabItem {
                    Image(systemName: "graduationcap.fill")
                    Text("Programs")
                }
            
            AboutView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("About Us")
                }
        }
        .accentColor(.chieacSecondary)
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.systemBackground
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}

// MARK: - Connectivity Banner
struct ConnectivityBanner: View {
    @EnvironmentObject var appDataManager: AppDataManager
    @State private var pulseOpacity: Double = 1.0
    
    var body: some View {
        HStack(spacing: 10) {
            // Animated icon
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .font(.system(size: 12, weight: .medium))
                .opacity(appDataManager.isRetrying ? pulseOpacity : 1.0)
                .onAppear {
                    startPulseAnimationIfNeeded()
                }
                .onChange(of: appDataManager.isRetrying) { _, isRetrying in
                    if isRetrying {
                        startPulseAnimation()
                    } else {
                        stopPulseAnimation()
                    }
                }
            
            // Banner message
            Text(bannerMessage)
                .foregroundColor(textColor)
                .font(.system(size: 12, weight: .medium))
            
            // Retry button
            if appDataManager.shouldShowRetryButton {
                Button(action: retryConnection) {
                    Text("Retry")
                        .foregroundColor(retryButtonTextColor)
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(retryButtonBackground)
                        .clipShape(Capsule())
                }
                .disabled(!appDataManager.hasNetworkPath)
                .opacity(appDataManager.hasNetworkPath ? 1.0 : 0.6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(bannerBackgroundColor)
                .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Private Methods
    
    private func startPulseAnimationIfNeeded() {
        if appDataManager.isRetrying {
            startPulseAnimation()
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            pulseOpacity = 0.5
        }
    }
    
    private func stopPulseAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            pulseOpacity = 1.0
        }
    }
    
    private func retryConnection() {
        Task {
            await appDataManager.retryConnection()
        }
    }
    
    // MARK: - Banner Styling Properties
    
    private var iconName: String {
        switch (appDataManager.isRetrying, appDataManager.hasNetworkPath) {
        case (true, _):
            return "arrow.triangle.2.circlepath"
        case (false, false):
            return "wifi.slash"
        case (false, true):
            return "exclamationmark.triangle"
        }
    }
    
    private var bannerMessage: String {
        if appDataManager.isRetrying {
            return "Connecting..."
        } else if !appDataManager.hasNetworkPath {
            return "No Internet"
        } else {
            return "Connection Issue"
        }
    }
    
    private var bannerBackgroundColor: Color {
        if appDataManager.isRetrying {
            return Color.chieacInfo
        } else if !appDataManager.hasNetworkPath {
            return Color.red
        } else {
            return Color.chieacWarning
        }
    }
    
    private var iconColor: Color {
        return .white
    }
    
    private var textColor: Color {
        return .white
    }
    
    private var retryButtonBackground: Color {
        return Color.white.opacity(0.2)
    }
    
    private var retryButtonTextColor: Color {
        return .white
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppDataManager.shared)
    }
}
