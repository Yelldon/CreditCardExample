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
    var onValidation: ((FieldType, Bool) -> Void)?
    var onEditingChanged: ((Bool) -> Void)?
    
    @State var focused: Bool = false
    @State var error: FieldErrors? = .initial
    
    @ScaledMetric(relativeTo: .caption) var scaledOffset: CGFloat = 8
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                CustomField(
                    fieldType: fieldType,
                    text: text,
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
            .onChange(of: text.wrappedValue) { _, newValue in
                guard !newValue.isEmpty else {
                    error = .required
                    onValidation?(fieldType, true)
                    return
                }
                
                error = nil
                onValidation?(fieldType, false)
            }
            .onChange(of: creditCardState.isComplete) { oldValue, newValue in
                if oldValue && !newValue {
                    error = .initial
                }
            }
        }
        .animation(.easeInOut, value: hasError)
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
        guard error != .initial else {
            return false
        }
        
        return error != nil
    }
    
    var errorMessage: String {
        switch error {
        case .initial:
            return ""
        case .required:
            return "\(placeholder) is required."
        default:
            return "Unknown error."
        }
    }
}

#Preview {
    @Previewable var focused = true
    @Previewable var error: FieldErrors = .required

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
            error: error
        )
        .environment(MockData.emptyCreditCardState)
    }
    .padding()
}
