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
    private let cacheService: CacheService
    
    init(
        networkService: NetworkService = .shared,
        cacheService: CacheService = .shared
    ) {
        self.networkService = networkService
        self.cacheService = cacheService
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
            cacheService.savePortfolio(holdings) // Save holdings to cache
            
            return holdings
            
        } catch {
            if let cachedHoldings = cacheService.getCachedPortfolio() {
                return cachedHoldings
            } else {
                throw error // Both network and cache failed - throw the network error
            }
        }
    }

    func refreshHoldings() async throws -> [Holding] {
        let response = try await networkService.fetch(
            from: apiURL,
            as: APIResponse.self
        )
        
        let holdings = response.data.userHolding
        cacheService.savePortfolio(holdings)
        
        return holdings
    }
    
    func getCachedHoldings() -> [Holding]? {
        return cacheService.getCachedPortfolio()
    }
}

