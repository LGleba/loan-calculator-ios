//
//  NumberFormatter.swift
//  LoanCalculator
//
//  Created by LGleba on 27.11.2025.
//

import Foundation

// MARK: - Formatting Utilities
struct NumberFormatter {
    static func formatCurrency(_ number: Int) -> String {
        let formatter = Foundation.NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    static func formatCurrencyDouble(_ number: Double) -> String {
        let formatter = Foundation.NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: Int(number))) ?? String(format: "%.0f", number)
    }
    
    static func formatDate(_ date: Date) -> String {
        let formatter = Foundation.DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
