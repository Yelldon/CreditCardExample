//
//  FieldHelpers.swift
//  CreditCardExample
//
//  Created by Greg Patrick on 7/30/25.
//

// MARK: Card Type Detection and Formatting
func cvvLengthForCardType(_ cardType: CreditCardType) -> Int {
    switch cardType {
    case .americanExpress:
        return 4 // American Express uses 4-digit CVV
    default:
        return 3 // Most cards use 3-digit CVV
    }
}

func maxDigitsForCardType(_ cardType: CreditCardType) -> Int {
    switch cardType {
    case .americanExpress:
        return 15
    case .dinersClub:
        return 14
    case .visa, .mastercard, .discover:
        return 16
    case .unknown:
        return 16 // Default to 16 for unknown cards
    }
}

func formatCardNumber(_ digits: String, for cardType: CreditCardType) -> String {
    switch cardType {
    case .americanExpress:
        // American Express: 4-6-5 format
        return formatAmericanExpress(digits)
    case .dinersClub:
        // Diners Club: 4-6-4 format
        return formatDinersClub(digits)
    case .visa, .mastercard, .discover, .unknown:
        // Standard: 4-4-4-4 format
        return formatStandard(digits)
    }
}

private func formatStandard(_ digits: String) -> String {
    // Format as 4-4-4-4
    return digits.enumerated().map { index, char in
        index > 0 && index % 4 == 0 ? " \(char)" : "\(char)"
    }.joined()
}

private func formatAmericanExpress(_ digits: String) -> String {
    // Format as 4-6-5 (spaces after positions 4 and 10)
    return digits.enumerated().map { index, char in
        if index == 4 || index == 10 {
            return " \(char)"
        }
        return "\(char)"
    }.joined()
}

private func formatDinersClub(_ digits: String) -> String {
    // Format as 4-6-4 (spaces after positions 4 and 10)
    return digits.enumerated().map { index, char in
        if index == 4 || index == 10 {
            return " \(char)"
        }
        return "\(char)"
    }.joined()
}
