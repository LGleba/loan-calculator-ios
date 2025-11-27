//
//  LoanCalculatorView.swift
//  LoanCalculator
//
//  Created by LGleba on 27.11.2025.
//

import SwiftUI

// MARK: - Main View
struct LoanCalculatorView: View {
    @StateObject private var store = LoanCalculatorStore()
    @Environment(\.colorScheme) var colorScheme
    
    @State private var headerSize: CGSize = .zero
    @State private var footerSize: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // Scrollable Content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Amount Slider Section
                    VStack(spacing: 12) {
                        HStack {
                            Text("Loan Amount")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("$\(NumberFormatter.formatCurrency(store.state.amount))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                        }
                        
                        CustomSlider(
                            value: .constant(Double(store.state.amount)),
                            range: Double(LoanCalculatorState.minAmount)...Double(LoanCalculatorState.maxAmount),
                            step: 1000,
                            color: .green,
                            onChanged: { oldValue, newValue in
                                store.dispatch(.updateAmount(Int(newValue)))
                            }
                        )
                        
                        HStack {
                            Text("$\(NumberFormatter.formatCurrency(LoanCalculatorState.minAmount))")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("$\(NumberFormatter.formatCurrency(LoanCalculatorState.maxAmount))")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor { $0.userInterfaceStyle == .dark ?
                                UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1) :
                                UIColor.white
                            }))
                    )
                    
                    // Period Slider Section
                    VStack(spacing: 12) {
                        HStack {
                            Text("Loan Period")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(store.state.period) days")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        
                        CustomSlider(
                            value: .constant(Double(store.state.period)),
                            range: 7...28,
                            step: 7,
                            color: .orange,
                            onChanged: { oldValue, newValue in
                                store.dispatch(.updatePeriod(Int(newValue), currentDate: Date()))
                            }
                        )
                        
                        HStack {
                            Text("7 days")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("28 days")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor { $0.userInterfaceStyle == .dark ?
                                UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1) :
                                UIColor.white
                            }))
                    )
                    
                    // Calculation Results
                    VStack(spacing: 16) {
                        ResultRow(
                            label: "Interest Rate",
                            value: String(format: "%.1f%%", store.state.interestRate)
                        )
                        
                        Divider()
                            .foregroundColor(.secondary.opacity(0.3))
                        
                        ResultRow(
                            label: "Total Repayment",
                            value: "$\(NumberFormatter.formatCurrencyDouble(store.state.totalRepayment))",
                            highlighted: true
                        )
                        
                        Divider()
                            .foregroundColor(.secondary.opacity(0.3))
                        
                        ResultRow(
                            label: "Return Date",
                            value: NumberFormatter.formatDate(store.state.returnDate)
                        )
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor { $0.userInterfaceStyle == .dark ?
                                UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1) :
                                UIColor.white
                            }))
                    )
                    
                    // Status Messages
                    if store.state.submitStatus == .success {
                        SuccessMessage()
                    }
                    
                    if case .error(let error) = store.state.submitStatus {
                        ErrorMessage(message: error)
                    }
                }
                .padding(16)
                .padding(.top, headerSize.height)
            }
            
            
            VStack {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Loan Calculator")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Quick and easy loan calculation")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.ultraThinMaterial)
                .saveSize(in: $headerSize)
                
                Spacer(minLength: 0)
                
                // Footer
                VStack(spacing: 12) {
                    Button(action: {
                        store.dispatch(.submit(.loading))
                    }) {
                        if store.state.submitStatus == .loading {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                                
                                Text("Submitting...")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        } else {
                            Text("Submit Application")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(store.state.submitStatus == .loading)
                    .opacity(store.state.submitStatus == .loading ? 0.8 : 1.0)
                    
                    Text("Amount: $\(NumberFormatter.formatCurrency(store.state.amount)) • Period: \(store.state.period)d")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .saveSize(in: $footerSize)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LoanCalculatorView()
}
