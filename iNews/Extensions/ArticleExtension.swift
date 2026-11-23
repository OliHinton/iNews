//
//  ArticleExtension.swift
//  iNews
//
//  Created by Oli Hinton on 21/08/2026.
//

import Foundation

extension Article {
   static func mock(
       title: String = "Sample Headline",
       author: String? = "Jane Reporter",
       description: String? = "A sample description.",
       url: String = "https://example.com/\(UUID().uuidString)",
       urlToImage: String? = nil,
       publishedAt: String = "2026-08-01T09:00:00Z",
       content: String? = nil,
       sourceName: String = "Test Source"
   ) -> Article {
       Article(
           source: Article.Source(id: nil, name: sourceName),
           author: author,
           title: title,
           description: description,
           url: url,
           urlToImage: urlToImage,
           publishedAt: publishedAt,
           content: content
       )
   }
}
