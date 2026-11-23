//
//  CategoryPill.swift
//  iNews
//
//  Created by Oli Hinton on 25/07/2026.
//

import SwiftUI

struct CategoryPill: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onTap()
            }
        } label: {
            Text(category.title)
                .padding(10)
                .background(isSelected ? Color.gray : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .font(.headline)
                .fontWeight(.semibold)
                .overlay(Capsule().strokeBorder(lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(category.title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Filters the news by \(category.title).")
    }
}

#Preview {
    CategoryPill(category: .business, isSelected: false, onTap: { })
}
