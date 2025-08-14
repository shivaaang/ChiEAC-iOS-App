//
//  ArticleTags.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/13/25.
//

import Foundation

extension Collection where Element == Article {
    /// Returns a stable, frequency-sorted list of all unique tags that appear across the articles.
    /// - Sorting Strategy:
    ///   1. Descending by usage count (most common first)
    ///   2. Alphabetical as tiebreaker for predictable ordering
    /// - Returns: `[String]` of unique tags; empty if collection is empty or contains no tags.
    func allArticleTags() -> [String] {
        var counts: [String: Int] = [:]
        for article in self {
            for tag in article.articleTags {
                let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { continue }
                counts[trimmed, default: 0] += 1
            }
        }
        return counts
            .map { ($0.key, $0.value) }
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 > rhs.1 } // higher frequency first
                return lhs.0.lowercased() < rhs.0.lowercased() // alpha tiebreaker
            }
            .map { $0.0 }
    }
}
