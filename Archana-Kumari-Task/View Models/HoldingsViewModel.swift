//
//  HoldingsViewModel.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 24/12/25.
//

import Foundation
import UIKit

class HoldingsCellViewModel {
    
    // MARK: - Properties
    private let holding: Holding
    
    // MARK: - Computed Properties for Display
    var symbol: String {
        holding.symbol
    }
    var quantityText: String {
        "\(holding.quantity)"
    }
    var ltpText: String {
        holding.ltp.formattedAsCurrency()
    }
    var profitAndLossText: String {
        let pnl = holding.profitAndLoss
        let sign = pnl >= 0 ? "+" : ""
        return "\(sign)\(pnl.formattedAsCurrency())"
    }
    var profitAndLossColor: UIColor {
        holding.profitAndLoss >= 0 ? .systemGreen : .systemRed
    }
    var isProfit: Bool {
        holding.profitAndLoss >= 0
    }
    
    // MARK: - Initializer

    init(holding: Holding) {
        self.holding = holding
    }
}
