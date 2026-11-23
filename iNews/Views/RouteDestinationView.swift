//
//  RouteDestinationView.swift
//  iNews
//
//  Created by Oli Hinton on 02/10/2026.
//

import SwiftUI

struct RouteDestinationView: View {
    let route: Route
    @Binding var path: NavigationPath
    
    var body: some View {
        switch route {
        case .newsDetail(let article, let category):
            NewsDetailedView(article: article, category: category, path: $path)
        case .newsCategory:
            SearchView(path: $path)
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    RouteDestinationView(route: .newsCategory("Business"), path: $path)
}
