//
//  CategoryPillRow.swift
//  iNews
//
//  Created by Oli Hinton on 25/07/2026.
//

import SwiftUI

struct CategoryPillRow: View {
    @Binding var selectedCategory: Category
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(Category.allCases) { category in
                    CategoryPill(
                        category: category,
                        isSelected: selectedCategory == category,
                        onTap: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    @Previewable @State var selectedCategory: Category = .business
    CategoryPillRow(selectedCategory: $selectedCategory)
}
