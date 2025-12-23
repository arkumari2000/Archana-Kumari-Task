//
//  PortfolioViewModelTest.swift
//  Archana-Kumari-TaskTests
//
//  Created by Archana Kumari on 24/12/25.
//

import XCTest
import Combine
@testable import Archana_Kumari_Task

final class PortfolioViewModelTests: XCTestCase {

    // MARK: - Properties
    
    private var viewModel: PortfolioViewModel?
    private var mockRepository: PortfolioRepository?
    private var mockNetworkService: MockNetworkService?
    private var mockCacheService: MockCacheService?
    private var cancellables: Set<AnyCancellable>?
    
    // MARK: - Computed Properties for Safe Access
    
    private var safeViewModel: PortfolioViewModel {
        guard let viewModel = viewModel else {
            fatalError("viewModel was not initialized in setUp()")
        }
        return viewModel
    }
    
    private var safeMockNetworkService: MockNetworkService {
        guard let service = mockNetworkService else {
            fatalError("mockNetworkService was not initialized in setUp()")
        }
        return service
    }
    
    private var safeMockCacheService: MockCacheService {
        guard let service = mockCacheService else {
            fatalError("mockCacheService was not initialized in setUp()")
        }
        return service
    }
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        mockNetworkService = MockNetworkService()
        mockCacheService = MockCacheService()
        mockRepository = PortfolioRepository(
            networkService: mockNetworkService!,
            cacheService: mockCacheService!
        )
        viewModel = PortfolioViewModel(repository: mockRepository!)
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockRepository = nil
        mockCacheService = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateOnFetch() {
        // Given: Network service will succeed
        let mockHoldings = [
            Holding(symbol: "TEST", quantity: 1, ltp: 100.0, avgPrice: 90.0, close: 95.0)
        ]
        let mockResponse = APIResponse(data: PortfolioData(userHolding: mockHoldings))
        safeMockNetworkService.shouldSucceed = true
        safeMockNetworkService.mockResponse = mockResponse
        
        let expectation = expectation(description: "Loading state changes")
        var loadingStates: [Bool] = []
        
        // When: Observe loading state
        safeViewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables!)
        
        safeViewModel.loadHoldings()
        
        // Then: Should start loading, then stop
        waitForExpectations(timeout: 2.0)
        XCTAssertTrue(loadingStates.contains(true))
        XCTAssertTrue(loadingStates.contains(false))
    }
    
    // MARK: - Holdings Tests
    
    func testLoadHoldingsSuccess() async {
        // Given: Network service returns holdings
        let mockHoldings = [
            Holding(symbol: "HDFC", quantity: 7, ltp: 2497.20, avgPrice: 2800.00, close: 2500.00),
            Holding(symbol: "ICICI", quantity: 1, ltp: 624.70, avgPrice: 500.00, close: 600.00)
        ]
        let mockResponse = APIResponse(data: PortfolioData(userHolding: mockHoldings))
        safeMockNetworkService.shouldSucceed = true
        safeMockNetworkService.mockResponse = mockResponse
        
        let expectation = expectation(description: "Holdings loaded")
        
        // When: Observe holdings
        safeViewModel.$holdings
            .dropFirst() // Skip initial empty state
            .sink { holdings in
                if !holdings.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables!)
        
        safeViewModel.loadHoldings()
        
        // Then: Should have holdings
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(safeViewModel.holdings.count, 2)
        XCTAssertEqual(safeViewModel.holdings.first?.symbol, "HDFC")
    }
    
    func testLoadHoldingsWithError() async {
        // Given: Network fails and no cache
        safeMockNetworkService.shouldSucceed = false
        safeMockNetworkService.mockError = .networkError(NSError(domain: "Test", code: -1))
        safeMockCacheService.cachedHoldings = nil
        
        let expectation = expectation(description: "Error state")
        
        // When: Observe error
        safeViewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                if errorMessage != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables!)
        
        safeViewModel.loadHoldings()
        
        // Then: Should have error message
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertNotNil(safeViewModel.errorMessage)
    }
}
