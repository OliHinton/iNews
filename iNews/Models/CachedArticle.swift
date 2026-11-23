//
//  CachedArticle.swift
//  iNews
//
//  Created by Oli Hinton on 03/10/2026.
//

import Foundation
import SwiftData

@Model
final class CachedArticle {
    var url: String
    var title: String
    var articleDescription: String?
    var urlToImage: String?
    var author: String?
    var publishedAt: String
    var content: String?
    var sourceId: String?
    var sourceName: String
    var category: String
    var cachedAt: Date
    
    init(from article: Article, category: Category, cachedAt: Date = .now) {
        self.url = article.url
        self.title = article.title
        self.articleDescription = article.description
        self.urlToImage = article.urlToImage
        self.author = article.author
        self.publishedAt = article.publishedAt
        self.content = article.content
        self.sourceId = article.source.id
        self.sourceName = article.source.name
        self.category = category.rawValue
        self.cachedAt = cachedAt
    }
    
    var asArticle: Article {
        Article(
            source: Article.Source(id: sourceId, name: sourceName),
            author: author,
            title: title,
            description: articleDescription,
            url: url,
            urlToImage: urlToImage,
            publishedAt: publishedAt,
            content: content
        )
    }
}
