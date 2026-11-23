//
//  BookmarkListView.swift
//  iNews
//
//  Created by Oli Hinton on 05/08/2026.
//

import SwiftUI

struct BookmarksListView: View {
    let bookmarks: [Bookmark]
    let isVisible: Bool
    let onDelete: (IndexSet) -> Void
    @Binding var path: NavigationPath
    
    var body: some View {
        List {
            ForEach(bookmarks) { bookmark in
                BookmarkRow(bookmark: bookmark, onSelected: { selected in
                    path.append(Route.newsDetail(selected.asArticle, selected.category))
                })
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
            }
            .onDelete(perform: onDelete)
        }
        .listStyle(.plain)
        .transition(.opacity)
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    BookmarksListView(
        bookmarks: [
            Bookmark(
                url: "https://apple.com",
                title: "SwiftUI Preview Tip",
                sourceName: "Apple Developer",
                publishedAt: "2026-08-05"
            )
        ],
        isVisible: true,
        onDelete: { _ in },
        path: $path
    )
}

