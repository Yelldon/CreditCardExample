//
//  CardReaderView.swift
//  CreditCard
//
//  Created by Greg Patrick on 7/19/25.
//

import SwiftUI

struct CardReaderView: View {
    @Environment(CreditCardState.self) var creditCardState
    
    @State var submitionIndex: Int = 0
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                Rectangle()
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .frame(width: 350, height: 300)
                    .shadow(radius: 8, x: 2, y: 12)
                    .onTapGesture {
                        creditCardState.resetFormSubmit()
                    }
                
                HStack {
                    Group {
                        Circle()
                            .foregroundStyle(submitionIndex > 0 ? .green : .gray)
                        Circle()
                            .foregroundStyle(submitionIndex > 1 ? .green : .gray)
                        Circle()
                            .foregroundStyle(submitionIndex > 2 ? .green : .gray)
                        Circle()
                            .foregroundStyle(submitionIndex > 3 ? .green : .gray)
                    }
                    .frame(width: 5, height: 5)
                    .padding()
                }
                .offset(y: 30)
            }
        }
        .onAppear {
            submitionIndex = 0
        }
        .onChange(of: creditCardState.isSubmitting) { oldValue, isSubmitting in
            if isSubmitting && submitionIndex == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    runSubmitLight(index: submitionIndex)
                }
            }
            
            if oldValue && !isSubmitting {
                submitionIndex = 0
            }
        }
    }
}

// MARK: Variables
extension CardReaderView {
    var isFormSubmitting: Bool {
        creditCardState.isSubmitting
    }
}

// MARK: Functions
extension CardReaderView {
    func runSubmitLight(index: Int) {
        if index < 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                submitionIndex += 1
                runSubmitLight(index: submitionIndex)
            }
        } else if index == 4 {
            creditCardState.isComplete.toggle()
        }
    }
}

#Preview {
    CardReaderView()
        .environment(MockData.baseCreditCardState)
}
