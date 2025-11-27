//
//  ResultRow.swift
//  LoanCalculator
//
//  Created by LGleba on 27.11.2025.
//

import SwiftUI

// MARK: - Result Row Component
struct ResultRow: View {
    let label: String
    let value: String
    var highlighted: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: highlighted ? .bold : .semibold))
                .foregroundColor(highlighted ? .blue : .primary)
        }
    }
}
