//
//  BookmarksErrorStateView.swift
//  iNews
//
//  Created by Oli Hinton on 07/08/2026.
//

import SwiftUI

struct BookmarksErrorStateView: View {
    let message: String
    let onRetry: () async -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Something Went Wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task {
                    await onRetry()
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    BookmarksErrorStateView(
        message: "No internet connection.",
        onRetry: {}
    )
}
