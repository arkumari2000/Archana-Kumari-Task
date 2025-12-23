//
//  HoldingsTVC.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 24/12/25.
//

import UIKit

class HoldingsTVC: UITableViewCell {
    
    // MARK: - UI Components
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ltpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profitLossLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quantityPrefixLabel: UILabel = {
        let label = UILabel()
        label.text = "NET QTY:"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ltpPrefixLabel: UILabel = {
        let label = UILabel()
        label.text = "LTP:"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pnlPrefixLabel: UILabel = {
        let label = UILabel()
        label.text = "P&L:"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration

    func configure(with viewModel: HoldingsCellViewModel) {
        symbolLabel.text = viewModel.symbol
        quantityLabel.text = viewModel.quantityText
        ltpLabel.text = viewModel.ltpText
        profitLossLabel.text = viewModel.profitAndLossText
        profitLossLabel.textColor = viewModel.profitAndLossColor
    }
    
    // MARK: - Setup
    
    private func setupUI() {

        contentView.addSubview(symbolLabel)
        contentView.addSubview(quantityPrefixLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(ltpPrefixLabel)
        contentView.addSubview(ltpLabel)
        contentView.addSubview(pnlPrefixLabel)
        contentView.addSubview(profitLossLabel)
        
        selectionStyle = .none
        backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            // Symbol label - top left
            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Quantity section - left side, below symbol
            quantityPrefixLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 8),
            quantityPrefixLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            quantityLabel.topAnchor.constraint(equalTo: quantityPrefixLabel.topAnchor),
            quantityLabel.leadingAnchor.constraint(equalTo: quantityPrefixLabel.trailingAnchor, constant: 8),
            quantityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            // LTP section - right side, top
            ltpPrefixLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            ltpPrefixLabel.trailingAnchor.constraint(equalTo: ltpLabel.leadingAnchor, constant: -8),
            
            ltpLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            ltpLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // P&L section - right side, below LTP
            pnlPrefixLabel.topAnchor.constraint(equalTo: ltpLabel.bottomAnchor, constant: 8),
            pnlPrefixLabel.trailingAnchor.constraint(equalTo: profitLossLabel.leadingAnchor, constant: -8),
            
            profitLossLabel.topAnchor.constraint(equalTo: ltpLabel.bottomAnchor, constant: 8),
            profitLossLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            profitLossLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        quantityLabel.text = nil
        ltpLabel.text = nil
        profitLossLabel.text = nil
    }
}
