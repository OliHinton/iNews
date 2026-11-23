//
//  DiscoverRow.swift
//  iNews
//
//  Created by Oli Hinton on 25/07/2026.
//

import SwiftUI

struct DiscoverRow: View {
    let article: Article
    let onPressed: (Article) -> Void
    
    var body: some View {
        Button {
            onPressed(article)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                    AsyncImage(url: URL(string: article.urlToImage ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                       ProgressView()
                    }
                    .frame(width: 175, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title)
                        .font(.headline)
                        .lineLimit(2)
                        .bold()
                    
                        Text(article.formattedDate)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    
                        Text(article.authorDisplay)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                }
                .frame(maxWidth: 200, alignment: .leading)
            }
            .padding(10)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(article.title)
        .accessibilityValue("By \(article.authorDisplay). Published \(article.formattedDate).")
        .accessibilityHint("Opens this article.")
    }
}

#Preview {
    DiscoverRow(
        article: Article(
            source: Article.Source(id: nil, name: "BBC"),
            author: "Sarah Mitchell",
            title: "Prime Minister Announces New Green Energy Initiative",
            description: "The government unveiled a major new policy today.",
            url: "https://example.com/article",
            urlToImage: nil,
            publishedAt: "2026-07-22T10:00:00Z",
            content: nil
        ),
        onPressed: { _ in }
    )
}
