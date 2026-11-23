//
//  Article.swift
//  iNews
//
//  Created by Oli Hinton on 22/07/2026.
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable, Identifiable, Hashable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    
    var id: String { url }
    
    struct Source: Codable, Hashable {
        let id: String?
        let name: String
    }
    
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: publishedAt) else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: publishedAt) else { return publishedAt }
            return date.formatted(date: .abbreviated, time: .omitted)
        }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
    
    var authorDisplay: String {
        author ?? source.name
    }
}


