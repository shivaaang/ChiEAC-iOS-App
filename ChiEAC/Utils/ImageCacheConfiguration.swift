//
//  ImageCacheConfiguration.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/19/25.
//

import Foundation
import Kingfisher

/// Configures Kingfisher cache settings for optimal performance
struct ImageCacheConfiguration {
    
    /// Configure Kingfisher cache settings on app launch
    static func configure() {
        let cache = ImageCache.default
        
        // Disk cache settings
        cache.diskStorage.config.sizeLimit = 100 * 1024 * 1024 // 100MB disk cache
        cache.diskStorage.config.expiration = .days(30) // Keep for 30 days
        
        // Memory cache settings  
        cache.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024 // 50MB memory cache
        cache.memoryStorage.config.expiration = .seconds(300) // 5 minutes in memory
        
        // Cleanup settings
        cache.diskStorage.config.pathExtension = "chieac" // Custom cache folder
        
        print("✅ Kingfisher cache configured: 100MB disk, 50MB memory, 30-day retention")
    }
    
    /// Clear all cached images (useful for debugging or settings)
    static func clearCache() {
        ImageCache.default.clearCache {
            print("🗑️ Kingfisher cache cleared")
        }
    }
    
    /// Get current cache size information
    static func getCacheInfo() {
        ImageCache.default.calculateDiskStorageSize { result in
            switch result {
            case .success(let size):
                let sizeInMB = Double(size) / 1024.0 / 1024.0
                print("📊 Kingfisher disk cache size: \(String(format: "%.2f", sizeInMB)) MB")
            case .failure(let error):
                print("❌ Failed to get cache size: \(error)")
            }
        }
    }
}
