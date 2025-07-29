//
//  FormView.swift
//  CreditCard
//
//  Created by Greg Patrick on 6/28/25.
//

import SwiftUI

struct FormView: View {
    @Environment(CreditCardState.self) var creditCardState
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var cardRotation: Double = 0
    @State private var fieldErrors: [FieldType] = []
    
    @FocusState private var focus: FieldType?
    
    private var formSpacing: CGFloat = 20
    
    var body: some View {
        ZStack {
            ZStack {
                if isWideLayout {
                    horizontalLayout
                } else {
                    verticalLayout
                }
            }
            .animation(.easeInOut.speed(2), value: fieldErrors)
            
            CompletionModalView()
        }
        .onAppear {
            // Sets the focus on the initial view
            focus = .nameOnCard
        }
        .onChange(of: isFormComplete) { _, isComplete in
            // Reset the card positioning when the form was complete
            if !isComplete {
                cardRotation = 0
            }
        }
    }
}

// MARK: Variables
private extension FormView {
    var isWideLayout: Bool {
        horizontalSizeClass == .regular
    }
    
    var isFormSubmitting: Bool {
        creditCardState.isSubmitting
    }
    
    var isFormComplete: Bool {
        creditCardState.isComplete
    }
    
    var formInvalid: Bool {
        guard !creditCardState.allFieldsEmpty else {
            return true
        }
        
        return !fieldErrors.isEmpty
    }
}

// MARK: Views
private extension FormView {
    func baseViewStyle(geometry: GeometryProxy) -> some View {
        VStack {
            ZStack(alignment: .top) {
                ZStack {
                    GeometryReader { proxy in
                        CardReaderView()
                            .position(
                                x: geometry.size.width / 2,
                                y: isFormSubmitting ? geometry.size.height - geometry.size.height / 2 : -400
                            )
                            .animation(.spring.speed(0.8), value: isFormSubmitting)
                            .frame(height: isFormSubmitting ? proxy.size.height : 0)
                            .opacity(isFormSubmitting ? 1 : 0)
                    }
                }
                
                VStack {
                    Text("Submitting card...")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.indigo)
                        .offset(y: 100)
                        .padding(.top)
                }
                .opacity(isFormSubmitting && !isFormComplete ? 1 : 0)
                .transition(.opacity)
                .offset(
                    x: isWideLayout ? geometry.size.width / 4 : 0,
                    y: geometry.size.height / 2 + 50
                )
                .animation(.easeIn.delay(0.4), value: isFormSubmitting)
                .zIndex(4)
                
                ZStack {
                    VStack {
                        VStack {
                            CreditCardView()
                                .rotationEffect(.degrees(cardRotation))
                                .offset(
                                    x: isFormSubmitting ?
                                    (isWideLayout ? geometry.size.width / 4 : 0) : 0,
                                    y: isFormSubmitting ? geometry.size.height / 2 - 80 : 0
                                )
                                .transition(.slide)
                                .zIndex(3)
                        }
                        .animation(.spring.delay(0.3), value: isFormSubmitting)
                        .zIndex(2)
                        
                        generateRandomCardButton
                            .animation(.easeInOut, value: isFormSubmitting)
                            .zIndex(1)
                    }
                }
            }
            .blur(radius: isFormComplete ? 32 : 0)
            .animation(.spring, value: isFormComplete)
        }
        .zIndex(2)
    }
    
    var horizontalLayout: some View {
        GeometryReader { geometry in
            HStack(alignment: .center) {
                baseViewStyle(geometry: geometry)
                    
                ScrollView {
                    HStack {
                        formContent
                            .animation(.easeInOut.speed(2), value: fieldErrors)
                    }
                    .padding()
                    .zIndex(1)
                }
                .scrollDisabled(isFormSubmitting)
            }
            .padding(.top)
        }
    }
    
    var verticalLayout: some View {
        GeometryReader { geometry in
            ScrollView {
                baseViewStyle(geometry: geometry)
                
                VStack {
                    formContent
                        .animation(.easeInOut.speed(2), value: fieldErrors)
                }
                .padding()
                .zIndex(1)
            }
            .scrollDisabled(isFormSubmitting)
        }
    }
    
    @ViewBuilder private var formContent: some View {
        VStack(spacing: formSpacing) {
            CustomFieldWrapper(
                fieldType: .nameOnCard,
                onValidation: { field, value in
                    setFormValidValue(field, value: value)
                }
            )
            .focused($focus, equals: .nameOnCard)

            CustomFieldWrapper(
                fieldType: .cardNumber,
                onValidation: { field, value in
                    setFormValidValue(field, value: value)
                }
            )
            .focused($focus, equals: .cardNumber)
                
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: formSpacing) {
                    horizontalForm
                }
                
                VStack(spacing: formSpacing) {
                    horizontalForm
                }
            }
            
            VStack {
                Button(action: {
                    debugPrint("Credit Card Submitted")
                    focus = nil
                    randomRotation()
                    creditCardState.formSubmit()
                }) {
                    Text("Submit")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding(6)
                }
                .buttonStyle(.borderedProminent)
                .disabled(formInvalid || isFormSubmitting)
            }
            .padding(.vertical)
        }
        .blur(radius: isFormSubmitting ? 8 : 0)
        .animation(.easeInOut, value: isFormSubmitting)
        .animation(.easeInOut.speed(2), value: formInvalid)
        .accessibilityHidden(isFormSubmitting)
    }
    
    var generateRandomCardButton: some View {
        Button(action: {
            generateRandomCreditCard()
        }) {
            Text("Generate Credit Card")
                .font(.callout)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.blue)
                .padding(.top)
                .padding(.horizontal)
                .minimumScaleFactor(0.75)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
        .opacity(isFormSubmitting ? 0 : 1)
        .accessibilityHidden(isFormSubmitting)
    }
    
    @ViewBuilder var horizontalForm: some View {
        CustomFieldWrapper(
            fieldType: .cvv,
            onValidation: { field, value in
                setFormValidValue(field, value: value)
            }
        ) { _ in
            creditCardState.flipCard()
        }
        .focused($focus, equals: .cvv)
        
        CustomFieldWrapper(
            fieldType: .expirationDate,
            onValidation: { field, value in
                setFormValidValue(field, value: value)
            }
        )
        .focused($focus, equals: .expirationDate)
    }
}

// MARK: Functions
private extension FormView {
    func generateRandomCreditCard() {
        creditCardState.generateRandomCreditCard()
        
        focus = .expirationDate
    }
    
    func randomRotation() {
        cardRotation = Double(Int.random(in: -9...9))
    }
    
    func setFormValidValue(_ fieldType: FieldType, value: Bool) {
        if value {
            fieldErrors.append(fieldType)
        } else {
            fieldErrors.removeAll(where: { $0 == fieldType })
        }
    }
}

#Preview {
    FormView()
        .environment(MockData.emptyCreditCardState)
}
