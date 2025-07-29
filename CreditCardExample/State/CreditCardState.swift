//
//  CreditCardState.swift
//  CreditCard
//
//  Created by Greg Patrick on 7/18/25.
//

import Foundation
import Observation

@Observable
final class CreditCardState {
    var cardNumber: String = ""
    var expirationDate: String = ""
    var cvv: String = ""
    var nameOnCard: String = ""
    
    var validCardNumber: Bool = false
    var validExpirationDate: Bool = false
    var validCvv: Bool = false
    var validNameOnCard: Bool = false
    
    var isFlipped: Bool = false
    var isSubmitting: Bool = false
    var isComplete: Bool = false
}

// MARK: Helpers
extension CreditCardState {
    /// Check the credit card type
    var checkCreditCardType: CreditCardType {
        let digits = cardNumber.filter { $0.isNumber }
        guard !digits.isEmpty else { return .unknown }
        
        let firstDigit = String(digits.prefix(1))
        let firstTwo = String(digits.prefix(2))
        let firstFour = String(digits.prefix(4))
        
        switch firstDigit {
        case "4":
            return .visa
        case "5":
            if ["51", "52", "53", "54", "55"].contains(firstTwo) {
                return .mastercard
            }
        case "3":
            if ["34", "37"].contains(firstTwo) {
                return .americanExpress
            } else if firstTwo == "30" || firstTwo == "36" || firstTwo == "38" {
                return .dinersClub
            }
        case "6":
            if firstFour == "6011" || firstTwo == "65" {
                return .discover
            }
        default:
            return .unknown
        }
        
        return .unknown
    }
    
    /// Generate a random credit card number and related information
    func generateRandomCreditCard() {
        let cardTypes: [CreditCardType] = [.visa, .mastercard, .americanExpress, .discover, .dinersClub]
        let randomType = cardTypes.randomElement() ?? .visa
        
        var prefix: String
        var length: Int
        
        switch randomType {
        case .visa:
            prefix = "4"
            length = 16
        case .mastercard:
            prefix = ["51", "52", "53", "54", "55"].randomElement() ?? "51"
            length = 16
        case .americanExpress:
            prefix = ["34", "37"].randomElement() ?? "34"
            length = 15
        case .discover:
            prefix = "6011"
            length = 16
        case .dinersClub:
            prefix = ["30", "36", "38"].randomElement() ?? "30"
            length = 14
        default:
            prefix = "4"
            length = 16
        }
        
        var number = prefix
        let remainingDigits = length - prefix.count
        
        for _ in 0 ..< remainingDigits {
            number += String(Int.random(in: 0...9))
        }
        
        cardNumber = number.enumerated().map { index, char in
            index > 0 && index % 4 == 0 ? " \(char)" : "\(char)"
        }.joined()
        
        nameOnCard = "John Doe"
        
        // Generate random expiration date (future date)
        let currentYear = Calendar.current.component(.year, from: Date()) % 100
        let randomMonth = Int.random(in: 1...12)
        let randomYear = Int.random(in: currentYear...(currentYear + 5))
        expirationDate = String(format: "%02d/%02d", randomMonth, randomYear)
        
        // Generate random CVV
        if randomType == .americanExpress {
            cvv = String(format: "%04d", Int.random(in: 100...999))
        } else {
            cvv = String(format: "%03d", Int.random(in: 100...999))
        }
        
    }
    
    func flipCard() {
        isFlipped.toggle()
    }
    
    func formSubmit() {
        isSubmitting = true
    }
    
    func formComplete() {
        isComplete = true
    }
    
    func resetFormSubmit() {
        isSubmitting = false
        isComplete = false
        
        // Reset the fields
        cardNumber = ""
        expirationDate = ""
        cvv = ""
        nameOnCard = ""
    }
    
    var isFormInvalid: Bool {
        !validCardNumber &&
        !validExpirationDate &&
        !validCvv &&
        !validNameOnCard
    }
    
    func validateForm(_ value: Bool, for fieldType: FieldType) {
        switch fieldType {
        case .cardNumber:
            validCardNumber = value
        case .cvv:
            validCvv = value
        case .expirationDate:
            validExpirationDate = value
        case .nameOnCard:
            validNameOnCard = value
        }
    }
}

//fileprivate extension CreditCardState {
struct FieldValidator {
    let isValid: Bool
    let reason: String?
}
//}
