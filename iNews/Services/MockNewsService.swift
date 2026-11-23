//
//  MockNewsService.swift
//  iNews
//
//  Created by Oli Hinton on 22/07/2026.
//

import Foundation

class MockNewsService: NewsServiceProtocol {
    var articlesToReturn: [Article] = []
    var errorToThrow: Error?
    var delayNanoseconds: UInt64 = 0
    
    private(set) var fetchCallCount = 0
    private(set) var clearCacheCallCount = 0
    private(set) var lastCategoryRequested: Category?
    private(set) var lastQueryRequested: String?
    
    func fetchTopHeadlines(category: Category) async throws -> [Article] {
        fetchCallCount += 1
        lastCategoryRequested = category
        if delayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
        
        if let errorToThrow { throw errorToThrow }
        return articlesToReturn
    }
    
    func fetchSearchResults(query: String, category: Category) async throws -> [Article] {
        fetchCallCount += 1
        lastQueryRequested = query
        lastCategoryRequested = category
        
        if let errorToThrow { throw errorToThrow }
        return articlesToReturn
    }
    
    func clearCache() async {
        clearCacheCallCount += 1 
    }
}

