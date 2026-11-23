//
//  NewsDetailedView.swift
//  iNews
//
//  Created by Oli Hinton on 25/06/2026.
//

import SwiftUI
import SwiftData

struct NewsDetailedView: View {
    let article: Article
    let category: Category
    @State private var heroVisible = false
    @State private var metaVisible = false
    @State private var contentVisible = false
    @State private var relatedArticles: [Article] = []
    @State private var isLoadingRelated = false
    @Environment(NewsViewModel.self) private var viewModel
    @Environment(\.modelContext) private var context
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                Color.gray.opacity(0.15)
                    .frame(height: 250)
                    .overlay {
                        if let imageUrlString = article.urlToImage, let url = URL(string: imageUrlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    Image(systemName: category.placeholderIcon)
                                        .font(.largeTitle)
                                        .foregroundStyle(category.placeholderColor)
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: category.placeholderIcon)
                                .font(.largeTitle)
                                .foregroundStyle(category.placeholderColor)
                        }
                    }
                    .clipped()

                VStack(alignment: .leading, spacing: 8) {
                    Text(category.title)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .font(.caption)
                        .fontWeight(.bold)
                        .background(Color.gray.opacity(0.15))
                        .foregroundStyle(.gray)
                        .clipShape(Capsule())

                    Text(article.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            .padding(.top, 8)
            .opacity(heroVisible ? 1 : 0)
            .scaleEffect(heroVisible ? 1 : 0.95)

            HStack(spacing: 8) {
                if let author = article.author, !author.isEmpty {
                    Text(author)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .font(.caption)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(Capsule())
                }

                Text(article.formattedDate)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .font(.caption)
                    .background(Color.gray.opacity(0.12))
                    .clipShape(Capsule())

                Spacer()
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .opacity(metaVisible ? 1 : 0)

            VStack(alignment: .leading, spacing: 8) {
                Text(article.description?.nonEmpty ?? "No description available. Tap below to read the full article.")
                    .font(.body)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .padding(.vertical, 8)

                if let url = URL(string: article.url) {
                    Link(destination: url) {
                        HStack {
                            Text("Read full article on \(article.source.name)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .foregroundStyle(.primary)

                    ShareLink(item: url) {
                        Label("Share Article", systemImage: "square.and.arrow.up")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
            .opacity(contentVisible ? 1 : 0)

            if isLoadingRelated {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if !relatedArticles.isEmpty {
                RelatedArticlesSection(
                    articles: relatedArticles,
                    category: category,
                    onSelected: { selected in
                        path.append(Route.newsDetail(selected, category))
                    }
                )
                .opacity(contentVisible ? 1 : 0)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                BookmarkButton(article: article, category: category)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { heroVisible = true }
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) { metaVisible = true }
            withAnimation(.easeOut(duration: 0.4).delay(0.35)) { contentVisible = true }
        }
        .task {
            isLoadingRelated = true
            let fetched = await viewModel.fetchArticles(for: category)
            relatedArticles = fetched
                .filter { $0.url != article.url }
                .prefix(10)
                .map { $0 }
            isLoadingRelated = false
        }
        .task {
            viewModel.recordView(article: article, category: category, context: context)
        }
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
}


