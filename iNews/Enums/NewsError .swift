//
//  NewsError .swift
//  iNews
//
//  Created by Oli Hinton on 22/07/2026.
//

import Foundation

enum NewsError: LocalizedError {
    case invalidURL
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case noResults
    case rateLimited
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please try again."
        case .invalidResponse(let code):
            return "Server error (\(code)). Please try again later."
        case .decodingError:
            return "Failed to parse news data."
        case .networkError:
            return "No internet connection. Please check your network."
        case .noResults:
            return "No articles found."
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .unauthorized:
            return "Invalid API key."
        }
    }
}
