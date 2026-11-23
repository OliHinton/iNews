//
//  CategoryScrollView.swift
//  iNews
//
//  Created by Oli Hinton on 24/06/2026.
//

import SwiftUI

struct CategoryScrollView: View {
    let items: [Article]
    let onTap: (Article) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        CategoryCard(item: item, onTap: onTap)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    CategoryScrollView(
        items: [
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
        onTap: { _ in }
    )
}



