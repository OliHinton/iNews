//
//  BookmarksViewModel.swift
//  iNews
//
//  Created by Oli Hinton on 08/08/2026.
//

import Foundation
import Observation
import SwiftData

@Observable
class BookmarksViewModel {
    var bookmarks: [Bookmark] = []
    
    func toggleBookmark(article: Article, category: Category, bookmarks: [Bookmark], context: ModelContext) {
        if let existing = bookmarks.first(where: { $0.url == article.url }) {
            context.delete(existing)
        } else {
            context.insert(Bookmark(from: article, category: category))
        }
    }
    
    func delete(_ bookmarks: [Bookmark], at offsets: IndexSet, context: ModelContext) {
        for index in offsets {
            context.delete(bookmarks[index])
        }
    }
}

