//
//  Colors.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

extension Color {
    // ChiEAC Brand Colors
    static let chieacPrimary = Color(hex: "#13372e")      // Dark green
    static let chieacSecondary = Color(hex: "#12614d")    // Medium green
    static let chieacBackground = Color.white             // Background
    static let chieacCardBackground = Color(hex: "#f8f9fa") // Card background
    
    // Light Green Theme Colors
    static let chieacLightBackground = Color(hex: "#f0f8f5")  // Very light green background
    static let chieacCardGreen = Color(hex: "#f7fcf9")        // Very light green for cards
    static let chieacMintGreen = Color(hex: "#e8f5f0")        // Mint green accent
    
    // Supporting Colors
    static let chieacSuccess = Color(hex: "#28a745")      // Success green
    static let chieacInfo = Color(hex: "#007bff")         // Info blue (for Data Science Alliance)
    static let chieacWarning = Color(hex: "#fd7e14")      // Warning orange
    static let chieacTextPrimary = Color(hex: "#13372e")  // Primary text
    static let chieacTextSecondary = Color(hex: "#6c757d") // Secondary text
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
