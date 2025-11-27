//
//  LoanCalculatorState.swift
//  LoanCalculator
//
//  Created by LGleba on 27.11.2025.
//

import Foundation

// MARK: - Redux/UDF Architecture

// MARK: - State
struct LoanCalculatorState: Equatable, Sendable {
    
    // MARK: - Enum
    enum SubmitStatus: Equatable {
        case loading
        case success
        case error(String)
    }
    
    // MARK: - State vars
    var amount: Int
    var period: Int
    var returnDate: Date
    var submitStatus: SubmitStatus?
    
    // MARK: - Get vars
    var interestRate: Double {
        Self.baseInterestRate + Double(max(0, period - 7)) * 0.5
    }
    var totalRepayment: Double {
        let interest: Double = Double(amount) * (interestRate / 100) * Double(period) / 365
        return Double(amount) + interest
    }
    
    // MARK: - Constants
    static let amountBase = 10_000
    static let periodBase = 14
    static let baseInterestRate: Double = 15.0
    static let minAmount: Int = 5_000
    static let maxAmount: Int = 50_000
    static let availablePeriods: [Int] = [7, 14, 21, 28]
    
    init(
        amount: Int = Self.amountBase,
        period: Int = Self.periodBase,
        returnDate: Date? = nil,
        submitStatus: SubmitStatus? = nil,
        creationDate: Date = Date()
    ) {
        self.amount = amount
        self.period = period
        self.returnDate = returnDate ?? creationDate.addingTimeInterval(Double(period) * 24 * 3600)
        self.submitStatus = submitStatus
    }
}

