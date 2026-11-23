//
//  Bookmark.swift
//  iNews
//
//  Created by Oli Hinton on 05/08/2026.
//

import Foundation
import SwiftData

@Model
final class Bookmark {
    @Attribute(.unique) var url: String
    var title: String
    var author: String?
    var sourceName: String
    var articleDescription: String?
    var urlToImage: String?
    var publishedAt: String
    var content: String?
    var categoryRawValue: String

    var category: Category {
        Category(rawValue: categoryRawValue) ?? .business
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

    init(from article: Article, category: Category) {
        self.url = article.url
        self.title = article.title
        self.author = article.author
        self.sourceName = article.source.name
        self.articleDescription = article.description
        self.urlToImage = article.urlToImage
        self.publishedAt = article.publishedAt
        self.content = article.content
        self.categoryRawValue = category.rawValue
    }

    init(
        url: String,
        title: String,
        author: String? = nil,
        sourceName: String,
        articleDescription: String? = nil,
        urlToImage: String? = nil,
        publishedAt: String,
        content: String? = nil,
        category: Category = .world
    ) {
        self.url = url
        self.title = title
        self.author = author
        self.sourceName = sourceName
        self.articleDescription = articleDescription
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.content = content
        self.categoryRawValue = category.rawValue
    }
}
