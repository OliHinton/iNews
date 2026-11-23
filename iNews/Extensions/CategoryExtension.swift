//
//  CategoryExtension.swift
//  iNews
//
//  Created by Oli Hinton on 12/08/2026.
//

import Foundation
import SwiftUI

extension Category {
    var placeholderColor: Color {
        switch self {
        case .business: .green
        case .technology: .blue
        case .sports: .orange
        case .politics: .red
        case .science: .purple
        case .world: .teal
        case .lifestyle: .pink
        case .health: .mint
        }
    }

    var placeholderIcon: String {
        switch self {
        case .business: "chart.line.uptrend.xyaxis"
        case .technology: "cpu"
        case .sports: "sportscourt"
        case .politics: "building.columns"
        case .science: "atom"
        case .world: "globe"
        case .lifestyle: "leaf"
        case .health: "heart"
        }
    }
}
