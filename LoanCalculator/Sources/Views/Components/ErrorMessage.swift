//
//  ErrorMessage.swift
//  LoanCalculator
//
//  Created by LGleba on 27.11.2025.
//

import SwiftUI

// MARK: - Error Message
struct ErrorMessage: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Error")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.1))
        )
        .border(Color.red.opacity(0.3), width: 1)
        .cornerRadius(8)
    }
}
