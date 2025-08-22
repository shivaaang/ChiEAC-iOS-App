//
//  ChiEACApp.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI
import FirebaseCore

@main
struct ChiEACApp: App {
    @StateObject private var appDataManager = AppDataManager.shared
    
    init() {
        // Configure Firebase on app launch
        FirebaseApp.configure()
        
        // Configure Kingfisher image cache
        ImageCacheConfiguration.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDataManager)
                .preferredColorScheme(.light)
        }
    }
}
