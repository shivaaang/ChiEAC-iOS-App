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
    @State private var presentingArticle: Article?
    @State private var showingFilter: Bool = false
    // Adjustable offset so popup aligns approximately with first article card top
    private let filterPopupTopOffset: CGFloat = 60 // refined to align with first ArticlePageCard
    
    // Dynamically derive all tags from current articles (see Utils/ArticleTags.swift)
    // Only include tags that appear in at least 6 articles ( >5 )
    private var allTags: [String] { articles.allArticleTags(minimumFrequency: 5) }
    
    private var filtered: [Article] {
        guard !selectedTags.isEmpty else { return articles }
        return articles.filter { article in
            !selectedTags.isDisjoint(with: article.articleTags)
        }
    }
    
    var body: some View {
        ZStack {
            Color.chieacLightBackground.ignoresSafeArea()
            List {
                Section {
                    // Header title + tag chips
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Articles")
                            .font(.chieacAppTitle)
                            .foregroundColor(.chieacTextPrimary)
                            .padding(.top, 2)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 6, trailing: 16))
                    .listRowBackground(Color.clear)

                    // Articles list
                    ForEach(filtered, id: \.mediumLink) { article in
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
                }
                .textCase(nil)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(.custom(10))
            .listSectionSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .sheet(item: $presentingArticle) { article in
            ExternalLinkWebView(urlString: article.mediumLink, title: "Article")
        }
        // Modern onChange API (iOS 17+) using two-parameter closure; fallback to legacy for earlier OS versions.
        .modifier(ArticlesTagsChangeModifier(articles: articles, selectedTags: $selectedTags, allTagsProvider: { allTags }))
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
    let allTagsProvider: () -> [String]

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.onChange(of: articles) { oldValue, newValue in
                pruneSelections(using: newValue)
            }
        } else {
            content.onChange(of: articles) { _ in
                pruneSelections(using: articles)
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
            let mock = [Article(id: nil, title: "Sample", mediumLink: "https://example.com", imageLink: "https://picsum.photos/400/300", articleTags: ["Mock"], publishedAt: Date()) ]
            ArticlesView(articles: mock)
        }
    }
}
