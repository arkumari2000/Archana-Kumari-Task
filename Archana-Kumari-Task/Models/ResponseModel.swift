//
//  ResponseModel.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 24/12/25.
//

import Foundation

struct APIResponse: Codable {
    let data: PortfolioData
}

struct PortfolioData: Codable {
    let userHolding: [Holding]
}
