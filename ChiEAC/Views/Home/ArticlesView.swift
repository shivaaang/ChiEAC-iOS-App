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
    
    private let allTags: [String] = [
        "Mental Health",
        "Social Justice",
        "Education Equity",
        "Immigration & Community",
        "Identity & Culture",
        "Higher Ed Life",
        "Economic Justice"
    ]
    
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
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Articles")
                            .font(.chieacAppTitle)
                            .foregroundColor(.chieacTextPrimary)
                            .padding(.top, 2)

                        // Chip tray card (styled like TeamCard edges)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(allTags, id: \.self) { tag in
                                    TagChip(tag: tag, isSelected: selectedTags.contains(tag)) {
                                        if selectedTags.contains(tag) { selectedTags.remove(tag) } else { selectedTags.insert(tag) }
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .padding(.trailing, 16) // keep last chip from touching rounded border
                        }
                        // Clip only the scrollable content to avoid chips overflowing
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        // TeamCard edge styling
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
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)

                        // No divider to keep sections visually connected
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
    }
}

private struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(tag)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.85)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.chieacPrimary.opacity(0.15) : Color(UIColor.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.chieacPrimary : Color(UIColor.systemGray4), lineWidth: 0)
            )
            .foregroundColor(isSelected ? .chieacPrimary : .chieacTextPrimary)
        }
    }
}

struct ArticlesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let mock = [Article(id: nil, title: "Sample", mediumLink: "https://example.com", imageLink: "https://picsum.photos/400/300", articleTags: ["Mock"]) ]
            ArticlesView(articles: mock)
        }
    }
}
