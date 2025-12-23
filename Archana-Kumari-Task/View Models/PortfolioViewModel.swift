//
//  PortfolioViewModel.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 24/12/25.
//

import Foundation
import Combine

class PortfolioViewModel: ObservableObject {
    
    // MARK: - Published Properties (Reactive)

    @Published var holdings: [Holding] = []
    @Published var portfolioSummary: PortfolioSummary?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSummaryExpanded: Bool = false
    
    // MARK: - Private Properties

    private let repository: PortfolioRepository
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer

    init(repository: PortfolioRepository = .shared) {
        self.repository = repository
    }
    
    // MARK: - Public Methods

    func loadHoldings() {

        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedHoldings = try await repository.fetchHoldings()
                
                // Update on main thread (UI updates must be on main thread)
                await MainActor.run {
                    self.holdings = fetchedHoldings
                    self.calculateSummary()
                    self.isLoading = false
                }
                
            } catch {
                // Handle error
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func toggleSummaryExpansion() {
        isSummaryExpanded.toggle()
    }
    
    // MARK: - Private Methods

    private func calculateSummary() {
        guard !holdings.isEmpty else {
            portfolioSummary = nil
            return
        }
        portfolioSummary = PortfolioSummary(holdings: holdings)
    }
    
    func getCellViewModels() -> [HoldingsCellViewModel] {
        return holdings.map { HoldingsCellViewModel(holding: $0) }
    }
}


