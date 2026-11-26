//
//  BookmarkRow.swift
//  iNews
//
//  Created by Oli Hinton on 05/08/2026.
//

import SwiftUI

struct BookmarkRow: View {
    let bookmark: Bookmark
    let onSelected: (Bookmark) -> Void
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onSelected(bookmark)
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: bookmark.urlToImage ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(.quaternary)
                    Image(systemName: "newspaper")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 175, height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(bookmark.title)
                        .font(.headline)
                        .lineLimit(2)
                        .bold()
                    
                    Text(bookmark.formattedDate)
                        .foregroundStyle(.secondary)
                    
                    Text(bookmark.author ?? "")
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(bookmark.title), by \(bookmark.author ?? "Unknown author"), \(bookmark.publishedAt)")
        .accessibilityHint("Swipe left to delete")
    }
}

#Preview {
    BookmarkRow(
        bookmark: Bookmark(
            url: "https://apple.com",
            title: "Swift Preview Example",
            sourceName: "Tech News",
            publishedAt: "2026-08-05"
        ), onSelected: { _ in }
    )
}
