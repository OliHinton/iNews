//
//  RelatedArticleCard.swift
//  iNews
//
//  Created by Oli Hinton on 06/08/2026.
//

import SwiftUI

struct RelatedArticleCard: View {
    let article: Article
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Color.gray.opacity(0.15)
                    .frame(width: 220, height: 130)
                    .overlay {
                        if let imageUrlString = article.urlToImage,
                           let url = URL(string: imageUrlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure, .empty:
                                    Image(systemName: "photo")
                                        .foregroundStyle(.secondary)
                                default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .clipped()

                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(width: 220, alignment: .leading)

                if let author = article.author, !author.isEmpty {
                    Text(author)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .frame(width: 220, alignment: .leading)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(article.title)
        .accessibilityHint("Opens this article")
    }
}

#Preview {
    RelatedArticleCard(article:     Article(
        source: Article.Source(id: nil, name: "Reuters"),
        author: "James Carter",
        title: "Tech Giants Report Record Quarterly Earnings Amid Market Growth",
        description: "Several major companies posted strong results.",
        url: "https://example.com/article-2",
        urlToImage: nil,
        publishedAt: "2026-07-21T09:30:00Z",
        content: nil
    ), onTap: { })
}
