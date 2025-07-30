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
    var onValidation: (() -> Void)?
    var onEditingChanged: ((Bool) -> Void)?
    
    @State var focused: Bool = false
    
    @ScaledMetric(relativeTo: .caption) var scaledOffset: CGFloat = 8
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                CustomField(
                    fieldType: fieldType,
                    text: field.text,
                    placeholder: placeholder,
                    onEditingChanged: { isEditing in
                        onEditingChanged?(isEditing)
                        focused = isEditing
                    }
                )
                .fieldBorder(borderColor: borderColor)
                
                ZStack {
                    if hasError {
                        Text(errorMessage)
                            .padding(.horizontal, 6)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.25)
                            .transition(
                                AnyTransition.move(edge: .top)
                                    .combined(with: .opacity)
                            )
                    }
                }
                .animation(.easeInOut.speed(3), value: hasError)
            }
            .onChange(of: field.text.wrappedValue) { _, newValue in
                // Handle all the field validation here
                handleFieldValidation(newValue)
            }
        }
        .animation(.easeInOut, value: hasError)
    }
}

extension CustomFieldWrapper {
    var field: Binding<FieldInfo> {
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
        guard field.error.wrappedValue != .initial else {
            return false
        }
        
        return field.error.wrappedValue != nil
    }
    
    var errorMessage: String {
        switch field.error.wrappedValue {
        case .initial:
            return ""
        case .required:
            return "\(placeholder) is required."
        case .notEnoughDigits:
            return "Not enough digits."
        case .dateExpired:
            return "Card has expired."
        case .dateInvalid:
            return "The date is invalid."
        default:
            return "Unknown error."
        }
    }
}

// MARK: Field Validation
private extension CustomFieldWrapper {
    func handleFieldValidation(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            field.error.wrappedValue = .required
            onValidation?()
            return
        }
        
        field.error.wrappedValue = nil
        onValidation?()
    }
}

#Preview {
    @Previewable var focused = true

    VStack(spacing: 24) {
        CustomFieldWrapper(
            fieldType: .nameOnCard
        )
        .environment(MockData.baseCreditCardState)
        
        CustomFieldWrapper(
            fieldType: .nameOnCard,
            focused: focused
        )
        .environment(MockData.baseCreditCardState)
                
        CustomFieldWrapper(
            fieldType: .nameOnCard,
        )
        .environment(MockData.creditCardErrorState)
    }
    .padding()
}
