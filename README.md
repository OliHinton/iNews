iNews
A SwiftUI news app for keeping up with the latest headlines. Browse by category, search for articles, save favourites, and pick up where you left off with recently viewed articles

Features
Latest news, loaded from [NewsAPI](https://newsapi.org)
Categories: filter the feed by topic
Search across articles
Favourites: save articles to read later, stored with SwiftData
Recently viewed: pick up where you left off
Loading, error and empty states, so the app never just shows a blank screen
Accessibility: VoiceOver labels and hints throughout

Tech
SwiftUI · Swift Concurrency (async/await) · SwiftData · Observation (@Observable) · Swift Testing

Architecture
The app follows MVVM, with networking behind a protocol

Design decisions
API struct vs SwiftData model. Article is a lightweight Codable struct for data from the API. Only what the app owns, like favourites, is persisted, as a separate Bookmark model.
SwiftData vs UserDefaults. SwiftData holds structured data that grows and needs searching or sorting, like favourites and history. UserDefaults is only for small settings.
Service behind a protocol. The view models depend on a protocol, not the real service, so tests and previews can inject a mock instead of calling the network.
The API key stays out of the repository. It lives in a git-ignored Config.swift (see Setup below).


Setup
The API key isn't included in this repository. To run the app:
Get a free API key from [NewsAPI](https://newsapi.org).
Create iNews/Endpoints/Config.swift:
swift
enum Config {
    static let apiKey = "YOUR_KEY_HERE"
}

