//
//  ArticlePageCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/10/25.
//

import SwiftUI
import UIKit

struct ArticlePageCard: View {
    let article: Article
    // Fixed card sizing
    private static let cardHeight: CGFloat = 140
    private static let verticalPadding: CGFloat = 15
    // Image width kept consistent with prior design
    private static let imageWidth: CGFloat = 132

    var body: some View {
        let contentHeight = Self.cardHeight - (Self.verticalPadding * 2)
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.chieacTextPrimary)
                    .lineLimit(3)
//                    .lineSpacing()
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let date = article.publishedAt {
                    Text(relativeDateString(for: date))
                        .font(.caption) // already dynamic
                        .foregroundColor(.chieacTextSecondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 4) // keep minimal gap before tags
                SingleLineTagRow(tags: article.articleTags)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: contentHeight, alignment: .top)

            AsyncImage(url: URL(string: article.imageLink)) { phase in
                switch phase {
                case .empty:
                    ZStack { Color.gray.opacity(0.15); ProgressView() }
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure(_):
                    ZStack { Color.gray.opacity(0.2); Image(systemName: "photo").font(.title).foregroundColor(.gray) }
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: Self.imageWidth, height: contentHeight)
            .clipped()
            .cornerRadius(16)
        }
        .padding(Self.verticalPadding)
        .frame(height: Self.cardHeight, alignment: .topLeading)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.chieacMintGreen.opacity(0.6), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.chieacCardGreen)
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Relative Date Helper
private extension ArticlePageCard {
    func relativeDateString(for date: Date) -> String {
        let calendar = Calendar.current
        let startOfTarget = calendar.startOfDay(for: date)
        let startOfToday = calendar.startOfDay(for: Date())
        let days = calendar.dateComponents([.day], from: startOfTarget, to: startOfToday).day ?? 0
        if days >= 0 && days < 7 {
            switch days {
            case 0: return "Today"
            case 1: return "1 day ago"
            default: return "\(days) days ago"
            }
        }
        return date.formatted(.dateTime.month(.wide).day().year())
    }
}

// MARK: - Single line tag row with +N overflow indicator
private struct SingleLineTagRow: View {
    let tags: [String]
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 4) {
            let layout = computeLayout(tags: tags)
            ForEach(layout.visible, id: \.self) { tag in
                TagChip(text: tag)
            }
            if layout.moreCount > 0 {
                TagChip(text: "+\(layout.moreCount)")
                    .foregroundColor(.chieacTextPrimary)
                    .accessibilityLabel("Plus \(layout.moreCount) more tags")
            }
        }
    }

    private func computeLayout(tags: [String]) -> (visible: [String], moreCount: Int) {
        guard !tags.isEmpty else { return ([], 0) }
        let screenWidth = UIScreen.main.bounds.width
        let listInsets: CGFloat = 32 // list row leading+trailing
        let cardPadding: CGFloat = 30 // internal + fudge
        let imageWidth: CGFloat = 132
        let columnSpacing: CGFloat = 12
        let safety: CGFloat = 6
    let available = screenWidth - listInsets - cardPadding - imageWidth - columnSpacing - safety
        if available < 40 { return ([], tags.count) }
        let spacing: CGFloat = 4

        func scaledTagUIFont() -> UIFont {
            let base = UIFont.systemFont(ofSize: 9, weight: .semibold)
            return UIFontMetrics(forTextStyle: .caption2).scaledFont(for: base)
        }

        let tagFont = scaledTagUIFont()
        func chipWidth(_ text: String) -> CGFloat {
            let attributes = [NSAttributedString.Key.font: tagFont]
            let size = (text as NSString).size(withAttributes: attributes)
            return size.width + 12 + 2 // horizontal padding + fudge
        }

        var visible: [String] = []
        var used: CGFloat = 0
        for (i, tag) in tags.enumerated() {
            let w = chipWidth(tag)
            let add = visible.isEmpty ? w : (spacing + w)
            let remainingTags = tags.count - (i + 1)
            let reserve = remainingTags > 0 ? (spacing + chipWidth("+\(remainingTags)")) : 0
            if used + add + reserve <= available {
                visible.append(tag)
                used += add
            } else { break }
        }
        let more = tags.count - visible.count
        return (visible, max(0, more))
    }
}

private struct TagChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption2)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 2.5) // slightly tighter to keep chip compact as it scales
            .background(Color(UIColor.systemGray6))
            .foregroundColor(.chieacTextSecondary)
            .cornerRadius(16)
    }
}

struct ArticlePageCard_Previews: PreviewProvider {
    static var previews: some View {
        List {
            let mock = Article(id: "sample_long_title", title: "Sample Long Title That Potentially Spans Multiple Lines To Test Layout Wrapping", mediumLink: "https://example.com", imageLink: "https://picsum.photos/400/300", articleTags: ["Education", "Community", "Advocacy", "Equity", "Youth"], publishedAt: Date())
            ArticlePageCard(article: mock)
        }
    }
}

// Removed dynamic height measurement; fixed card height restored.
