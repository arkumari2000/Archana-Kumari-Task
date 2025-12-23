//
//  CacheService.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 24/12/25.
//

import Foundation

class CacheService {

    static let shared = CacheService()
    private let userDefaults: UserDefaults
    private let portfolioCacheKey = "portfolio_holdings_cache"
    private let cacheTimestampKey = "portfolio_cache_timestamp"
    private let cacheExpirationInterval: TimeInterval = 300
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public Method

    func savePortfolio(_ holdings: [Holding]) {
        if let encoded = try? JSONEncoder().encode(holdings) {
            userDefaults.set(encoded, forKey: portfolioCacheKey)
            userDefaults.set(Date().timeIntervalSince1970, forKey: cacheTimestampKey)
            userDefaults.synchronize()
        }
    }
    
    func getCachedPortfolio() -> [Holding]? {
        guard let data = userDefaults.data(forKey: portfolioCacheKey) else {
            return nil
        }

        if isCacheExpired() {
            clearCache()
            return nil
        }

        do {
            let holdings = try JSONDecoder().decode([Holding].self, from: data)
            return holdings
        } catch {
            clearCache()
            return nil
        }
    }
    func isCacheExpired() -> Bool {
        guard let timestamp = userDefaults.object(forKey: cacheTimestampKey) as? TimeInterval else {
            return true // No timestamp means cache is expired
        }
        
        let cacheDate = Date(timeIntervalSince1970: timestamp)
        let expirationDate = cacheDate.addingTimeInterval(cacheExpirationInterval)
        
        return Date() > expirationDate
    }

    func clearCache() {
        userDefaults.removeObject(forKey: portfolioCacheKey)
        userDefaults.removeObject(forKey: cacheTimestampKey)
        userDefaults.synchronize()
    }

    func hasCachedData() -> Bool {
        return userDefaults.data(forKey: portfolioCacheKey) != nil
    }
}

