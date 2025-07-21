//
//  FormView.swift
//  CreditCard
//
//  Created by Greg Patrick on 6/28/25.
//

import SwiftUI

struct FormView: View {
    @Environment(CreditCardState.self) var creditCardState
    
    @FocusState private var focus: FieldType?
    @ScaledMetric(relativeTo: .body) var scaledPadding: CGFloat = 8
    
    private let durationAndDelay: CGFloat = 0.15
    @State private var cardRotation: Double = 0
    
    var body: some View {
        ZStack {
            @Bindable var bindState = creditCardState
            
            GeometryReader { geometry in
                ScrollView {
                    ZStack {
                        GeometryReader { proxy in
                            CardReaderView()
                                .position(
                                    x: geometry.size.width / 2,
                                    y: isFormSubmitting ? geometry.size.height - geometry.size.height / 2 : -300
                                )
                                .animation(.spring.speed(0.8), value: isFormSubmitting)
                                .frame(height: isFormSubmitting ? proxy.size.height : 0)
                        }
                        
                        VStack {
                            Text("Submitting card...")
                                .font(.title)
                                .bold()
                                .foregroundStyle(.indigo)
                                .offset(y: 40)
                                .padding(.top)
                        }
                        .opacity(
                            isFormSubmitting && !isFormComplete ? 1 : 0
                        )
                        .transition(.opacity)
                        .offset(y: geometry.size.height / 2 + 50)
                        .animation(.easeIn.delay(0.4), value: isFormSubmitting)
                        .zIndex(4)
                        
                        VStack {
                            CreditCardView()
                                .rotationEffect(
                                    .degrees(cardRotation)
                                )
                                .offset(
                                    y: isFormSubmitting ? geometry.size.height / 2 - 80 : 0
                                )
                                .transition(.scale)
                                .zIndex(3)
                        }
                        .animation(.spring, value: isFormSubmitting)
                    }
                    .blur(radius: isFormComplete ? 32 : 0)
                    .animation(.spring, value: isFormComplete)
                    .zIndex(2)
                    
                    VStack {
                        VStack {
                            Button(action: {
                                generateRandomCreditCard()
                            }) {
                                Text("Generate Credit Card")
                                    .font(.callout)
                                    .frame(maxWidth: .infinity)
                                    .foregroundStyle(Color.blue)
                                    .padding(scaledPadding)
                                    .minimumScaleFactor(0.85)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                            }
                            .buttonStyle(.plain)
                            
                            Group {
                                CustomField(
                                    fieldType: .nameOnCard,
                                    text: $bindState.nameOnCard,
                                    placeholder: "Name on Card",
                                    onEditingChanged: { isEditing in
                                        if isEditing {
                                            focus = .nameOnCard
                                        }
                                    }
                                )
                                .focused($focus, equals: .nameOnCard)
                                .fieldBorder(focused: focus == .nameOnCard)
                                
                                CustomField(
                                    fieldType: .cardNumber,
                                    text: $bindState.cardNumber,
                                    placeholder: "Card Number",
                                    onEditingChanged: { isEditing in
                                        if isEditing {
                                            focus = .cardNumber
                                        }
                                    }
                                )
                                .focused($focus, equals: .cardNumber)
                                .fieldBorder(focused: focus == .cardNumber)
                                
                                HStack {
                                    CustomField(
                                        fieldType: .cvv,
                                        text: $bindState.cvv,
                                        placeholder: "CVV",
                                        onEditingChanged: { isEditing in
                                            creditCardState.flipCard()
                                            if isEditing {
                                                focus = .cvv
                                            }
                                        }
                                    )
                                    .focused($focus, equals: .cvv)
                                    .fieldBorder(focused: focus == .cvv)
                                    .padding(.trailing, 8)
                                    Spacer()
                                    
                                    CustomField(
                                        fieldType: .expirationDate,
                                        text: $bindState.expirationDate,
                                        placeholder: "Expiration",
                                        onEditingChanged: { isEditing in
                                            if isEditing {
                                                focus = .expirationDate
                                            }
                                        }
                                    )
                                    .focused($focus, equals: .expirationDate)
                                    .fieldBorder(focused: focus == .expirationDate)
                                }
                            }
                            .padding(.vertical, scaledPadding)
                            
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
                                .disabled(isFormSubmitting)
                            }
                            .padding(.vertical)
                        }
                        .blur(radius: isFormSubmitting ? 8 : 0)
                        .animation(.easeInOut, value: isFormSubmitting)
                        .accessibilityHidden(isFormSubmitting)
                    }
                    .padding()
                    .zIndex(1)
                }
                .scrollDisabled(isFormSubmitting)
            }
            
            CompletionModalView()
        }
        .onAppear {
            focus = .nameOnCard
        }
        .onChange(of: isFormComplete) { _, isComplete in
            if !isComplete {
                cardRotation = 0
            }
        }
    }
}

// MARK: Variables
extension FormView {
    var isFormSubmitting: Bool {
        creditCardState.isSubmitting
    }
    
    var isFormComplete: Bool {
        creditCardState.isComplete
    }
}

// MARK: Functions
extension FormView {
    func generateRandomCreditCard() {
        creditCardState.generateRandomCreditCard()
        
        focus = .expirationDate
    }
    
    func randomRotation() {
        cardRotation = Double(Int.random(in: -9...9))
    }
}

struct ConditionalPositionModifier: ViewModifier {
    let shouldApply: Bool
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        if shouldApply {
            content.position(x: x, y: y)
        } else {
            content
        }
    }
}

enum CreditCardType {
    case visa
    case mastercard
    case americanExpress
    case dinersClub
    case discover
    case unknown
}

#Preview {
    FormView()
        .environment(MockData.emptyCreditCardState())
}
