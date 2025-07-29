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
    
    @FocusState private var focus: FieldType?
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 8
    
    @State private var cardRotation: Double = 0
    
    var body: some View {
        ZStack {
            if isWideLayout {
                horizontalLayout
            } else {
                verticalLayout
            }
            
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
                }
                .padding()
                .zIndex(1)
            }
            .scrollDisabled(isFormSubmitting)
        }
    }
    
    @ViewBuilder private var formContent: some View {
        @Bindable var bindState = creditCardState
        
        VStack(spacing: 18) {
            CustomFieldWrapper(
                fieldType: .nameOnCard,
            )
            .focused($focus, equals: .nameOnCard)

            CustomFieldWrapper(
                fieldType: .cardNumber,
            )
            .focused($focus, equals: .cardNumber)
                
            ViewThatFits(in: .horizontal) {
                HStack {
                    horizontalForm
                }
                
                VStack(spacing: 18) {
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
                .disabled(creditCardState.isFormInvalid || isFormSubmitting)
            }
            .padding(.vertical)
        }
        .blur(radius: isFormSubmitting ? 8 : 0)
        .animation(.easeInOut, value: isFormSubmitting)
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
                .padding(scaledPadding)
                .minimumScaleFactor(0.75)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
        .opacity(isFormSubmitting ? 0 : 1)
        .accessibilityHidden(isFormSubmitting)
    }
    
    @ViewBuilder var horizontalForm: some View {
        @Bindable var bindState = creditCardState
        
        CustomFieldWrapper(
            fieldType: .cvv
        ) { _ in
            creditCardState.flipCard()
        }
        .focused($focus, equals: .cvv)
        
        CustomFieldWrapper(
            fieldType: .expirationDate
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
}

#Preview {
    FormView()
        .environment(MockData.emptyCreditCardState)
}
