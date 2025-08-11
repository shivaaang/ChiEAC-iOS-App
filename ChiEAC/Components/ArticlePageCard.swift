//
//  ArticlePageCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/10/25.
//

import SwiftUI

struct ArticlePageCard: View {
    let article: Article
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                // Title at top-left
                Text(article.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.chieacTextPrimary)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 4)

                // Tags anchored to bottom-left
                TagWrap(tags: article.articleTags)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Right image (wider by ~50%)
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
            .frame(width: 132, height: 100)
            .clipped()
            .cornerRadius(10)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(UIColor.systemGray5), lineWidth: 1)
        )
    }
}

private struct TagWrap: View {
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            let rows = makeRows(tags: tags, maxRows: 2)
            ForEach(rows.indices, id: \.self) { idx in
                HStack(spacing: 4) {
                    ForEach(rows[idx], id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 9, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(UIColor.systemGray6))
                            .foregroundColor(.chieacTextSecondary)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private func makeRows(tags: [String], maxRows: Int) -> [[String]] {
        // Estimate available width for the left column inside the card based on screen width
        // card sits in a List row with 16pt insets, and has 14pt internal horizontal padding
        // right image is 132pt and HStack spacing is 12pt
        let screenWidth = UIScreen.main.bounds.width
        let listInsets: CGFloat = 32 // 16 leading + 16 trailing
        let cardPadding: CGFloat = 28 // 14 left + 14 right
        let imageWidth: CGFloat = 132
        let columnSpacing: CGFloat = 12
        let safety: CGFloat = 6
        var maxWidth = screenWidth - listInsets - cardPadding - imageWidth - columnSpacing - safety
        if maxWidth < 0 { maxWidth = 0 }

        // Approximate chip width using SwiftUI font metrics; avoid UIKit
        func chipWidth(for text: String) -> CGFloat {
            // Base estimate per character with semibold 9pt + padding; tuned to avoid overflow
            let perChar: CGFloat = 5.3
            let base = perChar * CGFloat(text.count)
            return base + 14 // 6+6 padding + small buffer
        }

        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentWidth: CGFloat = 0
        let interChipSpacing: CGFloat = 4

        for tag in tags {
            var width = chipWidth(for: tag)
            // If a single chip is wider than the available width, clamp it to maxWidth
            if width > maxWidth { width = maxWidth }

            if currentRow.isEmpty {
                // first chip in the row
                if width <= maxWidth {
                    currentRow.append(tag)
                    currentWidth = width
                } else {
                    // fallback: force into its own row
                    rows.append([tag])
                    if rows.count >= maxRows { break }
                    currentRow.removeAll(); currentWidth = 0
                }
            } else {
                if currentWidth + interChipSpacing + width <= maxWidth {
                    currentRow.append(tag)
                    currentWidth += interChipSpacing + width
                } else {
                    rows.append(currentRow)
                    if rows.count >= maxRows { break }
                    currentRow = [tag]
                    currentWidth = width
                }
            }
        }

        if rows.count < maxRows && !currentRow.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }
}

struct ArticlePageCard_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ArticlePageCard(article: Article.seedData.first!)
        }
    }
}
