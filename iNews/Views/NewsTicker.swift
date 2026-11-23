//
//  NewsTicker.swift
//  iNews
//
//  Created by Oli Hinton on 16/07/2026.
//
import SwiftData
import SwiftUI

struct NewsTicker: View {
    @Environment(NewsViewModel.self) private var viewModel
    @Environment(\.modelContext) private var context

    var body: some View {
        HStack(spacing: 8) {
            Text("LIVE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            if viewModel.hasError {
                Button {
                    Task { await viewModel.loadArticles(context: context) }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                        
                        Text("Unable to load headlines — tap to retry")
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                
            } else if viewModel.articles.isEmpty {
                Text("Loading headlines…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            
            } else {
                Text(viewModel.articles[viewModel.tickerIndex].title)
                    .font(.subheadline)
                    .lineLimit(1)
                    .transition(.push(from: .trailing))
                    .id(viewModel.tickerIndex)
            }
        }
        .padding(.horizontal)
        .task {
            if viewModel.articles.isEmpty {
                await viewModel.loadArticles(context: context)
            }
            viewModel.startTicker()
        }
        .onDisappear {
            viewModel.stopTicker()
        }
    }
}
#Preview {
    NewsTicker()
}
