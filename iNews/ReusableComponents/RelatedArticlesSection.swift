//
//  RelatedArticlesSection.swift
//  iNews
//
//  Created by Oli Hinton on 06/08/2026.
//

import SwiftUI

struct RelatedArticlesSection: View {
    let articles: [Article]
    let category: Category
    let onSelected: (Article) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("More in \(category.title)")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(articles, id: \.url) { related in
                        RelatedArticleCard(article: related) {
                            onSelected(related)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 30)
    }
}
#Preview {
    RelatedArticlesSection(
        articles: [
            Article(
                source: Article.Source(id: nil, name: "Reuters"),
                author: "James Carter",
                title: "Tech Giants Report Record Quarterly Earnings Amid Market Growth",
                description: "Several major companies posted strong results.",
                url: "https://example.com/article-2",
                urlToImage: nil,
                publishedAt: "2026-07-21T09:30:00Z",
                content: nil
            )],
        category: .business,
        onSelected: { _ in }
    )
}
