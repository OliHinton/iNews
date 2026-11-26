//
//  BookmarkExtension.swift
//  iNews
//
//  Created by Oli Hinton on 08/08/2026.
//

import Foundation

extension Bookmark {
    var asArticle: Article {
        Article(
            source: Article.Source(id: nil, name: sourceName),
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


