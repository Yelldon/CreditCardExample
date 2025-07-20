//
//  CompletionModalView.swift
//  CreditCard
//
//  Created by Greg Patrick on 7/19/25.
//

import SwiftUI

struct CompletionModalView: View {
    @State var creditCardState = CreditCardState.shared
    
    var body: some View {
        ZStack {
            if isFormComplete {
                VStack {
                    VStack {
                        Text("Congratulations")
                            .font(.title2)
                            .padding(.bottom)
                        
                        Text("Your credit card has been accepted")
                            .font(.body)
                            .padding(.bottom)
                        
                        Button("OK") {
                            creditCardState.resetFormSubmit()
                        }
                    }
                    .padding()
                    
                }
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .clipped()
                .shadow(radius: 20)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.bouncy, value: isFormComplete)
    }
}

// MARK: Variables
extension CompletionModalView {
    var isFormComplete: Bool {
        creditCardState.isComplete
    }
}

#Preview {
    @Previewable @State var creditCardState = CreditCardState()
    
    CompletionModalView(creditCardState: creditCardState)
        .onAppear {
            creditCardState.isSubmitting = true
            creditCardState.isComplete = true
        }
}
