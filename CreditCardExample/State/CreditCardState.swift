//
//  CreditCardState.swift
//  CreditCard
//
//  Created by Greg Patrick on 7/18/25.
//

import Foundation
import Observation

@Observable
class CreditCardState {
    static let shared = CreditCardState()
     
    var cardNumber: String = ""
    var expirationDate: String = ""
    var cvv: String = ""
    var nameOnCard: String = ""
    
    var isSubmitting: Bool = false
    var isComplete: Bool = false
}

extension CreditCardState {
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
        cvv = String(format: "%03d", Int.random(in: 100...999))
    }
    
    func formSubmit() {
        isSubmitting = true
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
}
