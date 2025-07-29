//
//  GlobalEnums.swift
//  CreditCardExample
//
//  Created by Greg Patrick on 7/21/25.
//

/// Credit Card Types
enum CreditCardType {
    case visa
    case mastercard
    case americanExpress
    case dinersClub
    case discover
    case unknown
}

/// Field Types
enum FieldType {
    case cardNumber
    case expirationDate
    case cvv
    case nameOnCard
}

/// Field Errors
enum FieldErrors {
    case required
    case notEnoughDigits
    case dateExpired
    case dateInvalid
}
