//
//  DiscoverScrollView.swift
//  iNews
//
//  Created by Oli Hinton on 25/06/2026.
//

import SwiftUI

struct DiscoverScrollView: View {
    let news: [Article]
    let onPressed: (Article) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(news) { article in
                DiscoverRow(article: article, onPressed: onPressed)
            }
        }
    }
}

#Preview {
    DiscoverScrollView(
        news: [
            Article(
                source: Article.Source(id: nil, name: "BBC"),
                author: "Sarah Mitchell",
                title: "Prime Minister Announces New Green Energy Initiative",
                description: "The government unveiled a major new policy today.",
                url: "https://example.com/article",
                urlToImage: nil,
                publishedAt: "2026-07-22T10:00:00Z",
                content: nil
            )
        ],
        onPressed: { _ in }
    )
}
