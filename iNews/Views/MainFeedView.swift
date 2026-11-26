//
//  MainFeedView.swift
//  iNews
//
//  Created by Oli Hinton on 24/06/2026.
//
import SwiftUI
import SwiftData

struct MainFeedView: View {
    let category: Category
    @Binding var path: NavigationPath
    
    @State private var heroVisible = false
    @State private var contentVisible = false
    
    @Environment(NewsViewModel.self) private var viewModel
    @Environment(\.modelContext) private var context
    @Query(sort: \ViewedArticle.viewedAt, order: .reverse) private var recentlyViewed: [ViewedArticle]
    
    var featuredArticle: Article? {
        viewModel.articles.first
    }
    
    var body: some View {
        ScrollView(.vertical) {
            if viewModel.articles.isEmpty && !viewModel.isLoading {
                Group {
                    if !viewModel.isConnected {
                        ContentUnavailableView(
                            "No Internet Connection",
                            systemImage: "wifi.slash",
                            description: Text("Check your connection and try again.")
                        )
                    } else if viewModel.hasError {
                        ContentUnavailableView(
                            "Something Went Wrong",
                            systemImage: "exclamationmark.triangle",
                            description: Text(viewModel.errorMessage ?? "Please try again.")
                        )
                    } else {
                        ContentUnavailableView(
                            "No Articles",
                            systemImage: "newspaper",
                            description: Text("Check back later for the latest news")
                        )
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 500)
            } else {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ZStack {
                        if let urlString = featuredArticle?.urlToImage, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    Text("Failed to load image")
                                        .foregroundStyle(.primary)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                case .empty:
                                    Image(systemName: viewModel.selectedCategory.placeholderIcon)
                                        .font(.largeTitle)
                                        .foregroundStyle(viewModel.selectedCategory.placeholderColor)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: viewModel.selectedCategory.placeholderIcon)
                                .font(.largeTitle)
                                .foregroundStyle(viewModel.selectedCategory.placeholderColor)
                        }
                        
                        if let featuredArticle {
                            Button {
                                path.append(Route.newsDetail(featuredArticle, viewModel.selectedCategory))
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Spacer()
                                    Text("News of the day")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                    
                                    Text(featuredArticle.title)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .lineLimit(2)
                                        .shadow(color: .black.opacity(0.7), radius: 3)
                                    
                                    HStack(alignment: .bottom) {
                                        Text("More info")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.body)
                                    }
                                    .foregroundStyle(.white)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            }
                            .buttonStyle(.plain)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("News of the day. \(featuredArticle.title)")
                            .accessibilityHint("Opens today's featured news story.")
                            .accessibilityIdentifier("featuredArticleButton")
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    .opacity(heroVisible ? 1 : 0)
                    .offset(y: heroVisible ? 0 : 30)
                    
                    NewsTicker()
                        .padding(.vertical, 8)
                        .opacity(contentVisible ? 1 : 0)
                    
                    HStack {
                        Text("Breaking News")
                            .font(.title2)
                        
                        Spacer()
                        
                        Button {
                            path.append(Route.newsCategory(viewModel.selectedCategory.rawValue))
                        } label: {
                            Text("More")
                                .font(.headline)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(10)
                    .bold()
                    .opacity(contentVisible ? 1 : 0)
                    .offset(y: contentVisible ? 0 : 10)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 50)
                    } else {
                        CategoryScrollView(items: viewModel.articles, onTap: { article in
                            path.append(Route.newsDetail(article, viewModel.selectedCategory))
                        }, category: category)
                        .opacity(contentVisible ? 1 : 0)
                        .offset(y: contentVisible ? 0 : 20)
                        
                        if !recentlyViewed.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Continue Reading")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal, 10)
                                    .padding(.top, 16)

                                CategoryScrollView(
                                    items: recentlyViewed.prefix(10).map(\.asArticle),
                                    onTap: { article in
                                        path.append(Route.newsDetail(article, viewModel.selectedCategory))
                                    }
                                )
                            }
                            .opacity(contentVisible ? 1 : 0)
                            .offset(y: contentVisible ? 0 : 20)
                        }
                    }
                }
            }
        }
        .navigationTitle("iNews")
        .scrollIndicators(.hidden)
        .task {
            await viewModel.loadArticles(context: context)
        }
        .refreshable {
            await viewModel.refreshArticles(context: context)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                heroVisible = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentVisible = true
            }
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    MainFeedView(category: .business, path: $path)
        .environment(NewsViewModel(service: MockNewsService(), networkMonitor: MockNetworkMonitor()))
}
