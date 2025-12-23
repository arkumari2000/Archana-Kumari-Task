//
//  PortfolioSummaryTest.swift
//  Archana-Kumari-TaskTests
//
//  Created by Archana Kumari on 24/12/25.
//

import XCTest
@testable import Archana_Kumari_Task

final class PortfolioSummaryTests: XCTestCase {
    
    func testPortfolioSummaryCalculation() {
        // Given: Sample holdings
        let holdings = [
            Holding(symbol: "HDFC", quantity: 7, ltp: 2497.20, avgPrice: 2800.00, close: 2500.00),
            Holding(symbol: "ICICI", quantity: 1, ltp: 624.70, avgPrice: 500.00, close: 600.00)
        ]
        
        // When: Create portfolio summary
        let summary = PortfolioSummary(holdings: holdings)
        
        // Then: Verify calculations
        // HDFC: 7 * 2497.20 = 17,480.40 (current), 7 * 2800 = 19,600 (investment)
        // ICICI: 1 * 624.70 = 624.70 (current), 1 * 500 = 500 (investment)
        let expectedCurrentValue = (7 * 2497.20) + (1 * 624.70)
        let expectedTotalInvestment = (7 * 2800.00) + (1 * 500.00)
        let expectedTotalPNL = expectedCurrentValue - expectedTotalInvestment
        
        XCTAssertEqual(summary.currentValue, expectedCurrentValue, accuracy: 0.01)
        XCTAssertEqual(summary.totalInvestment, expectedTotalInvestment, accuracy: 0.01)
        XCTAssertEqual(summary.totalProfitAndLoss, expectedTotalPNL, accuracy: 0.01)
    }
    
    func testPortfolioSummaryTodayPNL() {
        // Given: Holdings with different close prices
        let holdings = [
            Holding(symbol: "STOCK1", quantity: 10, ltp: 100.0, avgPrice: 90.0, close: 95.0), // Today's P&L: 10 * (100 - 95) = 50
            Holding(symbol: "STOCK2", quantity: 5, ltp: 50.0, avgPrice: 60.0, close: 55.0)   // Today's P&L: 5 * (50 - 55) = -25
        ]
        
        // When: Create portfolio summary
        let summary = PortfolioSummary(holdings: holdings)
        
        // Then: Today's P&L should be 50 - 25 = 25
        let expectedTodayPNL = (10 * (100.0 - 95.0)) + (5 * (50.0 - 55.0))
        XCTAssertEqual(summary.todayProfitAndLoss, expectedTodayPNL, accuracy: 0.01)
    }
    
    func testPortfolioSummaryPercentage() {
        // Given: Holdings
        let holdings = [
            Holding(symbol: "STOCK1", quantity: 100, ltp: 110.0, avgPrice: 100.0, close: 105.0)
        ]
        
        // When: Create portfolio summary
        let summary = PortfolioSummary(holdings: holdings)
        
        // Then: P&L percentage should be (11000 - 10000) / 10000 * 100 = 10%
        let expectedPercentage = ((11000.0 - 10000.0) / 10000.0) * 100.0
        XCTAssertEqual(summary.totalProfitAndLossPercentage, expectedPercentage, accuracy: 0.01)
    }
    
    func testPortfolioSummaryWithEmptyHoldings() {
        // Given: Empty holdings array
        let holdings: [Holding] = []
        
        // When: Create portfolio summary
        let summary = PortfolioSummary(holdings: holdings)
        
        // Then: All values should be zero
        XCTAssertEqual(summary.currentValue, 0.0)
        XCTAssertEqual(summary.totalInvestment, 0.0)
        XCTAssertEqual(summary.todayProfitAndLoss, 0.0)
        XCTAssertEqual(summary.totalProfitAndLoss, 0.0)
        XCTAssertEqual(summary.totalProfitAndLossPercentage, 0.0)
    }
    
    func testPortfolioSummaryWithProfit() {
        // Given: Holdings with profit (ltp > avgPrice)
        let holdings = [
            Holding(symbol: "PROFIT", quantity: 10, ltp: 120.0, avgPrice: 100.0, close: 110.0)
        ]
        
        // When: Create portfolio summary
        let summary = PortfolioSummary(holdings: holdings)
        
        // Then: Should show profit
        XCTAssertGreaterThan(summary.totalProfitAndLoss, 0)
        XCTAssertGreaterThan(summary.totalProfitAndLossPercentage, 0)
    }
    
    func testPortfolioSummaryWithLoss() {
        // Given: Holdings with loss (ltp < avgPrice)
        let holdings = [
            Holding(symbol: "LOSS", quantity: 10, ltp: 80.0, avgPrice: 100.0, close: 90.0)
        ]
        
        // When: Create portfolio summary
        let summary = PortfolioSummary(holdings: holdings)
        
        // Then: Should show loss
        XCTAssertLessThan(summary.totalProfitAndLoss, 0)
        XCTAssertLessThan(summary.totalProfitAndLossPercentage, 0)
    }
}
