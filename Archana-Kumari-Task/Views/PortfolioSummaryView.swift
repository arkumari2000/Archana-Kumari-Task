//
//  PortfolioSummaryView.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 24/12/25.
//

import UIKit

class PortfolioSummaryView: UIView {
    
    // MARK: - Properties

    var onExpandCollapseTapped: (() -> Void)?
    private var isExpanded: Bool = false
    private var contentViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - UI Components
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profit & Loss*"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expandCollapseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let currentValueRow = SummaryRowView()
    private let totalInvestmentRow = SummaryRowView()
    private let todayPNLRow = SummaryRowView()
    private let totalPNLRow = SummaryRowView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {

        backgroundColor = .systemBackground

        addSubview(headerView)
        addSubview(contentView)
        
        headerView.addSubview(headerTitleLabel)
        headerView.addSubview(expandCollapseButton)
        
        contentView.addSubview(stackView)
        
        // Vertical Stack with Rows
        stackView.addArrangedSubview(currentValueRow)
        stackView.addArrangedSubview(totalInvestmentRow)
        stackView.addArrangedSubview(todayPNLRow)
        stackView.addArrangedSubview(totalPNLRow)
    
        expandCollapseButton.addTarget(self, action: #selector(expandCollapseTapped), for: .touchUpInside)
    
        NSLayoutConstraint.activate([
            // Header view
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            // Header title
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerTitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            // Expand/collapse button
            expandCollapseButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            expandCollapseButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            expandCollapseButton.widthAnchor.constraint(equalToConstant: 30),
            expandCollapseButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        contentViewHeightConstraint.isActive = true

        contentView.isHidden = true
    }
    
    // MARK: - Actions
    
    @objc private func expandCollapseTapped() {
        toggleExpansion()
        onExpandCollapseTapped?()
    }
    
    // MARK: - Public Methods
    func configure(with summary: PortfolioSummary) {
        currentValueRow.configure(
            title: "Current value",
            value: summary.currentValue.formattedAsCurrency()
        )
        
        totalInvestmentRow.configure(
            title: "Total investment",
            value: summary.totalInvestment.formattedAsCurrency()
        )
        
        let todayPNL = summary.todayProfitAndLoss
        let todayPNLText = "\(todayPNL >= 0 ? "+" : "")\(todayPNL.formattedAsCurrency())"
        todayPNLRow.configure(
            title: "Today's PNL",
            value: todayPNLText,
            isProfit: todayPNL >= 0
        )
        
        let totalPNL = summary.totalProfitAndLoss
        let totalPNLText = "\(totalPNL >= 0 ? "+" : "")\(totalPNL.formattedAsCurrency()) (\(String(format: "%.2f", summary.totalProfitAndLossPercentage))%)"
        totalPNLRow.configure(
            title: "Total PNL",
            value: totalPNLText,
            isProfit: totalPNL >= 0
        )
    }

    func setExpanded(_ expanded: Bool, animated: Bool = true) {
        guard isExpanded != expanded else { return }
        isExpanded = expanded
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.updateExpansionState()
            }
        } else {
            updateExpansionState()
        }
    }
    
    // MARK: - Private Methods
    
    private func toggleExpansion() {
        setExpanded(!isExpanded)
    }
    
    private func updateExpansionState() {

        contentViewHeightConstraint.constant = isExpanded ? 200 : 0
        contentView.isHidden = !isExpanded
        let imageName = isExpanded ? "chevron.up" : "chevron.down"
        expandCollapseButton.setImage(UIImage(systemName: imageName), for: .normal)
        layoutIfNeeded()
    }
}
