//
//  PortfolioRepository.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 24/12/25.
//

import Foundation

class PortfolioRepository {

    static let shared = PortfolioRepository()
    private let apiURL = "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/"
    private let networkService: NetworkService
    
    init(
        networkService: NetworkService = .shared
    ) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods

    func fetchHoldings() async throws -> [Holding] {
        do {
            // Try to fetch from network first
            let response = try await networkService.fetch(
                from: apiURL,
                as: APIResponse.self
            )
            
            let holdings = response.data.userHolding
            
            return holdings
            
        } catch {
            throw error
        }
    }

    func refreshHoldings() async throws -> [Holding] {
        let response = try await networkService.fetch(
            from: apiURL,
            as: APIResponse.self
        )
        
        let holdings = response.data.userHolding
        
        return holdings
    }
}

