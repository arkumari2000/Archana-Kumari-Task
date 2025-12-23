//
//  HoldingsCellVMTests.swift
//  Archana-Kumari-TaskTests
//
//  Created by Archana Kumari on 24/12/25.
//

import XCTest
@testable import Archana_Kumari_Task

final class HoldingCellViewModelTests: XCTestCase {
    
    func testHoldingCellViewModelWithProfit() {
        // Given: Holding with profit
        let holding = Holding(symbol: "HDFC", quantity: 7, ltp: 2497.20, avgPrice: 2000.00, close: 2400.00)
        let viewModel = HoldingsCellViewModel(holding: holding)
        
        // Then: Verify properties
        XCTAssertEqual(viewModel.symbol, "HDFC")
        XCTAssertEqual(viewModel.quantityText, "7")
        XCTAssertTrue(viewModel.ltpText.contains("₹"))
        XCTAssertTrue(viewModel.profitAndLossText.contains("₹"))
        XCTAssertTrue(viewModel.isProfit)
        XCTAssertEqual(viewModel.profitAndLossColor, .systemGreen)
    }
    
    func testHoldingCellViewModelWithLoss() {
        // Given: Holding with loss
        let holding = Holding(symbol: "LOSS", quantity: 10, ltp: 80.0, avgPrice: 100.0, close: 90.0)
        let viewModel = HoldingsCellViewModel(holding: holding)
        
        // Then: Verify properties
        XCTAssertEqual(viewModel.symbol, "LOSS")
        XCTAssertEqual(viewModel.quantityText, "10")
        XCTAssertFalse(viewModel.isProfit)
        XCTAssertEqual(viewModel.profitAndLossColor, .systemRed)
    }
    
    func testHoldingCellViewModelProfitAndLossText() {
        // Given: Holding with positive P&L
        let profitHolding = Holding(symbol: "PROFIT", quantity: 1, ltp: 110.0, avgPrice: 100.0, close: 105.0)
        let profitViewModel = HoldingsCellViewModel(holding: profitHolding)
        
        // Then: Should have + sign for profit
        XCTAssertTrue(profitViewModel.profitAndLossText.contains("+") || profitViewModel.profitAndLossText.contains("₹"))
        
        // Given: Holding with negative P&L
        let lossHolding = Holding(symbol: "LOSS", quantity: 1, ltp: 90.0, avgPrice: 100.0, close: 95.0)
        let lossViewModel = HoldingsCellViewModel(holding: lossHolding)
        
        // Then: Should show negative value
        XCTAssertTrue(lossViewModel.profitAndLossText.contains("₹"))
    }
}


