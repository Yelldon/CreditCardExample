//
//  MockData.swift
//  CreditCardExample
//
//  Created by Greg Patrick on 7/21/25.
//

final class MockData {
    static var emptyCreditCardState: CreditCardState {
       return CreditCardState()
    }
    
    static var baseCreditCardState: CreditCardState {
        let state = CreditCardState()
        state.cardNumber = "4111 5678 9012 3456"
        state.nameOnCard = "John Doe"
        state.expirationDate = "12/24"
        state.cvv = "123"
        
        return state
    }
    
    static var flippedCreditCardState: CreditCardState {
        let state = baseCreditCardState
        state.isFlipped = true
        
        return state
    }
    
    static var completeCreditCardState: CreditCardState {
        let state = baseCreditCardState
        state.isComplete = true
        
        return state
    }
}
