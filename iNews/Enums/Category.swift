//
//  Category.swift
//  iNews
//
//  Created by Oli Hinton on 08/08/2026.
//

import Foundation

enum Category: String, CaseIterable, Identifiable {
    case business = "Business"
    case technology = "Technology"
    case sports = "Sports"
    case politics = "Politics"
    case science = "Science"
    case world = "World"
    case lifestyle = "Lifestyle"
    case health = "Health"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
    var apiValue: String {
        switch self {
        case .business: "business"
        case .technology: "technology"
        case .sports: "sports"
        case .politics: "general"
        case .science: "science"
        case .world: "general"
        case .lifestyle: "general"
        case .health: "health"
        }
    }
}
