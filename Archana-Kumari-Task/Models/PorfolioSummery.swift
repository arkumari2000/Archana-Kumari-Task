//
//  PorfolioSummery.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 24/12/25.
//

import Foundation

/// Aggregated portfolio summary
struct PortfolioSummary {

    let currentValue: Double
    let totalInvestment: Double
    let todayProfitAndLoss: Double
    let totalProfitAndLoss: Double
    
    // MARK: - Computed Property

    var totalProfitAndLossPercentage: Double {
        guard totalInvestment > 0 else { return 0 }
        return (totalProfitAndLoss / totalInvestment) * 100
    }
    
    // MARK: - Initializer

    init(holdings: [Holding]) {

        self.currentValue = holdings.reduce(0) { $0 + $1.currentValue }
        
        self.totalInvestment = holdings.reduce(0) { $0 + $1.totalInvestment }
        
        self.todayProfitAndLoss = holdings.reduce(0) { $0 + $1.todayProfitAndLoss }
        
        self.totalProfitAndLoss = currentValue - totalInvestment
    }
}
