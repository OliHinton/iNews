//
//  iNewsUITests.swift
//  iNewsUITests
//
//  Created by Oli Hinton on 24/06/2026.
//

import XCTest

final class NewsAppUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testAllTabsAreReachable() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should appear on launch")

        for tabName in ["Home", "Search", "Bookmarked", "Settings"] {
            let tab = tabBar.buttons[tabName]
            XCTAssertTrue(tab.exists, "\(tabName) tab should exist")
            tab.tap()
        }
    }

    @MainActor
    func testSettingsTabShowsNotificationsSection() throws {
        app.tabBars.buttons["Settings"].tap()

        let notificationsHeader = app.staticTexts["Notifications"]
        XCTAssertTrue(notificationsHeader.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSearchFieldAcceptsTextInput() throws {
        app.tabBars.buttons["Search"].tap()

        let searchField = app.textFields["Search articles, topics, sources"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))

        searchField.tap()
        searchField.typeText("technology")

        XCTAssertEqual(searchField.value as? String, "technology")
    }

    @MainActor
    func testSearchingForUnlikelyTermShowsNoResultsState() throws {
        app.tabBars.buttons["Search"].tap()

        let searchField = app.textFields["Search articles, topics, sources"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))

        searchField.tap()
        searchField.typeText("zzzznonexistentqueryxyz")

        // ContentUnavailableView.search(text:) renders a "No results" style message.
        let noResults = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "No results")
        ).firstMatch
        XCTAssertTrue(noResults.waitForExistence(timeout: 5))
    }

    @MainActor
    func testBookmarkedTabShowsEmptyStateWithNoSavedArticles() throws {
        app.tabBars.buttons["Bookmarked"].tap()

        // Only reliable if the simulator has no prior bookmarks saved —
        // see note below about resetting state for deterministic runs.
        let emptyState = app.staticTexts["No Bookmarks"]
        XCTAssertTrue(emptyState.waitForExistence(timeout: 5))
    }

    @MainActor
    func testTappingBookmarkOnAnArticleAddsItToBookmarksTab() throws {
        app.tabBars.buttons["Home"].tap()

        let firstArticle = app.buttons["featuredArticleButton"]
        XCTAssertTrue(firstArticle.waitForExistence(timeout: 15), "Featured article should load")
        firstArticle.tap()

        let bookmarkButton = app.buttons["Bookmark"]
        XCTAssertTrue(bookmarkButton.waitForExistence(timeout: 5))
        bookmarkButton.tap()

        app.navigationBars.buttons.firstMatch.tap() // back
        app.tabBars.buttons["Bookmarked"].tap()

        // With at least one bookmark saved, the empty state should be gone.
        let emptyState = app.staticTexts["No Bookmarks"]
        XCTAssertFalse(emptyState.exists)
    }
}


