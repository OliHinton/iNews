//
//  Navigation.swift
//  iNews
//
//  Created by Oli Hinton on 08/08/2026.
//

import Foundation

enum Route: Hashable {
    case newsDetail(Article, Category)
    case newsCategory(String)
}
