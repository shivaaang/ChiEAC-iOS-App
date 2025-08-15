//
//  ArticleTags.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/13/25.
//

import Foundation

extension Collection where Element == Article {
    /// Returns a stable, frequency-sorted list of unique tags.
    /// - Parameters:
    ///   - minimumFrequency: Only include tags whose occurrence count is >= this threshold (default 1 = all tags).
    /// - Sorting Strategy:
    ///   1. Descending by usage count (most common first)
    ///   2. Alphabetical as tiebreaker
    func allArticleTags(minimumFrequency: Int = 1) -> [String] {
        guard minimumFrequency > 0 else { return [] }
        var counts: [String: Int] = [:]
        for article in self {
            for tag in article.articleTags {
                let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { continue }
                counts[trimmed, default: 0] += 1
            }
        }
        return counts
            .compactMap { key, value in value >= minimumFrequency ? (key, value) : nil }
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
                return lhs.0.lowercased() < rhs.0.lowercased()
            }
            .map { $0.0 }
    }
}
