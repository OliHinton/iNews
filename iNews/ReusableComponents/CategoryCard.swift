//
//  CategoryCard.swift
//  iNews
//
//  Created by Oli Hinton on 25/07/2026.
//

import SwiftUI

struct CategoryCard: View {
    let item: Article
    let onTap: (Article) -> Void
   
    var body: some View {
        Button {
            onTap(item)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: item.urlToImage ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Text("Failed to load image")
                            .foregroundStyle(.primary)
                            .font(.headline)
                            .fontWeight(.semibold)
                    case .empty:
                        Rectangle().fill(.quaternary)
                        Image(systemName: "newspaper")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 220, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)
                    .bold()
                
                Text(item.formattedDate)
                    .foregroundStyle(.secondary)
                
                Text(item.authorDisplay)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 220)
            .padding(10)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue("By \(item.authorDisplay). Published \(item.formattedDate).")
        .accessibilityHint("Opens this article.")
    }
}

#Preview {
    CategoryCard(
        item: Article(
            source: Article.Source(id: nil, name: "BBC"),
            author: "Sarah Mitchell",
            title: "Prime Minister Announces New Green Energy Initiative",
            description: "The government unveiled a major new policy today.",
            url: "https://example.com/article",
            urlToImage: nil,
            publishedAt: "2026-07-22T10:00:00Z",
            content: nil
        ),
        onTap: { _ in },
    )
}
