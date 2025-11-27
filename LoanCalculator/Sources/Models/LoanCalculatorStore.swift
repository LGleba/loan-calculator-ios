//
//  LoanCalculatorStore.swift
//  LoanCalculator
//
//  Created by LGleba on 27.11.2025.
//

import Foundation

// MARK: - Store
@MainActor
final class LoanCalculatorStore: ObservableObject {
    @Published var state: LoanCalculatorState = LoanCalculatorState()
    
    init() {
        dispatch(.loadFromDefaults)
    }
    
    func dispatch(_ action: LoanCalculatorAction) {
        let oldAmount = state.amount
        let oldPeriod = state.period
        
        loanCalculatorReducer(state: &state, action: action)
        
        // Side effects ПОСЛЕ reducer
        if case .updateAmount = action, state.amount != oldAmount {
            saveToDefaults(state)
        }
        if case .updatePeriod = action, state.period != oldPeriod {
            saveToDefaults(state)
        }
        
        // Async actions
        Task { [weak self] in
            guard let self else { return }
            if case .submit(.loading) = action {
                await self.submitApplication()
            }
        }
    }
    
    @MainActor
    private func submitApplication() async {
        let payload = [
            "amount": state.amount,
            "period": state.period,
            "totalRepayment": Int(state.totalRepayment)
        ] as [String : Int]
        
        do {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
                dispatch(.submit(LoanCalculatorState.SubmitStatus.error("Failed to encode data")))
                return
            }
            
            var request = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                dispatch(.submit(LoanCalculatorState.SubmitStatus.success))
                // Auto-dismiss success after 2 seconds
                try await Task.sleep(nanoseconds: 2_000_000_000)
                dispatch(.submit(nil))
            } else {
                dispatch(.submit(LoanCalculatorState.SubmitStatus.error("Server error")))
            }
        } catch {
            dispatch(.submit(LoanCalculatorState.SubmitStatus.error(error.localizedDescription)))
        }
    }
}

// MARK: - Actions
enum LoanCalculatorAction {
    case updateAmount(Int)
    case updatePeriod(Int, currentDate: Date)
    
    case submit(LoanCalculatorState.SubmitStatus?)
    
    case loadFromDefaults
}

// MARK: - Reducer
func loanCalculatorReducer(state: inout LoanCalculatorState, action: LoanCalculatorAction) {
    switch action {
    case .updateAmount(let amount):
        state.amount = max(LoanCalculatorState.minAmount, min(amount, LoanCalculatorState.maxAmount))
        
    case .updatePeriod(let period, let currentDate):
        state.period = period
        state.returnDate = currentDate.addingTimeInterval(Double(period) * 24 * 3600)
        
    case .submit(let status):
        state.submitStatus = status
        
    case .loadFromDefaults:
        if let saved = loadFromDefaults() {
            state = saved
        }
    }
}

// MARK: - Helper Functions
private func loadFromDefaults() -> LoanCalculatorState? {
    let defaults = UserDefaults.standard
    guard defaults.object(forKey: "loanAmount") != nil,
          defaults.object(forKey: "loanPeriod") != nil else {
        return nil
    }
    
    var state = LoanCalculatorState()
    state.amount = defaults.integer(forKey: "loanAmount")
    state.period = defaults.integer(forKey: "loanPeriod")
    
    return state
}

private func saveToDefaults(_ state: LoanCalculatorState) {
    let defaults = UserDefaults.standard
    defaults.set(state.amount, forKey: "loanAmount")
    defaults.set(state.period, forKey: "loanPeriod")
}
