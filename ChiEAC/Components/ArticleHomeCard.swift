//
//  ArticleHomeCard.swift
//  ChiEAC
//
//  Created by Shivaang Kumar on 8/10/25.
//

import SwiftUI

struct ArticleHomeCard: View {
    let article: Article
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: article.imageLink)) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.15).overlay(ProgressView())
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure(_):
                    Color.gray.opacity(0.2).overlay(Image(systemName: "photo").font(.title).foregroundColor(.gray))
                @unknown default:
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 260, height: 150)
            .clipped()
            .cornerRadius(16)
            
            LinearGradient(
                gradient: Gradient(colors: [Color.chieacPrimary.opacity(0.0), Color.chieacPrimary.opacity(0.85)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(16)
            .frame(width: 260, height: 150)
            .allowsHitTesting(false)
            
            Text(article.title)
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .padding(12)
        }
        .frame(width: 260, height: 150)
    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(UIColor.systemGray5), lineWidth: 1))
    }
}

struct ArticleHomeCard_Previews: PreviewProvider {
    static var previews: some View {
        ArticleHomeCard(article: Article.seedData.first!)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
