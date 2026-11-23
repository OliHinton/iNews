//
//  ViewedArticle.swift
//  iNews
//
//  Created by Oli Hinton on 12/08/2026.
//

import Foundation
import SwiftData

@Model
final class ViewedArticle {
    @Attribute(.unique) var url: String
    var title: String
    var author: String?
    var sourceName: String
    var articleDescription: String?
    var urlToImage: String?
    var publishedAt: String
    var content: String?
    var categoryRawValue: String
    var viewedAt: Date
    
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
        self.viewedAt = .now
    }
    
    var category: Category { Category(rawValue: categoryRawValue) ?? .world }
    
    var asArticle: Article {
         Article(
             source: Article.Source(id: nil, name: sourceName),
             author: author, title: title, description: articleDescription,
             url: url, urlToImage: urlToImage, publishedAt: publishedAt, content: content
         )
     }
}
