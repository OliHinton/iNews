//
//  NewsViewModel.swift
//  iNews
//
//  Created by Oli Hinton on 22/07/2026.
//

import Foundation
import Observation
import SwiftUI
import SwiftData

@MainActor
@Observable
class NewsViewModel {
    var articles: [Article] = []
    var isLoading = false
    var errorMessage: String?
    var hasError = false
    var selectedCategory: Category = .business
    var tickerIndex = 0
    var isShowingCachedData = false
    var cacheTimestamp: Date?
    var relatedArticles: [Article] = []
    var isLoadingRelated = false
    
    private let service: NewsServiceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    private var tickerTask: Task<Void, Never>?
    
    var isConnected: Bool {
        networkMonitor.isConnected
    }
    
      init(
          service: NewsServiceProtocol? = nil,
          networkMonitor: NetworkMonitorProtocol? = nil
      ) {
          self.service = service ?? NewsService.shared
          self.networkMonitor = networkMonitor ?? NetworkMonitor.shared
      }
    
    func fetchArticles(for category: Category) async -> [Article] {
        (try? await service.fetchTopHeadlines(category: category)) ?? []
    }
    
    func recordView(article: Article, category: Category, context: ModelContext) {
           let articleURL = article.url
           let descriptor = FetchDescriptor<ViewedArticle>(
               predicate: #Predicate { $0.url == articleURL })
        
           if let existing = try? context.fetch(descriptor).first {
               context.delete(existing)
           }
           context.insert(ViewedArticle(from: article, category: category))
       }

    func loadArticles(context: ModelContext) async {
        guard !isLoading else { return }
        
        guard networkMonitor.isConnected else {
            loadCachedArticles(context: context)
            if articles.isEmpty {
                errorMessage = "No internet connection."
                hasError = true
            }
            return
        }
        
        isLoading = true
        hasError = false
        errorMessage = nil
        
        do {
            let fetched = try await service.fetchTopHeadlines(category: selectedCategory)
            articles = fetched
            cacheArticles(fetched, context: context)
        } catch {
            if (error as? URLError)?.code == .cancelled {
            } else {
                loadCachedArticles(context: context)
                if articles.isEmpty {
                    errorMessage = (error as? NewsError)?.errorDescription ?? error.localizedDescription
                    hasError = true
                }
            }
        }
        isLoading = false
    }
    
    func refreshArticles(context: ModelContext) async {
        await service.clearCache()
        await loadArticles(context: context)
    }
    
    func selectCategory(_ category: Category, context: ModelContext) async {
        selectedCategory = category
        await loadArticles(context: context)
    }
    
    func loadCachedArticles(context: ModelContext) {
        let category = selectedCategory.rawValue
        let descriptor = FetchDescriptor<CachedArticle>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )
        let cached = (try? context.fetch(descriptor)) ?? []
        articles = cached.map(\.asArticle)
        isShowingCachedData = !cached.isEmpty
        cacheTimestamp = cached.first?.cachedAt
    }

    func cacheArticles(_ articles: [Article], context: ModelContext) {
        let category = selectedCategory
        let categoryRaw = category.rawValue
        
        let descriptor = FetchDescriptor<CachedArticle>(predicate: #Predicate { $0.category == categoryRaw })
        if let existing = try? context.fetch(descriptor) {
            existing.forEach { context.delete($0) }
        }
        
        for article in articles {
            context.insert(CachedArticle(from: article, category: category))
        }
    }
    
    func startTicker(interval: TimeInterval = 4) {
            tickerTask?.cancel()
            tickerTask = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(interval))
                    guard !Task.isCancelled, !articles.isEmpty else { continue }
                    withAnimation(.easeInOut) {
                        tickerIndex = (tickerIndex + 1) % articles.count
                    }
                }
            }
        }

        func stopTicker() {
            tickerTask?.cancel()
            tickerTask = nil
        }
    
    func loadRelatedArticles(for category: Category, excluding article: Article, limit: Int = 10) async {
        isLoadingRelated = true
        defer { isLoadingRelated = false }
        
        let fetched = await fetchArticles(for: category)
        relatedArticles = Array(
            fetched.filter { $0.url != article.url }
                .prefix(limit)
        )
    }
}
