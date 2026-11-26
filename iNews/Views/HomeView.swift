//
//  ContentView.swift
//  iNews
//
//  Created by Oli Hinton on 24/06/2026.
//

import SwiftUI

struct HomeView: View {
    @State private var homePath = NavigationPath()
    @State private var savedPath = NavigationPath()
    @State private var searchPath = NavigationPath()
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                NavigationStack(path: $homePath) {
                    MainFeedView(path: $homePath)
                        .navigationDestination(for: Route.self) { route in
                        RouteDestinationView(route: route, path: $homePath)}
                }
            }
            
            Tab("Search", systemImage: "magnifyingglass") {
                NavigationStack(path: $searchPath) {
                    SearchView(path: $searchPath)
                        .navigationDestination(for: Route.self) { route in
                        RouteDestinationView(route: route, path: $searchPath)}
                }
            }
            
            Tab("Bookmarked", systemImage: "book.fill") {
                NavigationStack(path: $savedPath) {
                    BookmarksView(path: $savedPath)
                        .navigationDestination(for: Route.self) { route in
                            RouteDestinationView(route: route, path: $savedPath)
                        }
                }
            }
            
            Tab("Settings", systemImage: "gearshape.fill") {
                NavigationStack {
                    SettingsView()
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
