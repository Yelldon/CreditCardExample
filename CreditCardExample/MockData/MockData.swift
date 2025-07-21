//
//  MockData.swift
//  CreditCardExample
//
//  Created by Greg Patrick on 7/21/25.
//

final class MockData {
    static func emptyCreditCardState() -> CreditCardState {
       return CreditCardState()
    }
    
    static func baseCreditCardState() -> CreditCardState {
        let state = CreditCardState()
        state.cardNumber = "4111 5678 9012 3456"
        state.nameOnCard = "John Doe"
        state.expirationDate = "12/24"
        state.cvv = "123"
        
        return state
    }
    
    static func flippedCreditCardState() -> CreditCardState {
        let state = CreditCardState()
        state.cardNumber = "4111 5678 9012 3456"
        state.nameOnCard = "John Doe"
        state.expirationDate = "12/24"
        state.cvv = "123"
        state.isFlipped = true
        
        return state
    }
    
    static func completeCreditCardState() -> CreditCardState {
        let state = CreditCardState()
        state.isComplete = true
        
        return state
    }
}
