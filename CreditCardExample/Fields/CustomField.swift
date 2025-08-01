//
//  CustomField.swift
//  CreditCard
//
//  Created by Greg Patrick on 6/28/25.
//

import SwiftUI
import UIKit

struct CustomField: UIViewRepresentable {
    @Environment(CreditCardState.self) var creditCardState: CreditCardState
    
    let fieldType: FieldType
    @Binding var text: String
    var placeholder: String
    var onEditingChanged: (Bool) -> Void
    
    func createKeyboardType() -> UIKeyboardType {
        switch fieldType {
        case .cardNumber:
            return .decimalPad
        case .expirationDate:
            return .numberPad
        case .cvv:
            return .decimalPad
        case .nameOnCard:
            return .default
        }
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = createKeyboardType()
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        
        context.coordinator.textField = textField
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        // The placeholder may change in the middle of editing the fields,
        // so we change that here.
        uiView.placeholder = placeholder
        
        if uiView.text != text {
            let cursorPosition = uiView.selectedTextRange
            uiView.text = text
            
            // Restore cursor position if possible
            if let cursorPosition {
                uiView.selectedTextRange = cursorPosition
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: CustomField
        weak var textField: UITextField?
        
        init(_ parent: CustomField) {
            self.parent = parent
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            handleFieldType(textField)
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onEditingChanged(true)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onEditingChanged(false)
        }
    }
}

// MARK: Handle Fields
extension CustomField.Coordinator {
    func handleFieldType(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        let creditCardType: CreditCardType = parent.creditCardState.checkCreditCardType
        let oldText = parent.text
        var newCursorOffset: Int?
        
        switch parent.fieldType {
        case .cardNumber:
            // Filter to numbers only
            let digits = text.filter { $0.isNumber }
            let maxDigits = maxDigitsForCardType(creditCardType)
            
            // If we already have maximum digits for this card type, don't allow more
            if digits.count > maxDigits {
                debugPrint("Too many digits for \(creditCardType)")
                textField.text = oldText // Restore previous valid text
                return
            }
            
            // Store current cursor position and calculate digit position
            let cursorPosition = textField.selectedTextRange
            let cursorOffset = textField.offset(from: textField.beginningOfDocument, to: cursorPosition?.start ?? textField.beginningOfDocument)
            
            // Count digits before cursor position in the original text
            let textBeforeCursor = String(text.prefix(cursorOffset))
            let digitsBeforeCursor = textBeforeCursor.filter { $0.isNumber }.count
            
            // Format the text based on card type
            let formatted = formatCardNumber(digits, for: creditCardType)
            
            // Calculate new cursor position based on digit count
            var calculatedCursorOffset = 0
            var digitCount = 0
            
            for (index, char) in formatted.enumerated() {
                if char.isNumber {
                    digitCount += 1
                    if digitCount == digitsBeforeCursor {
                        calculatedCursorOffset = index + 1
                        break
                    }
                }
            }
            
            // If we're at the end, set cursor to end
            if digitsBeforeCursor >= digits.count {
                calculatedCursorOffset = formatted.count
            }
            
            newCursorOffset = calculatedCursorOffset
            
            // Update the binding and text field
            parent.text = formatted
            textField.text = formatted
        case .expirationDate:
            let digits = text.filter { $0.isNumber }.prefix(4)
            let currentText = parent.text
            
            // Handle backspace on the forward slash (/)
            if text.count < currentText.count && currentText.contains("/") && !text.contains("/") {
                // User backspaced on the slash, remove last digit and slash
                let digitsOnly = currentText.filter { $0.isNumber }
                if digitsOnly.count > 0 {
                    let newDigits = String(digitsOnly.dropLast())
                    parent.text = newDigits
                    textField.text = newDigits
                    
                    // Set cursor to end
                    DispatchQueue.main.async {
                        let endPosition = textField.endOfDocument
                        textField.selectedTextRange = textField.textRange(from: endPosition, to: endPosition)
                    }
                }
                return
            }
            
            var formatted: String
            
            if digits.count >= 2 {
                let month = String(digits.prefix(2))
                let year = String(digits.dropFirst(2))
                formatted = year.isEmpty ? "\(month)/" : "\(month)/\(year)"
                
                // Set cursor to end when slash is auto-added
                if digits.count == 2 && !currentText.contains("/") {
                    newCursorOffset = formatted.count
                }
            } else {
                formatted = String(digits)
            }
            
            parent.text = formatted
            textField.text = formatted
        case .cvv:
            // Get the current card type from the card number to determine CVV length
            let digits = text.filter { $0.isNumber }
            let maxCvvLength = cvvLengthForCardType(creditCardType)
            let formatted = String(digits.prefix(maxCvvLength))
            
            parent.text = formatted
            textField.text = formatted
        case .nameOnCard:
            if text.count > 36 {
                debugPrint("String too long")
                textField.text = oldText // Restore previous valid text
                return
            }
            
            parent.text = text
            textField.text = text
        }
        
        // Restore cursor position
        if let newCursorOffset {
            DispatchQueue.main.async {
                if let newPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorOffset) {
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
            }
        }
    }
}
