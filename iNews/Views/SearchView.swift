//
//  SearchView.swift
//  iNews
//
//  Created by Oli Hinton on 24/06/2026.
//
import SwiftData
import SwiftUI

struct SearchView: View {
    @Environment(\.modelContext) private var context
    @Environment(NewsViewModel.self) private var viewModel
    @Binding var path: NavigationPath
    @State private var searchText = ""
    @State private var searchVisible = false
    @State private var pillsVisible = false
    @State private var articlesVisible = false

    private var filteredArticles: [Article] {
        guard !searchText.isEmpty else { return viewModel.articles }

        return viewModel.articles.filter { article in
            let matchesTitle = article.title
                .localizedCaseInsensitiveContains(searchText)
            let matchesAuthor = article.author?
                .localizedCaseInsensitiveContains(searchText) ?? false

            return matchesTitle || matchesAuthor
        }
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search articles, topics, sources", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(12)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
                .opacity(searchVisible ? 1 : 0)
                .offset(y: searchVisible ? 0 : -10)

                CategoryPillRow(selectedCategory: $viewModel.selectedCategory)
                    .opacity(pillsVisible ? 1 : 0)
                    .offset(y: pillsVisible ? 0 : 10)

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 50)
                } else if viewModel.hasError {
                    ContentUnavailableView(
                        "Something went wrong",
                        systemImage: "exclamationmark.triangle",
                        description: Text(viewModel.errorMessage ?? "Please try again.")
                    )
                } else if viewModel.articles.isEmpty {
                    ContentUnavailableView(
                        "No Articles",
                        systemImage: "newspaper",
                        description: Text("Try a different category.")
                    )
                } else if filteredArticles.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    DiscoverScrollView(news: filteredArticles, onPressed: { article in
                        path.append(Route.newsDetail(article, viewModel.selectedCategory))
                    })
                    .opacity(articlesVisible ? 1 : 0)
                    .offset(y: articlesVisible ? 0 : 20)
                }
            }
        }
        .task {
            guard viewModel.articles.isEmpty else { return }
            await viewModel.loadArticles(context: context)
        }
        .refreshable {
            await viewModel.refreshArticles(context: context)
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in
            Task { await viewModel.loadArticles(context: context) }
        }
        .navigationTitle("Discover")
        .navigationSubtitle("News articles from all around the world")
        .scrollIndicators(.hidden)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                searchVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                pillsVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                articlesVisible = true
            }
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    SearchView(path: $path)
        .environment(NewsViewModel(service: MockNewsService(), networkMonitor: MockNetworkMonitor()))
}
