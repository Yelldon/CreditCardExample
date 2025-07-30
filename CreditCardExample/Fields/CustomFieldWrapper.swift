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
            .onChange(of: creditCardState.isComplete) { oldValue, newValue in
                // This handles resetting the field errors back to initial when
                // For submit has been complete.
                if oldValue && !newValue {
                    field.error.wrappedValue = .initial
                }
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
            let cardType = creditCardState.checkCreditCardType
            return cardType == .americanExpress ? "CID" : "CVV"
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
            return getNotEnoughDigitsMessage()
        case .dateExpired:
            return "Card has expired."
        case .dateInvalid:
            return "The date is invalid."
        case .invalidCardNumber:
            return "Invalid card number."
        case .nameTooLong:
            return "Name is too long (max 36 characters)."
        default:
            return "Unknown error."
        }
    }
}

// MARK: Field Validation
private extension CustomFieldWrapper {
    func handleFieldValidation(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if field is empty first
        guard !trimmedText.isEmpty else {
            field.error.wrappedValue = .required
            onValidation?()
            return
        }
        
        // Perform field-specific validation
        let validationResult = validateFieldContent(trimmedText)
        field.error.wrappedValue = validationResult
        onValidation?()
    }
    
    func getNotEnoughDigitsMessage() -> String {
        switch fieldType {
        case .cardNumber:
            let cardType = creditCardState.checkCreditCardType
            let expectedLength = maxDigitsForCardType(cardType)
            return "Card number must be \(expectedLength) digits."
        case .expirationDate:
            return "Enter a valid MM/YY date."
        case .cvv:
            let cardType = creditCardState.checkCreditCardType
            let expectedLength = cvvLengthForCardType(cardType)
            let codeType = cardType == .americanExpress ? "CID" : "CVV"
            return "\(codeType) must be \(expectedLength) digits."
        case .nameOnCard:
            return "Name must be at least 2 characters."
        }
    }
    
    func validateFieldContent(_ text: String) -> FieldError? {
        switch fieldType {
        case .cardNumber:
            return validateCardNumber(text)
        case .expirationDate:
            return validateExpirationDate(text)
        case .cvv:
            return validateCVV(text)
        case .nameOnCard:
            return validateNameOnCard(text)
        }
    }
    
    func validateCardNumber(_ text: String) -> FieldError? {
        let digits = text.filter { $0.isNumber }
        let cardType = creditCardState.checkCreditCardType
        let expectedLength = maxDigitsForCardType(cardType)
        
        if digits.count < expectedLength {
            return .notEnoughDigits
        }
        
        return nil // Valid
    }
    
    func validateExpirationDate(_ text: String) -> FieldError? {
        let digits = text.filter { $0.isNumber }
        
        if digits.count < 4 {
            return .notEnoughDigits
        }
        
        let month = Int(String(digits.prefix(2))) ?? 0
        let year = Int(String(digits.suffix(2))) ?? 0
        let currentYear = Calendar.current.component(.year, from: Date()) % 100
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        if month < 1 || month > 12 {
            return .dateInvalid
        }
        
        if year < currentYear || (year == currentYear && month < currentMonth) {
            return .dateExpired
        }
        
        return nil // Valid
    }
    
    func validateCVV(_ text: String) -> FieldError? {
        let digits = text.filter { $0.isNumber }
        let cardType = creditCardState.checkCreditCardType
        let expectedLength = cvvLengthForCardType(cardType)
        
        if digits.count < expectedLength {
            return .notEnoughDigits
        }
        
        return nil // Valid
    }
    
    func validateNameOnCard(_ text: String) -> FieldError? {
        if text.count < 2 {
            return .notEnoughDigits
        }
        
        if text.count > 36 {
            return .nameTooLong
        }
        
        return nil // Valid
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
