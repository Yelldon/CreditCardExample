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
        state.cardNumber.text = "4111 5678 9012 3456"
        state.nameOnCard.text = "John Doe"
        state.expirationDate.text = "12/24"
        state.cvv.text = "123"
        
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
    
    static var creditCardErrorState: CreditCardState {
        let state = emptyCreditCardState
        state.nameOnCard.text = ""
        state.nameOnCard.error = .required
        
        return state
    }
}
