//
//  CustomUIBarButton.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 24/12/25.
//

import UIKit

class CustomUIBarButton {

    static func create(
        icon: String,
        text: String,
        iconColor: UIColor = .white,
        textColor: UIColor = .white,
        fontSize: CGFloat = 18,
        fontWeight: UIFont.Weight = .semibold,
        spacing: CGFloat = 8,
        iconSize: CGFloat = 24,
        target: Any? = nil,
        action: Selector? = nil
    ) -> UIBarButtonItem {
        // Create icon image view
        let iconImage = UIImage(systemName: icon)
        let iconImageView = UIImageView(image: iconImage)
        iconImageView.tintColor = iconColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        
        // Create text label
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.textColor = textColor
        textLabel.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create container view
        let containerView = UIView()
        containerView.addSubview(iconImageView)
        containerView.addSubview(textLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            textLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: spacing),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Create bar button item
        let barButtonItem = UIBarButtonItem(customView: containerView)
        
        // Set target and action if provided
        if let target = target, let action = action {
            let tapGesture = UITapGestureRecognizer(target: target, action: action)
            containerView.addGestureRecognizer(tapGesture)
            containerView.isUserInteractionEnabled = true
        }
        
        return barButtonItem
    }
}
