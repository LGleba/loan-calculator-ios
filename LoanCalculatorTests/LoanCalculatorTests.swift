//
//  LoanCalculatorTests.swift
//  LoanCalculator
//
//  Created by LGleba on 27.11.2025.
//

import XCTest
@testable import LoanCalculator

// MARK: - State Tests
final class LoanCalculatorStateTests: XCTestCase {
    
    var fixedDate: Date!
    
    override func setUp() {
        super.setUp()
        // Фиксированная дата для детерминированности
        fixedDate = Date(timeIntervalSince1970: 1700000000) // 14 Nov 2023
    }
    
    override func tearDown() {
        fixedDate = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() {
        let sut = LoanCalculatorState(creationDate: fixedDate)
        
        XCTAssertEqual(sut.amount, LoanCalculatorState.amountBase)
        XCTAssertEqual(sut.period, LoanCalculatorState.periodBase)
        XCTAssertNil(sut.submitStatus)
        
        let expectedReturnDate = fixedDate.addingTimeInterval(Double(LoanCalculatorState.periodBase) * 24 * 3600)
        XCTAssertEqual(sut.returnDate.timeIntervalSince1970, expectedReturnDate.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testCustomInitialization() {
        let customDate = fixedDate.addingTimeInterval(7 * 24 * 3600)
        let sut = LoanCalculatorState(
            amount: 20_000,
            period: 21,
            returnDate: customDate,
            submitStatus: .loading,
            creationDate: fixedDate
        )
        
        XCTAssertEqual(sut.amount, 20_000)
        XCTAssertEqual(sut.period, 21)
        XCTAssertEqual(sut.returnDate, customDate)
        XCTAssertEqual(sut.submitStatus, .loading)
    }
    
    // MARK: - Computed Properties Tests
    
    func testInterestRateForMinPeriod() {
        let sut = LoanCalculatorState(period: 7, creationDate: fixedDate)
        XCTAssertEqual(sut.interestRate, 15.0) // baseRate + (7-7)*0.5
    }
    
    func testInterestRateFor14Days() {
        let sut = LoanCalculatorState(period: 14, creationDate: fixedDate)
        XCTAssertEqual(sut.interestRate, 18.5) // baseRate + (14-7)*0.5 = 15 + 3.5
    }
    
    func testInterestRateFor21Days() {
        let sut = LoanCalculatorState(period: 21, creationDate: fixedDate)
        XCTAssertEqual(sut.interestRate, 22.0) // baseRate + (21-7)*0.5 = 15 + 7
    }
    
    func testInterestRateFor28Days() {
        let sut = LoanCalculatorState(period: 28, creationDate: fixedDate)
        XCTAssertEqual(sut.interestRate, 25.5) // baseRate + (28-7)*0.5 = 15 + 10.5
    }
    
    func testTotalRepaymentCalculation() {
        let sut = LoanCalculatorState(amount: 10_000, period: 14, creationDate: fixedDate)
        
        // Formula: amount + (amount * (interestRate/100) * period/365)
        let expectedInterest = 10_000.0 * (18.5 / 100.0) * (14.0 / 365.0)
        let expectedTotal = 10_000.0 + expectedInterest
        
        XCTAssertEqual(sut.totalRepayment, expectedTotal, accuracy: 0.01)
    }
    
    func testTotalRepaymentForMaxAmount() {
        let sut = LoanCalculatorState(
            amount: LoanCalculatorState.maxAmount,
            period: 28,
            creationDate: fixedDate
        )
        
        let expectedInterest = 50_000.0 * (25.5 / 100.0) * (28.0 / 365.0)
        let expectedTotal = 50_000.0 + expectedInterest
        
        XCTAssertEqual(sut.totalRepayment, expectedTotal, accuracy: 0.01)
    }
    
    // MARK: - Equatable Tests
    
    func testEquatableWithSameValues() {
        let state1 = LoanCalculatorState(amount: 10_000, period: 14, creationDate: fixedDate)
        let state2 = LoanCalculatorState(amount: 10_000, period: 14, creationDate: fixedDate)
        
        XCTAssertEqual(state1, state2)
    }
    
    func testEquatableWithDifferentAmounts() {
        let state1 = LoanCalculatorState(amount: 10_000, period: 14, creationDate: fixedDate)
        let state2 = LoanCalculatorState(amount: 15_000, period: 14, creationDate: fixedDate)
        
        XCTAssertNotEqual(state1, state2)
    }
    
    func testEquatableWithDifferentStatus() {
        let returnDate = fixedDate.addingTimeInterval(14 * 24 * 3600)
        let state1 = LoanCalculatorState(amount: 10_000, period: 14, returnDate: returnDate, submitStatus: nil, creationDate: fixedDate)
        let state2 = LoanCalculatorState(amount: 10_000, period: 14, returnDate: returnDate, submitStatus: .loading, creationDate: fixedDate)
        
        XCTAssertNotEqual(state1, state2)
    }
}

// MARK: - Reducer Tests
final class LoanCalculatorReducerTests: XCTestCase {
    
    var sut: LoanCalculatorState!
    var fixedDate: Date!
    
    override func setUp() {
        super.setUp()
        fixedDate = Date(timeIntervalSince1970: 1700000000)
        sut = LoanCalculatorState(creationDate: fixedDate)
    }
    
    override func tearDown() {
        sut = nil
        fixedDate = nil
        super.tearDown()
    }
    
    // MARK: - Update Amount Tests
    
    func testUpdateAmountWithinRange() {
        loanCalculatorReducer(state: &sut, action: .updateAmount(15_000))
        XCTAssertEqual(sut.amount, 15_000)
    }
    
    func testUpdateAmountBelowMinimumClampsToMin() {
        loanCalculatorReducer(state: &sut, action: .updateAmount(1_000))
        XCTAssertEqual(sut.amount, LoanCalculatorState.minAmount)
    }
    
    func testUpdateAmountAboveMaximumClampsToMax() {
        loanCalculatorReducer(state: &sut, action: .updateAmount(100_000))
        XCTAssertEqual(sut.amount, LoanCalculatorState.maxAmount)
    }
    
    func testUpdateAmountAtExactMinimum() {
        loanCalculatorReducer(state: &sut, action: .updateAmount(LoanCalculatorState.minAmount))
        XCTAssertEqual(sut.amount, LoanCalculatorState.minAmount)
    }
    
    func testUpdateAmountAtExactMaximum() {
        loanCalculatorReducer(state: &sut, action: .updateAmount(LoanCalculatorState.maxAmount))
        XCTAssertEqual(sut.amount, LoanCalculatorState.maxAmount)
    }
    
    // MARK: - Update Period Tests
    
    func testUpdatePeriodChangesValue() {
        let newDate = fixedDate.addingTimeInterval(100)
        loanCalculatorReducer(state: &sut, action: .updatePeriod(21, currentDate: newDate))
        
        XCTAssertEqual(sut.period, 21)
    }
    
    func testUpdatePeriodRecalculatesReturnDate() {
        let newDate = fixedDate.addingTimeInterval(100)
        loanCalculatorReducer(state: &sut, action: .updatePeriod(21, currentDate: newDate))
        
        let expectedReturnDate = newDate.addingTimeInterval(21 * 24 * 3600)
        XCTAssertEqual(sut.returnDate.timeIntervalSince1970, expectedReturnDate.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testUpdatePeriodPreservesDeterminism() {
        // Два одинаковых вызова с одинаковой датой дают одинаковый результат
        let testDate = Date(timeIntervalSince1970: 1700500000)
        
        var state1 = LoanCalculatorState(creationDate: fixedDate)
        var state2 = LoanCalculatorState(creationDate: fixedDate)
        
        loanCalculatorReducer(state: &state1, action: .updatePeriod(14, currentDate: testDate))
        loanCalculatorReducer(state: &state2, action: .updatePeriod(14, currentDate: testDate))
        
        XCTAssertEqual(state1.returnDate, state2.returnDate)
    }
    
    // MARK: - Submit Status Tests
    
    func testSubmitLoading() {
        loanCalculatorReducer(state: &sut, action: .submit(.loading))
        XCTAssertEqual(sut.submitStatus, .loading)
    }
    
    func testSubmitSuccess() {
        loanCalculatorReducer(state: &sut, action: .submit(.success))
        XCTAssertEqual(sut.submitStatus, .success)
    }
    
    func testSubmitError() {
        let errorMessage = "Network timeout"
        loanCalculatorReducer(state: &sut, action: .submit(.error(errorMessage)))
        
        if case .error(let message) = sut.submitStatus {
            XCTAssertEqual(message, errorMessage)
        } else {
            XCTFail("Expected error status")
        }
    }
    
    func testSubmitReset() {
        loanCalculatorReducer(state: &sut, action: .submit(.loading))
        loanCalculatorReducer(state: &sut, action: .submit(nil))
        
        XCTAssertNil(sut.submitStatus)
    }
    
    // MARK: - Reducer Purity Tests
    
    func testReducerDoesNotMutateInputDate() {
        let testDate = Date(timeIntervalSince1970: 1700600000)
        let originalTimestamp = testDate.timeIntervalSince1970
        
        loanCalculatorReducer(state: &sut, action: .updatePeriod(14, currentDate: testDate))
        
        // Исходная дата не должна измениться (pure function)
        XCTAssertEqual(testDate.timeIntervalSince1970, originalTimestamp)
    }
    
    func testReducerIsIdempotentForSubmitStatus() {
        loanCalculatorReducer(state: &sut, action: .submit(.success))
        let stateAfterFirst = sut
        
        loanCalculatorReducer(state: &sut, action: .submit(.success))
        let stateAfterSecond = sut
        
        XCTAssertEqual(stateAfterFirst, stateAfterSecond)
    }
}

// MARK: - UserDefaults Persistence Tests
final class LoanCalculatorPersistenceTests: XCTestCase {
    
    var testDefaults: UserDefaults!
    var fixedDate: Date!
    
    override func setUp() {
        super.setUp()
        // Создаем изолированный UserDefaults для тестов
        testDefaults = UserDefaults(suiteName: #file)
        testDefaults.removePersistentDomain(forName: #file)
        fixedDate = Date(timeIntervalSince1970: 1700000000)
    }
    
    override func tearDown() {
        testDefaults.removePersistentDomain(forName: #file)
        testDefaults = nil
        fixedDate = nil
        super.tearDown()
    }
    
    func testSaveStateToDefaults() {
        let state = LoanCalculatorState(
            amount: 25_000,
            period: 21,
            returnDate: fixedDate,
            creationDate: fixedDate
        )
        
        testDefaults.set(state.amount, forKey: "loanAmount")
        testDefaults.set(state.period, forKey: "loanPeriod")
        testDefaults.set(state.returnDate, forKey: "loanReturnDate")
        
        XCTAssertEqual(testDefaults.integer(forKey: "loanAmount"), 25_000)
        XCTAssertEqual(testDefaults.integer(forKey: "loanPeriod"), 21)
        
        // Принудительная распаковка с проверкой
        guard let savedDate = testDefaults.object(forKey: "loanReturnDate") as? Date else {
            XCTFail("Failed to load saved date from UserDefaults")
            return
        }
        XCTAssertEqual(savedDate.timeIntervalSince1970, fixedDate.timeIntervalSince1970, accuracy: 1.0)
    }
    
    func testLoadStateFromDefaults() {
        testDefaults.set(30_000, forKey: "loanAmount")
        testDefaults.set(28, forKey: "loanPeriod")
        testDefaults.set(fixedDate, forKey: "loanReturnDate")
        
        guard let returnDate = testDefaults.object(forKey: "loanReturnDate") as? Date else {
            XCTFail("Failed to load return date")
            return
        }
        
        let loadedState = LoanCalculatorState(
            amount: testDefaults.integer(forKey: "loanAmount"),
            period: testDefaults.integer(forKey: "loanPeriod"),
            returnDate: returnDate
        )
        
        XCTAssertEqual(loadedState.amount, 30_000)
        XCTAssertEqual(loadedState.period, 28)
        XCTAssertEqual(loadedState.returnDate, fixedDate)
    }
    
    func testLoadReturnsNilWhenNoData() {
        let amount = testDefaults.object(forKey: "loanAmount")
        let period = testDefaults.object(forKey: "loanPeriod")
        
        XCTAssertNil(amount)
        XCTAssertNil(period)
    }
}

// MARK: - Store Tests
@MainActor
final class LoanCalculatorStoreTests: XCTestCase {
    
    var sut: LoanCalculatorStore!
    
    override func setUp() async throws {
        try await super.setUp()
        // Очищаем UserDefaults перед каждым тестом
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "loanAmount")
        defaults.removeObject(forKey: "loanPeriod")
        defaults.removeObject(forKey: "loanReturnDate")
        
        sut = LoanCalculatorStore()
    }
    
    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testStoreInitialization() {
        XCTAssertNotNil(sut.state)
        XCTAssertEqual(sut.state.amount, LoanCalculatorState.amountBase)
        XCTAssertEqual(sut.state.period, LoanCalculatorState.periodBase)
    }
    
    // MARK: - Dispatch Tests
    
    func testDispatchUpdateAmount() {
        sut.dispatch(.updateAmount(20_000))
        XCTAssertEqual(sut.state.amount, 20_000)
    }
    
    func testDispatchUpdatePeriod() {
        let testDate = Date()
        sut.dispatch(.updatePeriod(21, currentDate: testDate))
        
        XCTAssertEqual(sut.state.period, 21)
        
        let expectedReturnDate = testDate.addingTimeInterval(21 * 24 * 3600)
        XCTAssertEqual(sut.state.returnDate.timeIntervalSince1970, expectedReturnDate.timeIntervalSince1970, accuracy: 2.0)
    }
    
    func testDispatchSubmitStatus() {
        sut.dispatch(.submit(.loading))
        XCTAssertEqual(sut.state.submitStatus, .loading)
        
        sut.dispatch(.submit(.success))
        XCTAssertEqual(sut.state.submitStatus, .success)
    }
    
    // MARK: - Async Tests
    
    func testSubmitApplicationSuccess() async {
        let expectation = XCTestExpectation(description: "Submit application")
        
        sut.dispatch(.submit(.loading))
        XCTAssertEqual(sut.state.submitStatus, .loading)
        
        // Даем время на выполнение async операции
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        
        // После успешного запроса статус должен быть success
        if case .success = sut.state.submitStatus {
            expectation.fulfill()
        } else if sut.state.submitStatus == nil {
            // Статус мог уже сброситься через 2 секунды
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 4.0)
    }
    
    func testMultipleDispatchesUpdateState() {
        sut.dispatch(.updateAmount(15_000))
        XCTAssertEqual(sut.state.amount, 15_000)
        
        sut.dispatch(.updateAmount(20_000))
        XCTAssertEqual(sut.state.amount, 20_000)
        
        sut.dispatch(.updateAmount(25_000))
        XCTAssertEqual(sut.state.amount, 25_000)
    }
    
    // MARK: - Side Effects Tests
    
    func testDispatchSavesToUserDefaults() {
        sut.dispatch(.updateAmount(35_000))
        
        let defaults = UserDefaults.standard
        let savedAmount = defaults.integer(forKey: "loanAmount")
        
        XCTAssertEqual(savedAmount, 35_000)
    }
    
    func testDispatchUpdatePeriodSavesToDefaults() {
        sut.dispatch(.updatePeriod(28, currentDate: Date()))
        
        let defaults = UserDefaults.standard
        let savedPeriod = defaults.integer(forKey: "loanPeriod")
        
        XCTAssertEqual(savedPeriod, 28)
    }
}

// MARK: - Number Formatter Tests
final class NumberFormatterTests: XCTestCase {
    
    func testFormatCurrency() {
        XCTAssertEqual(NumberFormatter.formatCurrency(1_000), "1,000")
        XCTAssertEqual(NumberFormatter.formatCurrency(10_000), "10,000")
        XCTAssertEqual(NumberFormatter.formatCurrency(50_000), "50,000")
        XCTAssertEqual(NumberFormatter.formatCurrency(100_000), "100,000")
    }
    
    func testFormatCurrencyWithZero() {
        XCTAssertEqual(NumberFormatter.formatCurrency(0), "0")
    }
    
    func testFormatCurrencyDouble() {
        XCTAssertEqual(NumberFormatter.formatCurrencyDouble(1_500.5), "1,500")
        XCTAssertEqual(NumberFormatter.formatCurrencyDouble(11_500.99), "11,500")
        XCTAssertEqual(NumberFormatter.formatCurrencyDouble(10_000.0), "10,000")
    }
    
    func testFormatCurrencyDoubleRoundsDown() {
        XCTAssertEqual(NumberFormatter.formatCurrencyDouble(1_234.4), "1,234")
    }
    
    func testFormatDate() {
        let date = Date(timeIntervalSince1970: 1700000000)
        let formatted = NumberFormatter.formatDate(date)
        
        XCTAssertFalse(formatted.isEmpty)
        XCTAssertTrue(formatted.contains("Nov") || formatted.contains("14"))
    }
}

// MARK: - SubmitStatus Enum Tests
final class SubmitStatusTests: XCTestCase {
    
    func testLoadingEquality() {
        XCTAssertEqual(LoanCalculatorState.SubmitStatus.loading, .loading)
    }
    
    func testSuccessEquality() {
        XCTAssertEqual(LoanCalculatorState.SubmitStatus.success, .success)
    }
    
    func testErrorEqualityWithSameMessage() {
        let error1 = LoanCalculatorState.SubmitStatus.error("Network error")
        let error2 = LoanCalculatorState.SubmitStatus.error("Network error")
        
        XCTAssertEqual(error1, error2)
    }
    
    func testErrorInequalityWithDifferentMessages() {
        let error1 = LoanCalculatorState.SubmitStatus.error("Network error")
        let error2 = LoanCalculatorState.SubmitStatus.error("Server error")
        
        XCTAssertNotEqual(error1, error2)
    }
    
    func testDifferentCasesAreNotEqual() {
        let loading = LoanCalculatorState.SubmitStatus.loading
        let success = LoanCalculatorState.SubmitStatus.success
        let error = LoanCalculatorState.SubmitStatus.error("Error")
        
        XCTAssertNotEqual(loading, success)
        XCTAssertNotEqual(success, error)
        XCTAssertNotEqual(loading, error)
    }
}

// MARK: - Integration Tests
@MainActor
final class LoanCalculatorIntegrationTests: XCTestCase {
    
    var store: LoanCalculatorStore!
    
    override func setUp() async throws {
        try await super.setUp()
        store = LoanCalculatorStore()
    }
    
    override func tearDown() async throws {
        store = nil
        try await super.tearDown()
    }
    
    func testCompleteUserFlow() {
        // Пользователь выбирает сумму
        store.dispatch(.updateAmount(25_000))
        XCTAssertEqual(store.state.amount, 25_000)
        
        // Пользователь выбирает период
        store.dispatch(.updatePeriod(21, currentDate: Date()))
        XCTAssertEqual(store.state.period, 21)
        
        // Проверяем что процент рассчитался
        XCTAssertEqual(store.state.interestRate, 22.0)
        
        // Проверяем что итоговая сумма больше исходной
        XCTAssertGreaterThan(store.state.totalRepayment, Double(store.state.amount))
    }
    
    func testStateRestorationFromDefaults() {
        // Сохраняем состояние
        store.dispatch(.updateAmount(40_000))
        store.dispatch(.updatePeriod(28, currentDate: Date()))
        
        // Создаем новый store (симулируем перезапуск)
        let newStore = LoanCalculatorStore()
        
        // Состояние должно восстановиться
        XCTAssertEqual(newStore.state.amount, 40_000)
        XCTAssertEqual(newStore.state.period, 28)
    }
}
