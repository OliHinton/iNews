//
//  BookmarksView.swift
//  iNews
//
//  Created by Oli Hinton on 16/07/2026.
//

import SwiftUI
import SwiftData

struct BookmarksView: View {
    @Query private var bookmarks: [Bookmark]
    @Environment(\.modelContext) private var context
    @Environment(NewsViewModel.self) private var viewModel
    @Environment(BookmarksViewModel.self) private var bookmarksViewModel
    @State private var listVisible = false
    @Binding var path: NavigationPath
    
    var body: some View {
        Group {
            if viewModel.hasError {
                BookmarksErrorStateView(message: viewModel.errorMessage ?? "Please try again.",
                onRetry: {
                    await viewModel.refreshArticles(context: context)
                })
                .transition(.opacity)
                
            } else if bookmarks.isEmpty {
                ContentUnavailableView(
                    "No Bookmarks",
                    systemImage: "bookmark",
                    description: Text("Articles you save will appear here")
                )
                .transition(.opacity)
            } else {
                BookmarksListView(
                    bookmarks: bookmarks,
                    isVisible: listVisible,
                    onDelete: { offsets in
                        withAnimation {
                            bookmarksViewModel.delete(bookmarks, at: offsets, context: context)}},
                    path: $path
                )
            }
        }
        .navigationTitle("Bookmarks")
        .refreshable {
            await viewModel.refreshArticles(context: context)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                listVisible = true
            }
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    BookmarksView(path: $path)
        .modelContainer(for: Bookmark.self, inMemory: true)
}
