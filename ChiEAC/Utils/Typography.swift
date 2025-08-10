//
//  Typography.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/9/25.
//

import SwiftUI

// MARK: - ChiEAC Typography System
extension Font {
    // MARK: - App Branding
    static var chieacAppTitle: Font {
        return .largeTitle.bold()
    }
    
    static var chieacTagline: Font {
        return .headline.weight(.medium)
    }
    
    // MARK: - Content Hierarchy
    static var chieacHero: Font {
        return .title2.bold()
    }
    
    static var chieacSectionHeader: Font {
        return .title.bold()
    }
    
    static var chieacCardTitle: Font {
        return .headline.bold()
    }
    
    static var chieacCardSubtitle: Font {
        return .subheadline.weight(.medium)
    }
    
    // MARK: - Body Text
    static var chieacBody: Font {
        return .body
    }
    
    static var chieacBodySecondary: Font {
        return .body.weight(.medium)
    }
    
    static var chieacCaption: Font {
        return .caption.weight(.medium)
    }
    
    // MARK: - Stats & Numbers
    static var chieacStatNumber: Font {
        return .title.bold()
    }
    
    static var chieacStatLabel: Font {
        return .caption.weight(.medium)
    }
    
    // MARK: - Buttons & Interactive
    static var chieacButtonText: Font {
        return .headline.weight(.semibold)
    }
    
    static var chieacButtonSecondary: Font {
        return .body.weight(.medium)
    }
    
    // MARK: - Additional font variants
    static var chieacCardBody: Font {
        return .system(size: 14, weight: .regular)
    }
}