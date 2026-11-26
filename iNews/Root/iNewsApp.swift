//
//  iNewsApp.swift
//  iNews
//
//  Created by Oli Hinton on 24/06/2026.
//

import SwiftUI
import SwiftData

@main
struct iNewsApp: App {
    @State private var newsViewModel = NewsViewModel()
    @State private var notificationsViewModel = NotificationsViewModel()
    @State private var bookmarksViewModel = BookmarksViewModel()
 
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(newsViewModel)
                .environment(notificationsViewModel)
                .environment(bookmarksViewModel)
        }
        .modelContainer(for: [Bookmark.self, ViewedArticle.self, CachedArticle.self])
    }
}
