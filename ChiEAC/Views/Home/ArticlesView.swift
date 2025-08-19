//
//  ArticlesView.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/10/25.
//

import SwiftUI

struct ArticlesView: View {
    let articles: [Article]
    @State private var selectedTags: Set<String> = []
    @State private var showingFilter = false
    @State private var presentingArticle: Article?
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool    // Pagination settings
    private let articlesPerPage = 10
    
    // Adjustable offset so popup aligns approximately with first article card top
    private let filterPopupTopOffset: CGFloat = 60 // refined to align with first ArticlePageCard
    
    // Dynamically derive all tags from current articles (see Utils/ArticleTags.swift)
    // Only include tags that appear in at least 6 articles ( >5 )
    private var allTags: [String] { articles.allArticleTags(minimumFrequency: 5) }
    
    private var filtered: [Article] {
        var result = articles
        
                // Apply smart search filter
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result = result.smartSearch(searchText)
        }
        
        // Apply tag filter
        if !selectedTags.isEmpty {
            result = result.filter { article in
                !selectedTags.isDisjoint(with: article.articleTags)
            }
        }
        
        return result
    }
    
    // MARK: - Load More Properties
    @State private var displayedCount: Int = 10
    private let articlesPerLoad: Int = 10
    
    // MARK: - Computed Properties for Load More
    private var displayedArticles: [Article] {
        let count = min(displayedCount, filtered.count)
        return Array(filtered[0..<count])
    }
    
    private var hasMoreToLoad: Bool {
        displayedCount < filtered.count
    }
    
    // Reset displayed count when filters change
    private func resetDisplayedCount() {
        displayedCount = min(articlesPerLoad, filtered.count)
    }
    
    var body: some View {
        ZStack {
            Color.chieacLightBackground.ignoresSafeArea()
            List {
                Section {
                    // Header title + tag chips
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Articles")
                                .font(.chieacAppTitle)
                                .foregroundColor(.chieacTextPrimary)
                                .padding(.top, 2)
                            
                            Spacer()
                            
                            // Articles count info
                            Text("\(filtered.count) articles")
                                .font(.chieacCaption)
                                .foregroundColor(.chieacTextSecondary)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)

                    // Search Bar
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.chieacTextSecondary)
                                .font(.system(size: 16, weight: .medium))
                            
                            TextField("Search articles...", text: $searchText)
                                .font(.system(size: 16))
                                .foregroundColor(.chieacTextPrimary)
                                .submitLabel(.search)
                                .focused($isSearchFocused)
                                .onSubmit {
                                    // Dismiss keyboard when search is submitted
                                    isSearchFocused = false
                                }
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.chieacTextSecondary)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.08))
                        )
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)

                    // Articles list - now using displayed articles
                    ForEach(displayedArticles, id: \.mediumLink) { article in
                        Button {
                            presentingArticle = article
                        } label: {
                            ArticlePageCard(article: article)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    
                    // Load More Button
                    if hasMoreToLoad {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    displayedCount = min(displayedCount + articlesPerLoad, filtered.count)
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Text("Load More")
                                        .font(.system(size: 15, weight: .medium))
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.chieacPrimary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .strokeBorder(Color.chieacPrimary.opacity(0.6), lineWidth: 1)
                                        .background(
                                            Capsule()
                                                .fill(Color.chieacPrimary.opacity(0.05))
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                        }
                        .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 20, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .textCase(nil)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(.custom(10))
            .listSectionSeparator(.hidden)
            .listRowBackground(Color.clear)
            .onTapGesture {
                // Dismiss keyboard when tapping outside search field
                if isSearchFocused {
                    isSearchFocused = false
                }
            }
        }
        .toolbar {
            if isSearchFocused {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isSearchFocused = false
                        }
                        .foregroundColor(.chieacPrimary)
                        .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
        .sheet(item: $presentingArticle) { article in
            ExternalLinkWebView(urlString: article.mediumLink, title: "Article")
        }
        // Modern onChange API (iOS 17+) using two-parameter closure; fallback to legacy for earlier OS versions.
        .modifier(ArticlesTagsChangeModifier(
            articles: articles, 
            selectedTags: $selectedTags, 
            searchText: $searchText,
            displayedCount: $displayedCount,
            articlesPerLoad: articlesPerLoad,
            allTagsProvider: { allTags }
        ))
        // Filter popup overlay
        .overlay(alignment: .top) {
            if showingFilter {
                ArticlesFilterPopupCard(
                    tags: allTags,
                    selection: $selectedTags,
                    topOffset: filterPopupTopOffset,
                    dismiss: { showingFilter = false }
                )
                .zIndex(10)
            }
        }
        .toolbar { // Persistent filter access while scrolling
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingFilter = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Filter")
                            .font(.caption.weight(.semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Color.chieacPrimary.opacity(0.15))
                    )
                    .foregroundColor(.chieacPrimary)
                    // Preserve tap target ~44pt height via invisible expansion
                    .contentShape(Rectangle())
                }
                .padding(.vertical, 4) // slight extra outer padding for tap area
                .accessibilityIdentifier("articlesFilterButton")
            }
        }
    }
}

// MARK: - Change Modifier (handles iOS 17 deprecation of old onChange signature)
private struct ArticlesTagsChangeModifier: ViewModifier {
    let articles: [Article]
    @Binding var selectedTags: Set<String>
    @Binding var searchText: String
    @Binding var displayedCount: Int
    let articlesPerLoad: Int
    let allTagsProvider: () -> [String]

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .onChange(of: articles) { oldValue, newValue in
                    pruneSelections(using: newValue)
                }
                .onChange(of: selectedTags) { oldValue, newValue in
                    // Reset displayed count when filters change
                    displayedCount = articlesPerLoad
                }
                .onChange(of: searchText) { oldValue, newValue in
                    // Reset displayed count when search changes
                    displayedCount = articlesPerLoad
                }
        } else {
            content
                .onChange(of: articles) { _ in
                    pruneSelections(using: articles)
                }
                .onChange(of: selectedTags) { _ in
                    // Reset displayed count when filters change
                    displayedCount = articlesPerLoad
                }
                .onChange(of: searchText) { _ in
                    // Reset displayed count when search changes
                    displayedCount = articlesPerLoad
                }
        }
    }

    private func pruneSelections(using current: [Article]) {
        let valid = Set(allTagsProvider())
        if !selectedTags.isSubset(of: valid) {
            selectedTags = selectedTags.intersection(valid)
        }
    }
}

// (Filter popup extracted to Components/ArticlesFilterPopupCard.swift)

struct ArticlesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let mock = [Article(id: "sample_1", title: "Sample", mediumLink: "https://example.com", imageLink: "https://picsum.photos/400/300", articleTags: ["Mock"], publishedAt: Date()) ]
            ArticlesView(articles: mock)
        }
    }
}
