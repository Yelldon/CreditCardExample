//
//  CustomFieldWrapper.swift
//  CreditCardExample
//
//  Created by Greg Patrick on 7/29/25.
//

import SwiftUI

struct CustomFieldWrapper: View {
    @Environment(CreditCardState.self) var creditCardState
    
    let fieldType: FieldType
    var onEditingChanged: ((Bool) -> Void)?
    
    @State var focused: Bool = false
    @State var error: FieldErrors?
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomField(
                fieldType: fieldType,
                text: text,
                placeholder: placeholder,
                onValidationCheck: { validation in
                    let formValidationValue = validation == nil ? true : false
                    
                    error = validation
                    creditCardState.validateForm(formValidationValue, for: fieldType)
                },
                onEditingChanged: { isEditing in
                    onEditingChanged?(isEditing)
                    focused = isEditing
                }
            )
            .fieldBorder(borderColor: borderColor)
            
            if hasError {
                ZStack {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
    }
}

extension CustomFieldWrapper {
    var text: Binding<String> {
        @Bindable var bindState = creditCardState
        
        switch fieldType {
        case .cvv:
            return $bindState.cvv
        case .expirationDate:
            return $bindState.expirationDate
        case .cardNumber:
            return $bindState.cardNumber
        case .nameOnCard:
            return $bindState.nameOnCard
        }
    }
    
    var placeholder: String {
        switch fieldType {
        case .cvv:
            return "CVV"
        case .expirationDate:
            return "Expiration"
        case .cardNumber:
            return "Card Number"
        case .nameOnCard:
            return "Name on Card"
        }
    }
    
    var borderColor: Color {
        if hasError {
            return .red
        } else {
            return focused ? .blue : .secondary
        }
    }
    
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String {
        switch error {
        case .required:
            return "\(placeholder) is required."
        default:
            return "Unknown error."
        }
    }
}

#Preview {
    @Previewable var hasError = true
    
    CustomFieldWrapper(
        fieldType: .nameOnCard
    )
    .environment(MockData.baseCreditCardState)
    .padding()
        
    CustomFieldWrapper(
        fieldType: .nameOnCard,
        error: .required
    )
    .environment(MockData.baseCreditCardState)
    .padding()
}
