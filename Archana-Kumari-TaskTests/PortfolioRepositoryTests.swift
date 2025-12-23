//
//  PortfolioRepositoryTests.swift
//  Archana-Kumari-TaskTests
//
//  Created by Archana Kumari on 24/12/25.
//

import XCTest
@testable import Archana_Kumari_Task

final class PortfolioRepositoryTests: XCTestCase {
    
    var mockNetworkService: MockNetworkService!
    var mockCacheService: MockCacheService!
    var repository: PortfolioRepository!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockCacheService = MockCacheService()
        repository = PortfolioRepository(
            networkService: mockNetworkService,
            cacheService: mockCacheService
        )
    }
    
    override func tearDown() {
        mockNetworkService = nil
        mockCacheService = nil
        repository = nil
        super.tearDown()
    }
    
    // MARK: - Success Cases
    
    func testFetchHoldingsSuccess() async throws {
        // Given: Network service returns successful response
        let mockHoldings = [
            Holding(symbol: "HDFC", quantity: 7, ltp: 2497.20, avgPrice: 2800.00, close: 2500.00)
        ]
        let mockResponse = APIResponse(data: PortfolioData(userHolding: mockHoldings))
        mockNetworkService.shouldSucceed = true
        mockNetworkService.mockResponse = mockResponse
        
        // When: Fetch holdings
        let holdings = try await repository.fetchHoldings()
        
        // Then: Should return holdings and cache them
        XCTAssertEqual(holdings.count, 1)
        XCTAssertEqual(holdings.first?.symbol, "HDFC")
        XCTAssertEqual(mockCacheService.saveCallCount, 1)
        XCTAssertEqual(mockCacheService.cachedHoldings?.count, 1)
    }
    
    func testFetchHoldingsWithCacheFallback() async throws {
        // Given: Network fails but cache exists
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = .networkError(NSError(domain: "Test", code: -1))
        
        let cachedHoldings = [
            Holding(symbol: "CACHED", quantity: 5, ltp: 100.0, avgPrice: 90.0, close: 95.0)
        ]
        mockCacheService.cachedHoldings = cachedHoldings
        
        // When: Fetch holdings
        let holdings = try await repository.fetchHoldings()
        
        // Then: Should return cached holdings
        XCTAssertEqual(holdings.count, 1)
        XCTAssertEqual(holdings.first?.symbol, "CACHED")
    }
    
    func testFetchHoldingsNetworkAndCacheBothFail() async {
        // Given: Both network and cache fail
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = .networkError(NSError(domain: "Test", code: -1))
        mockCacheService.cachedHoldings = nil
        
        // When/Then: Should throw error
        do {
            _ = try await repository.fetchHoldings()
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    // MARK: - Refresh Tests
    
    func testRefreshHoldings() async throws {
        // Given: Network service returns successful response
        let mockHoldings = [
            Holding(symbol: "REFRESHED", quantity: 10, ltp: 200.0, avgPrice: 180.0, close: 190.0)
        ]
        let mockResponse = APIResponse(data: PortfolioData(userHolding: mockHoldings))
        mockNetworkService.shouldSucceed = true
        mockNetworkService.mockResponse = mockResponse
        
        // When: Refresh holdings
        let holdings = try await repository.refreshHoldings()
        
        // Then: Should return fresh holdings and update cache
        XCTAssertEqual(holdings.count, 1)
        XCTAssertEqual(holdings.first?.symbol, "REFRESHED")
        XCTAssertEqual(mockCacheService.saveCallCount, 1)
    }
    
    func testRefreshHoldingsNetworkFailure() async {
        // Given: Network fails
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = .networkError(NSError(domain: "Test", code: -1))
        
        // When/Then: Should throw error (refresh doesn't use cache)
        do {
            _ = try await repository.refreshHoldings()
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    // MARK: - Cache Tests
    
    func testGetCachedHoldings() {
        // Given: Cache has holdings
        let cachedHoldings = [
            Holding(symbol: "CACHED1", quantity: 5, ltp: 100.0, avgPrice: 90.0, close: 95.0),
            Holding(symbol: "CACHED2", quantity: 3, ltp: 50.0, avgPrice: 40.0, close: 45.0)
        ]
        mockCacheService.cachedHoldings = cachedHoldings
        
        // When: Get cached holdings
        let holdings = repository.getCachedHoldings()
        
        // Then: Should return cached holdings
        XCTAssertNotNil(holdings)
        XCTAssertEqual(holdings?.count, 2)
        XCTAssertEqual(holdings?.first?.symbol, "CACHED1")
    }
    
    func testGetCachedHoldingsWhenEmpty() {
        // Given: No cache
        mockCacheService.cachedHoldings = nil
        
        // When: Get cached holdings
        let holdings = repository.getCachedHoldings()
        
        // Then: Should return nil
        XCTAssertNil(holdings)
    }
}
