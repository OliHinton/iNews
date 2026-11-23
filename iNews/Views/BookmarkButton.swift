//
//  BookmarkButton.swift
//  iNews
//
//  Created by Oli Hinton on 16/07/2026.
//

import SwiftUI
import SwiftData

struct BookmarkButton: View {
       let article: Article
       let category: Category
       @Environment(\.modelContext) private var context
       @Environment(BookmarksViewModel.self) private var viewModel
       @Query private var bookmarks: [Bookmark]

       var isBookmarked: Bool {
           bookmarks.contains { $0.url == article.url }
       }
    
    var body: some View {
        Button {
            viewModel.toggleBookmark(article: article, category: category, bookmarks: bookmarks, context: context)
        } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
        }
        .accessibilityLabel("Bookmark")
        .accessibilityValue(isBookmarked ? "Saved" : "Not saved")
        .accessibilityHint(
            isBookmarked
            ? "Removes this item from your bookmarks."
            : "Adds this item to your bookmarks."
        )
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack {
        NewsDetailedView(
            article: Article(
                source: Article.Source(id: nil, name: "BBC"),
                author: "Sarah Mitchell",
                title: "Prime Minister Announces New Green Energy Initiative",
                description: "The government unveiled a major new policy today aimed at reducing carbon emissions.",
                url: "https://example.com/article",
                urlToImage: nil,
                publishedAt: "2026-07-22T10:00:00Z",
                content: nil
            ),
            category: .politics, path: $path
        )
    }
    .modelContainer(for: Bookmark.self, inMemory: true)
}
