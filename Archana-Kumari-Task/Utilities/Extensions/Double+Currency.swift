//
//  Double+Currency.swift
//  Archana-Kumari-Task
//
//  Created by Archana Kumari on 24/12/25.
//

import Foundation

extension Double {

    /// Formats the double value as Indian Rupee currency: Formatted string with ₹
    func formattedAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_IN")
        
        return formatter.string(from: NSNumber(value: self)) ?? "₹ 0.00"
    }
}
