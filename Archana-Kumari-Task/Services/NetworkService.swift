//
//  NetworkService.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 24/12/25.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error with status code: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

class NetworkService {

    static let shared = NetworkService()
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Public Methods
    
    func fetch<T: Codable>(from url: URL, as responseType: T.Type) async throws -> T {
    
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            // Success Response Code Checking
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            // Decode the JSON response
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch {
                throw NetworkError.decodingError(error)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }

    func fetch<T: Codable>(from urlString: String, as responseType: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        return try await fetch(from: url, as: responseType)
    }
}
