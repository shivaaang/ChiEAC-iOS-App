//
//  HeroHeader.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/14/25.
//

import SwiftUI

/// Reusable hero-style header used at the top of primary tabs / feature screens.
/// Consolidates the previously duplicated gradient + icon + title + subtitle pattern.
/// - Customization points:
///   - systemImage OR asset image (circle badge)
///   - title & optional subtitle
///   - gradient colors
///   - optional decorative background circles
///   - optional extra content block placed beneath subtitle (e.g., tagline chips, buttons)
struct HeroHeader<ExtraContent: View>: View {
    // MARK: - Public API
    let title: String
    let subtitle: String?
    let systemImage: String?
    let assetImage: String?
    let gradientColors: [Color]
    let showDecorativeCircles: Bool
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    let extraContent: () -> ExtraContent

    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        assetImage: String? = nil,
        gradientColors: [Color] = [.chieacMintGreen, .white],
        showDecorativeCircles: Bool = false,
        topPadding: CGFloat = 60,
        bottomPadding: CGFloat = 24,
        @ViewBuilder extraContent: @escaping () -> ExtraContent = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.assetImage = assetImage
        self.gradientColors = gradientColors
        self.showDecorativeCircles = showDecorativeCircles
        self.topPadding = topPadding
        self.bottomPadding = bottomPadding
        self.extraContent = extraContent
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(decorativeOverlay)

            VStack(spacing: 12) {
                badge
                Text(title)
                    .font(.chieacAppTitle)
                    .foregroundColor(.chieacPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.chieacBody)
                        .foregroundColor(.chieacTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                extraContent()
            }
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Subviews
    @ViewBuilder private var badge: some View {
        if let asset = assetImage {
            Image(asset)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .padding(20)
                .background(Circle().fill(Color.white))
                .shadow(color: .chieacPrimary.opacity(0.15), radius: 10, x: 0, y: 6)
        } else if let symbol = systemImage {
            Image(systemName: symbol)
                .font(.system(size: 56))
                .foregroundColor(.chieacSecondary)
                .padding(18)
                .background(Circle().fill(Color.white))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder private var decorativeOverlay: some View {
        if showDecorativeCircles {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 240, height: 240)
                    .offset(x: -140, y: -60)
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 180, height: 180)
                    .offset(x: 160, y: 10)
            }
        } else {
            EmptyView()
        }
    }
}

// MARK: - Preview
struct HeroHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            HeroHeader(
                title: "About Us",
                subtitle: "Meet the passionate team behind ChiEAC's mission",
                systemImage: "person.3.fill"
            )
            .previewDisplayName("Symbol Header")

            HeroHeader(
                title: "ChiEAC",
                subtitle: "Serving students and families con cariño",
                assetImage: "chieac-logo-icon",
                showDecorativeCircles: true
            )
            .previewDisplayName("Logo Header w/ Decor")
        }
    }
}
