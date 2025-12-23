//
//  PortfolioViewController.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 23/12/25.
//

import UIKit
import Combine

class PortfolioViewController: UIViewController {
    
    // MARK: - Properties
    
    let viewModel: PortfolioViewModel
    private var cancellables = Set<AnyCancellable>()
    private var sortButton: UIBarButtonItem?
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    private let summaryView: PortfolioSummaryView = {
        let view = PortfolioSummaryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search by symbol..."
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.isHidden = true
        return searchBar
    }()
    
    var isSearchActive: Bool = false
    private var searchBarHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Initialization
    
    init(viewModel: PortfolioViewModel = PortfolioViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupTableView()
        bindViewModel()
        viewModel.loadHoldings()
    }
    
    deinit {
        // Cleanup Combine subscriptions
        cancellables.removeAll()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(summaryView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)
        
        // Setup constraints
        searchBarHeightConstraint = searchBar.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            // Search bar
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBarHeightConstraint,
            
            // Table view
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: summaryView.topAnchor),
            
            // Summary view
            summaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            summaryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Error label
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        
        // Setup summary view callback
        summaryView.onExpandCollapseTapped = { [weak self] in
            self?.viewModel.toggleSummaryExpansion()
        }
        
        // Setup search bar
        searchBar.delegate = self
    }
    
    private func setupNavigationBar() {
        // Create custom navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.0, green: 0.2, blue: 0.4, alpha: 1.0) // Dark blue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        title = nil
        
        let profileButton = CustomUIBarButton.create(
            icon: "person.circle",
            text: "Portfolio",
            iconColor: .white,
            textColor: .white
        )
        navigationItem.leftBarButtonItem = profileButton
        
        let sortBtn = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.arrow.down"),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        sortBtn.tintColor = .white
        sortButton = sortBtn
        
        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(searchButtonTapped)
        )
        searchButton.tintColor = .white
        
        navigationItem.rightBarButtonItems = [searchButton, sortBtn]
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HoldingsTVC.self, forCellReuseIdentifier: "HoldingCell")
        
        // Add pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func bindViewModel() {
        // Bind holdings
        viewModel.$holdings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateSummary()
            }
            .store(in: &cancellables)
        
        // Bind loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        // Bind error state
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.errorLabel.text = errorMessage
                    self?.errorLabel.isHidden = false
                } else {
                    self?.errorLabel.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        // Bind summary expansion state
        viewModel.$isSummaryExpanded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isExpanded in
                self?.summaryView.setExpanded(isExpanded, animated: true)
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: - Actions
    
    @objc private func refreshData() {
        viewModel.refreshHoldings()
    }
    
    @objc private func sortButtonTapped() {
        viewModel.sortHoldings()
    }
    
    @objc private func searchButtonTapped() {
        toggleSearchBar()
    }
    
    // MARK: - Helper Methods
    
    private func updateSummary() {
        if let summary = viewModel.portfolioSummary {
            summaryView.configure(with: summary)
        }
    }
    
    func toggleSearchBar() {
        isSearchActive.toggle()
        
        UIView.animate(withDuration: 0.3) {
            if self.isSearchActive {
                self.searchBar.isHidden = false
                self.searchBarHeightConstraint.constant = 56
                self.searchBar.becomeFirstResponder()
            } else {
                self.searchBar.resignFirstResponder()
                self.searchBarHeightConstraint.constant = 0
                self.viewModel.clearSearch()
            }
            self.view.layoutIfNeeded()
        } completion: { _ in
            if !self.isSearchActive {
                self.searchBar.isHidden = true
            }
        }
    }
}
