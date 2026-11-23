//
//  iNewsTests.swift
//  iNewsTests
//
//  Created by Oli Hinton on 24/06/2026.
//

import Testing
import Foundation
import SwiftData
@testable import iNews

@MainActor
struct NewsViewModelTests {

    @Test("Loading articles successfully populates articles and clears loading/error state")
    func loadArticles_success() async {
        let mockService = MockNewsService()
        mockService.articlesToReturn = [.mock(title: "Test Headline")]
        let viewModel = NewsViewModel(
            service: mockService,
            networkMonitor: MockNetworkMonitor(isConnected: true)
        )

        await viewModel.loadArticles()

        #expect(viewModel.articles.count == 1)
        #expect(viewModel.articles.first?.title == "Test Headline")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.hasError == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Loading articles while offline shows a no-internet error and skips the network call")
    func loadArticles_offline() async {
        let mockService = MockNewsService()
        let viewModel = NewsViewModel(
            service: mockService,
            networkMonitor: MockNetworkMonitor(isConnected: false)
        )

        await viewModel.loadArticles()

        #expect(viewModel.hasError == true)
        #expect(viewModel.errorMessage == "No internet connection.")
        #expect(mockService.fetchCallCount == 0)
    }

    @Test("A genuine service failure surfaces an error to the user")
    func loadArticles_genuineFailure() async {
        let mockService = MockNewsService()
        mockService.errorToThrow = NewsError.rateLimited
        let viewModel = NewsViewModel(
            service: mockService,
            networkMonitor: MockNetworkMonitor(isConnected: true)
        )

        await viewModel.loadArticles()

        #expect(viewModel.hasError == true)
        #expect(viewModel.articles.isEmpty)
    }

    @Test("A cancelled URLSession request is treated as benign, not shown as an error")
    func loadArticles_cancelledRequestIsIgnored() async {
        let mockService = MockNewsService()
        mockService.errorToThrow = URLError(.cancelled)
        let viewModel = NewsViewModel(
            service: mockService,
            networkMonitor: MockNetworkMonitor(isConnected: true)
        )

        await viewModel.loadArticles()

        #expect(viewModel.hasError == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("A second overlapping call to loadArticles is ignored while the first is in flight")
    func loadArticles_guardsAgainstReentrancy() async {
        let mockService = MockNewsService()
        mockService.articlesToReturn = [.mock()]
        // Force the mock to genuinely suspend, so the first call is provably
        // still "in flight" (isLoading == true) when the second call runs its guard.
        // Without a real suspension point, the scheduler's interleaving order
        // isn't guaranteed, which makes the test flaky.
        mockService.delayNanoseconds = 50_000_000
        let viewModel = NewsViewModel(
            service: mockService,
            networkMonitor: MockNetworkMonitor(isConnected: true)
        )
        
        let firstTask = Task { await viewModel.loadArticles() }
        
        // Give the first call enough time to pass both guards and reach
        // the artificial delay inside the mock — i.e. to genuinely be "in flight".
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        // This second call should now hit `guard !isLoading else { return }` and bail immediately.
        await viewModel.loadArticles()
        
        // Wait for the first call to actually finish before asserting.
        await firstTask.value
        
        #expect(mockService.fetchCallCount == 1)
    }

    @Test("Refreshing clears the service cache before reloading")
    func refreshArticles_clearsCacheBeforeReload() async {
        let mockService = MockNewsService()
        mockService.articlesToReturn = [.mock()]
        let viewModel = NewsViewModel(
            service: mockService,
            networkMonitor: MockNetworkMonitor(isConnected: true)
        )

        await viewModel.refreshArticles()

        #expect(mockService.clearCacheCallCount == 1)
        #expect(mockService.fetchCallCount == 1)
    }

    @Test("Selecting a new category updates state and fetches that category's articles")
    func selectCategory_fetchesNewCategory() async {
        let mockService = MockNewsService()
        mockService.articlesToReturn = [.mock()]
        let viewModel = NewsViewModel(
            service: mockService,
            networkMonitor: MockNetworkMonitor(isConnected: true)
        )

        await viewModel.selectCategory(.technology)

        #expect(viewModel.selectedCategory == .technology)
        #expect(mockService.lastCategoryRequested == .technology)
    }

    @Test("isConnected reflects whatever the injected network monitor reports")
    func isConnected_reflectsNetworkMonitor() {
        let viewModel = NewsViewModel(
            service: MockNewsService(),
            networkMonitor: MockNetworkMonitor(isConnected: false)
        )

        #expect(viewModel.isConnected == false)
    }
}

@MainActor
struct BookmarksViewModelTests {
 
    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([Bookmark.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }
 
    @Test("Toggling bookmark on an unbookmarked article inserts a new Bookmark")
    func toggleBookmark_insertsWhenNotBookmarked() throws {
        let context = try makeInMemoryContext()
        let viewModel = BookmarksViewModel()
        let article = Article.mock(title: "New Story", url: "https://example.com/new-story")
 
        viewModel.toggleBookmark(article: article, category: .world, bookmarks: [], context: context)
 
        let saved = try context.fetch(FetchDescriptor<Bookmark>())
        #expect(saved.count == 1)
        #expect(saved.first?.url == "https://example.com/new-story")
        #expect(saved.first?.category == .world)
    }
 
    @Test("Toggling bookmark on an already-bookmarked article removes it")
    func toggleBookmark_removesWhenAlreadyBookmarked() throws {
        let context = try makeInMemoryContext()
        let viewModel = BookmarksViewModel()
        let article = Article.mock(title: "Existing Story", url: "https://example.com/existing")
        let existing = Bookmark(from: article, category: .business)
        context.insert(existing)
 
        viewModel.toggleBookmark(
            article: article,
            category: .business,
            bookmarks: [existing],
            context: context
        )
 
        let saved = try context.fetch(FetchDescriptor<Bookmark>())
        #expect(saved.isEmpty)
    }
 
    @Test("Deleting at an offset removes the correct bookmark and leaves the rest untouched")
    func delete_removesCorrectBookmark() throws {
        let context = try makeInMemoryContext()
        let viewModel = BookmarksViewModel()
        let first = Bookmark(from: .mock(title: "First", url: "https://example.com/1"), category: .health)
        let second = Bookmark(from: .mock(title: "Second", url: "https://example.com/2"), category: .health)
        context.insert(first)
        context.insert(second)
 
        viewModel.delete([first, second], at: IndexSet(integer: 0), context: context)
 
        let saved = try context.fetch(FetchDescriptor<Bookmark>())
        #expect(saved.count == 1)
        #expect(saved.first?.url == "https://example.com/2")
    }
 
    @Test("Deleting multiple offsets removes all the targeted bookmarks")
    func delete_removesMultipleBookmarks() throws {
        let context = try makeInMemoryContext()
        let viewModel = BookmarksViewModel()
        let bookmarks = (0..<3).map {
            Bookmark(from: .mock(title: "Story \($0)", url: "https://example.com/\($0)"), category: .world)
        }
        bookmarks.forEach { context.insert($0) }
 
        viewModel.delete(bookmarks, at: IndexSet([0, 2]), context: context)
 
        let saved = try context.fetch(FetchDescriptor<Bookmark>())
        #expect(saved.count == 1)
        #expect(saved.first?.url == "https://example.com/1")
    }
}

@MainActor
struct NotificationsViewModelTests {
 
    @Test("Enabling notifications when permission is granted schedules them and shows no alert")
    func handleToggle_permissionGranted() async {
        let mockManager = MockNotificationManager()
        mockManager.shouldGrantPermission = true
        let viewModel = NotificationsViewModel(notificationManager: mockManager)
 
        await viewModel.handleToggle(true)
 
        #expect(mockManager.requestPermissionCallCount == 1)
        #expect(mockManager.scheduleCallCount == 1)
        #expect(viewModel.showingPermissionAlert == false)
    }
 
    @Test("Enabling notifications when permission is denied reverts the toggle and shows an alert")
    func handleToggle_permissionDenied() async {
        let mockManager = MockNotificationManager()
        mockManager.shouldGrantPermission = false
        let viewModel = NotificationsViewModel(notificationManager: mockManager)
 
        await viewModel.handleToggle(true)
 
        #expect(viewModel.notificationsEnabled == false)
        #expect(viewModel.showingPermissionAlert == true)
        #expect(mockManager.scheduleCallCount == 0)
    }
 
    @Test("Disabling notifications cancels any pending notifications")
    func handleToggle_disabling() async {
        let mockManager = MockNotificationManager()
        let viewModel = NotificationsViewModel(notificationManager: mockManager)
 
        await viewModel.handleToggle(false)
 
        #expect(mockManager.cancelCallCount == 1)
    }
 
    @Test("Rescheduling notifications forwards the new time to the notification manager")
    func rescheduleNotifications_forwardsNewTime() {
        let mockManager = MockNotificationManager()
        let viewModel = NotificationsViewModel(notificationManager: mockManager)
        let newTime = Date(timeIntervalSince1970: 1_000_000)
 
        viewModel.rescheduleNotifications(at: newTime)
 
        #expect(mockManager.scheduleCallCount == 1)
        #expect(mockManager.lastScheduledDate == newTime)
    }
 
    @Test("Refreshing authorization status syncs notificationsEnabled with the system value")
    func refreshAuthorizationStatus_syncsState() async {
        let mockManager = MockNotificationManager()
        mockManager.isAuthorized = true
        let viewModel = NotificationsViewModel(notificationManager: mockManager)
 
        await viewModel.refreshAuthorizationStatus()
 
        #expect(viewModel.notificationsEnabled == true)
    }
}

struct HelperExtensionTests {

    @Test("nonEmpty returns nil for an empty string")
    func nonEmpty_emptyString() {
        #expect("".nonEmpty == nil)
    }

    @Test("nonEmpty returns the original value for a non-empty string")
    func nonEmpty_nonEmptyString() {
        #expect("Hello".nonEmpty == "Hello")
    }

    @Test("Bookmark converts back into an equivalent Article")
    func bookmark_asArticle_roundTrips() {
        let article = Article.mock(
            title: "Round Trip",
            author: "A. Writer",
            url: "https://example.com/round-trip"
        )
        let bookmark = Bookmark(from: article, category: .science)

        let converted = bookmark.asArticle

        #expect(converted.title == article.title)
        #expect(converted.author == article.author)
        #expect(converted.url == article.url)
    }

    @Test("Bookmark exposes the category it was saved under")
    func bookmark_categoryRoundTrips() {
        let bookmark = Bookmark(from: .mock(), category: .sports)
        #expect(bookmark.category == .sports)
    }

    @Test("An unrecognized stored category value falls back to a safe default")
    func bookmark_category_fallsBackOnInvalidRawValue() {
        let bookmark = Bookmark(from: .mock(), category: .health)
        bookmark.categoryRawValue = "NotARealCategory"

        #expect(bookmark.category == .business)
    }
}
