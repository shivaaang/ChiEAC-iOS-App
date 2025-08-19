//
//  SocialMediaLinksCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/18/25.
//

import SwiftUI

struct SocialMediaLinksCard: View {
    let youtubeURL: String?
    let instagramURL: String?
    let linkedinURL: String?
    let websiteURL: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Connect With Us")
                    .font(.chieacHero)
                    .foregroundColor(.chieacTextPrimary)
                
                Text("Follow our journey and stay connected")
                    .font(.chieacBody)
                    .foregroundColor(.chieacTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Social Media Links Row
            HStack(spacing: 24) {
                // YouTube
                if let url = youtubeURL {
                    SocialMediaButton(
                        icon: "youtube-logo",
                        color: .red,
                        url: url,
                        platform: .youtube,
                        useAssetImage: true
                    )
                }
                
                // Instagram
                if let url = instagramURL {
                    SocialMediaButton(
                        icon: "instagram-logo",
                        color: Color(red: 0.91, green: 0.26, blue: 0.62),
                        url: url,
                        platform: .instagram,
                        useAssetImage: true
                    )
                }
                
                // LinkedIn
                if let url = linkedinURL {
                    SocialMediaButton(
                        icon: "linkedin-logo",
                        color: Color(red: 0.11, green: 0.47, blue: 0.71),
                        url: url,
                        platform: .linkedin,
                        useAssetImage: true
                    )
                }
                
                // Website - Using Safari SF Symbol
                if let url = websiteURL {
                    SocialMediaButton(
                        icon: "safari",
                        color: .chieacSecondary,
                        url: url,
                        platform: .website,
                        useAssetImage: false
                    )
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .chieacPrimary.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

enum SocialPlatform {
    case youtube
    case instagram
    case linkedin
    case website
}

struct SocialMediaButton: View {
    let icon: String
    let color: Color
    let url: String
    let platform: SocialPlatform
    let useAssetImage: Bool
    
    init(icon: String, color: Color, url: String, platform: SocialPlatform = .website, useAssetImage: Bool = false) {
        self.icon = icon
        self.color = color
        self.url = url
        self.platform = platform
        self.useAssetImage = useAssetImage
    }
    
    var platformName: String {
        switch platform {
        case .youtube:
            return "YouTube"
        case .instagram:
            return "Instagram"
        case .linkedin:
            return "LinkedIn"
        case .website:
            return "Website"
        }
    }
    
    var body: some View {
        Button(action: { openWithAppFallback() }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    if useAssetImage {
                        Image(icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(color)
                    }
                }
                
                Text(platformName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.chieacTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func openWithAppFallback() {
        // Try to open in native app first, fallback to web
        let appURL = getAppURL()
        
        if let appURL = appURL, UIApplication.shared.canOpenURL(appURL) {
            // Open in native app
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else if let webURL = URL(string: url) {
            // Fallback to web browser
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
    
    private func getAppURL() -> URL? {
        switch platform {
        case .instagram:
            // Instagram app scheme - extract username from web URL if possible
            if let username = extractInstagramUsername(from: url) {
                return URL(string: "instagram://user?username=\(username)")
            }
            return nil
            
        case .linkedin:
            // LinkedIn app scheme - extract profile/company from web URL if possible
            if let profilePath = extractLinkedInPath(from: url) {
                return URL(string: "linkedin://\(profilePath)")
            }
            return nil
            
        case .youtube:
            // YouTube already works well with web URLs
            return nil
            
        case .website:
            // Regular website, no app scheme needed
            return nil
        }
    }
    
    private func extractInstagramUsername(from urlString: String) -> String? {
        // Extract username from URL like "https://instagram.com/username"
        guard let url = URL(string: urlString) else { return nil }
        let pathComponents = url.pathComponents
        if pathComponents.count >= 2 && pathComponents[1] != "" {
            return pathComponents[1]
        }
        return nil
    }
    
    private func extractLinkedInPath(from urlString: String) -> String? {
        // Extract path from LinkedIn URL
        guard let url = URL(string: urlString) else { return nil }
        let path = url.path
        if path.hasPrefix("/") {
            return String(path.dropFirst())
        }
        return path
    }
}

// MARK: - Preview
struct SocialMediaLinksCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SocialMediaLinksCard(
                youtubeURL: "https://youtube.com/chieac",
                instagramURL: "https://instagram.com/chieac",
                linkedinURL: "https://linkedin.com/company/chieac",
                websiteURL: "https://chieac.org"
            )
            .padding()
            
            SocialMediaLinksCard(
                youtubeURL: "https://youtube.com/chieac",
                instagramURL: nil,
                linkedinURL: "https://linkedin.com/company/chieac",
                websiteURL: nil
            )
            .padding()
        }
        .background(Color.chieacLightBackground)
        .previewDisplayName("Social Media Links Card")
    }
}
