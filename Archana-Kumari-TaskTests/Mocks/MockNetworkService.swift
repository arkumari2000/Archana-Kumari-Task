//
//  MockNetworkService.swift
//  Archana-Kumari-TaskTests
//
//  Created by Archana Kumari on 24/12/25.
//

import Foundation
@testable import Archana_Kumari_Task

class MockNetworkService: NetworkService {
    
    var shouldSucceed: Bool = true
    var mockResponse: APIResponse?
    var mockError: NetworkError?
    var fetchCallCount: Int = 0
    
    override func fetch<T: Codable>(from url: URL, as responseType: T.Type) async throws -> T {
        fetchCallCount += 1
        
        if shouldSucceed {
            if let mockResponse = mockResponse as? T {
                return mockResponse
            }
            throw NetworkError.noData
        } else {
            if let error = mockError {
                throw error
            }
            throw NetworkError.networkError(NSError(domain: "TestError", code: -1))
        }
    }
    
    override func fetch<T: Codable>(from urlString: String, as responseType: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        return try await fetch(from: url, as: responseType)
    }
}
