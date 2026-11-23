//
//  NewsService.swift
//  iNews
//
//  Created by Oli Hinton on 22/07/2026.
//

import Foundation

actor NewsService: NewsServiceProtocol {
    static let shared = NewsService()
    
    private let session: URLSession
    private var cache: [String: (articles: [Article], timestamp: Date)] = [:]
    private let cacheExpiry: TimeInterval = 300
    private let maxRetries = 3
    
    init(session: URLSession = NewsService.makeSession()) {
        self.session = session
    }
    
    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }
    
    func fetchTopHeadlines(category: Category) async throws -> [Article] {
        let cacheKey = "headlines_\(category.rawValue)"
        
        if let cached = cache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheExpiry {
            return cached.articles
        }
        
        return try await fetchWithRetry(category: category, cacheKey: cacheKey)
    }
    
    func fetchSearchResults(query: String, category: Category) async throws -> [Article] {
        let cacheKey = "search_\(query)_\(category.rawValue)"
        
        if let cached = cache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheExpiry {
            return cached.articles
        }
        
        return try await fetchWithRetry(category: category, query: query, cacheKey: cacheKey)
    }
    
    func clearCache() {
        cache.removeAll()
    }
    
     func fetchWithRetry(category: Category, query: String? = nil, cacheKey: String, attempt: Int = 0) async throws -> [Article] {
        do {
            
            let articles = try await performRequest(category: category, query: query)
            
            cache[cacheKey] = (articles: articles, timestamp: Date())
            
            return articles
            
        } catch NewsError.rateLimited, NewsError.networkError {
            
            if attempt < maxRetries {
                
                let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                
                try await Task.sleep(nanoseconds: delay)
                
                return try await fetchWithRetry(category: category, query: query, cacheKey: cacheKey, attempt: attempt + 1)
            }
            throw NewsError.rateLimited
        }
    }
    
     func performRequest(category: Category, query: String? = nil) async throws -> [Article] {
        var components = URLComponents(string: "\(Config.baseURL)/top-headlines")
        
        var queryItems = [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "category", value: category.apiValue),
            URLQueryItem(name: "pageSize", value: "20"),
            URLQueryItem(name: "apiKey", value: Config.newsAPIKey)
        ]
        
        if let query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NewsError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NewsError.invalidResponse(statusCode: 0)
        }
        
        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw NewsError.unauthorized
        case 429:
            throw NewsError.rateLimited
        case let code:
            throw NewsError.invalidResponse(statusCode: code)
        }
        
        do {
            let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
            
            guard !decoded.articles.isEmpty else { throw NewsError.noResults }
            
            return decoded.articles
            
        } catch let decodingError as DecodingError {
            
            throw NewsError.decodingError(decodingError)
        }
    }
}

