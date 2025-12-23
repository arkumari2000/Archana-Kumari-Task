//
//  Holding.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 23/12/25.
//

import Foundation

struct Holding: Codable, Identifiable {

    var id: String { symbol }
    let symbol: String
    let quantity: Int
    let ltp: Double
    let avgPrice: Double
    let close: Double
    
    // MARK: - Computed Properties
    
    var currentValue: Double {
        return Double(quantity) * ltp
    }
    
    var totalInvestment: Double {
        return Double(quantity) * avgPrice
    }
    
    var profitAndLoss: Double {
        return currentValue - totalInvestment
    }

    var todayProfitAndLoss: Double {
        return Double(quantity) * (ltp - close)
    }
    
    var profitAndLossPercentage: Double {
        guard totalInvestment > 0 else { return 0 }
        return (profitAndLoss / totalInvestment) * 100
    }
}
