//
//  SearchUtils.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/19/25.
//

import Foundation

// MARK: - Smart Search Utilities
struct SearchUtils {
    
    /// Performs intelligent word-based search that handles punctuation and spacing gracefully
    /// - Parameters:
    ///   - text: The text to search within
    ///   - query: The search query (can contain multiple words)
    /// - Returns: True if all words in the query are found in the text
    static func smartContains(_ text: String, query: String) -> Bool {
        // Handle empty query
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return true
        }
        
        // Normalize text for searching (lowercase, remove extra spaces)
        let normalizedText = text.lowercased()
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Split query into individual words
        let searchWords = normalizedQuery.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        // Check if ALL words in the query exist in the text
        return searchWords.allSatisfy { word in
            normalizedText.contains(word)
        }
    }
    
    /// Advanced search that also considers word boundaries for more precise matching
    /// - Parameters:
    ///   - text: The text to search within
    ///   - query: The search query
    /// - Returns: True if the query matches with word boundary consideration
    static func preciseWordSearch(_ text: String, query: String) -> Bool {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return true
        }
        
        let normalizedText = text.lowercased()
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let searchWords = normalizedQuery.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        return searchWords.allSatisfy { word in
            // Create word boundary pattern for more precise matching
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: word))"
            let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(normalizedText.startIndex..., in: normalizedText)
            return regex?.firstMatch(in: normalizedText, options: [], range: range) != nil
        }
    }
}

// MARK: - Article Search Extensions
extension Array where Element == Article {
    
    /// Filter articles using smart search
    /// - Parameter query: Search query string
    /// - Returns: Filtered array of articles
    func smartSearch(_ query: String) -> [Article] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return self
        }
        
        return self.filter { article in
            SearchUtils.smartContains(article.title, query: query)
        }
    }
    
    /// Filter articles using precise word boundary search
    /// - Parameter query: Search query string
    /// - Returns: Filtered array of articles
    func preciseSearch(_ query: String) -> [Article] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return self
        }
        
        return self.filter { article in
            SearchUtils.preciseWordSearch(article.title, query: query)
        }
    }
}

// MARK: - Generic Search Extensions (for future use)
extension Array where Element: CustomStringConvertible {
    
    /// Generic smart search for any array of items that can be converted to string
    /// - Parameter query: Search query string
    /// - Returns: Filtered array
    func genericSmartSearch(_ query: String) -> [Element] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return self
        }
        
        return self.filter { item in
            SearchUtils.smartContains(item.description, query: query)
        }
    }
}
