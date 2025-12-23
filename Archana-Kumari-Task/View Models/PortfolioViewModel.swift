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
    @Published var searchQuery: String = ""
    @Published var isSortAscending: Bool = true
    
    // MARK: - Private Properties

    private let repository: PortfolioRepository
    private var originalHoldings: [Holding] = []
    private var cancellables = Set<AnyCancellable>()
    private var searchWorkItem: DispatchWorkItem?
    
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
                
                await MainActor.run {
                    self.originalHoldings = fetchedHoldings
                    self.applyFiltersAndSort()
                    self.calculateSummary()
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    
                    // Try to load cached data as fallback
                    if let cachedHoldings = self.repository.getCachedHoldings() {
                        self.originalHoldings = cachedHoldings
                        self.applyFiltersAndSort()
                        self.calculateSummary()
                    }
                }
            }
        }
    }

    func refreshHoldings() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedHoldings = try await repository.refreshHoldings()
                
                await MainActor.run {
                    self.originalHoldings = fetchedHoldings
                    self.applyFiltersAndSort()
                    self.calculateSummary()
                    self.isLoading = false
                }
                
            } catch {
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

    func sortHoldings() {
        isSortAscending.toggle()
        // Ensure main thread
        if Thread.isMainThread {
            applyFiltersAndSort()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.applyFiltersAndSort()
            }
        }
    }

    func setSearchQuery(_ query: String) {

        searchWorkItem?.cancel()
        searchWorkItem = nil
        
        if Thread.isMainThread {
            searchQuery = query
            scheduleSearch()
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.searchQuery = query
                self.scheduleSearch()
            }
        }
    }

    private func scheduleSearch() {
        searchWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.applyFiltersAndSort()
        }
        
        searchWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    func clearSearch() {
        searchWorkItem?.cancel()
        searchWorkItem = nil
    
        if Thread.isMainThread {
            searchQuery = ""
            applyFiltersAndSort()
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.searchQuery = ""
                self.applyFiltersAndSort()
            }
        }
    }
    
    // MARK: - Private Methods

    private func applyFiltersAndSort() {

        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.applyFiltersAndSort()
            }
            return
        }

        let currentOriginalHoldings: [Holding]
        let currentSearchQuery: String
        let currentSortAscending: Bool

        currentOriginalHoldings = self.originalHoldings
        currentSearchQuery = self.searchQuery
        currentSortAscending = self.isSortAscending
    
        guard !currentOriginalHoldings.isEmpty else {
            if !holdings.isEmpty {
                holdings = []
            }
            if portfolioSummary != nil {
                portfolioSummary = nil
            }
            return
        }
        
        var filteredHoldings = currentOriginalHoldings

        if !currentSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let trimmedQuery = currentSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            filteredHoldings = currentOriginalHoldings.filter { holding in
                holding.symbol.localizedCaseInsensitiveContains(trimmedQuery)
            }
        }

        filteredHoldings.sort { holding1, holding2 in
            if currentSortAscending {
                return holding1.symbol.localizedCaseInsensitiveCompare(holding2.symbol) == .orderedAscending
            } else {
                return holding1.symbol.localizedCaseInsensitiveCompare(holding2.symbol) == .orderedDescending
            }
        }
        
        // Update holdings and summary - these @Published properties will trigger UI updates
        holdings = filteredHoldings
        calculateSummary()
    }
    
    /// Calculates and updates the portfolio summary from current holdings
    private func calculateSummary() {
        guard !holdings.isEmpty else {
            portfolioSummary = nil
            return
        }
        portfolioSummary = PortfolioSummary(holdings: holdings)
    }
    
    /// Creates view models for holding cells
    /// - Returns: Array of HoldingCellViewModel
    func getCellViewModels() -> [HoldingsCellViewModel] {
        return holdings.map { HoldingsCellViewModel(holding: $0) }
    }
}


