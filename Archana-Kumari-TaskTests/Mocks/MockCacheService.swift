//
//  MockCacheService.swift
//  Archana-Kumari-TaskTests
//
//  Created by Archana Kumari on 24/12/25.
//

import Foundation
@testable import Archana_Kumari_Task

class MockCacheService: CacheService {
    
    var cachedHoldings: [Holding]?
    var saveCallCount: Int = 0
    var getCallCount: Int = 0
    var shouldReturnExpired: Bool = false
    
    override func savePortfolio(_ holdings: [Holding]) {
        saveCallCount += 1
        cachedHoldings = holdings
    }
    
    override func getCachedPortfolio() -> [Holding]? {
        getCallCount += 1
        if shouldReturnExpired {
            return nil
        }
        return cachedHoldings
    }
    
    override func isCacheExpired() -> Bool {
        return shouldReturnExpired
    }
    
    override func hasCachedData() -> Bool {
        return cachedHoldings != nil
    }
}

