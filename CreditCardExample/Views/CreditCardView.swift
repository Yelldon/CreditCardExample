//
//  CreditCardView.swift
//  CreditCard
//
//  Created by Greg Patrick on 7/17/25.
//

import SwiftUI

struct CreditCardView: View {
    @Environment(CreditCardState.self) var creditCardState
    
    @State private var frontDegree = 0.0
    @State private var backDegree = 90.0
    
    private let durationAndDelay: CGFloat = 0.15
    
    var body: some View {
        VStack {
            ZStack {
                creditCardBaseView(isBack: false, degree: frontDegree, color: creditCardColor) {
                    VStack {
                        VStack(alignment: .trailing) {
                            Text(redactedCreditCardNumber)
                            Text("Valid Experation: \(visibleExperation)")
                                .font(.caption2)
                                .padding(.top, 1)
                        }
                        .padding(.top)
                        .offset(y: 20)
                        
                        
                        HStack(alignment: .center) {
                            Text(creditCardState.nameOnCard.text)
                                .lineLimit(1)
                                .bold()
                            
                            Spacer()
                            
                            UnevenRoundedRectangle(
                                cornerRadii: RectangleCornerRadii(
                                    topLeading: 8,
                                    bottomLeading: 0,
                                    bottomTrailing: 0,
                                    topTrailing: 0)
                            )
                            .foregroundStyle(Color.white)
                            .frame(width: 75, height: 55)
                            .padding(.trailing, 20)
                            .padding(.bottom, 6)
                            .overlay {
                                ZStack {
                                    cardTypeImage()
                                        .padding(.trailing)
                                        .offset(x: -2, y: -3)
                                        .padding(8)
                                }
                                .animation(.easeInOut.speed(1.5), value: checkCardType)
                            }
                        }
                        .offset(x: 20, y: 35)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .clipped()
                }
                
                creditCardBaseView(isBack: true, degree: backDegree, color: .white) {
                    VStack {
                        HStack(spacing: 0) {
                            Rectangle()
                                .foregroundStyle(Color.gray)
                            
                            Rectangle()
                                .foregroundStyle(Color.white)
                                
                                .overlay {
                                    Text(creditCardState.cvv.text)
                                        .bold()
                                }
                                .frame(width: 70)
                        }
                        .border(.black)
                        .frame(height: 35)
                        .padding()
                    }
                }
            }
            .dynamicTypeSize(.large)
            .padding(.vertical)
            .shadow(radius: 4, x: 0, y: 6)
            .transition(.opacity)
        }
        .onChange(of: isFlipped) { _, _ in
            flipCard()
        }
#if DEBUG
        // We really only want this to run for previews
        .onAppear {
            if isFlipped {
                flipCard()
            }
        }
#endif
    }
}

// MARK: Views
extension CreditCardView {
    func creditCardBaseView<Content: View>(
        isBack: Bool,
        degree: Double,
        color: Color,
        @ViewBuilder content: () -> Content) -> some View {
        Rectangle()
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray, lineWidth: 1)
            )
            .animation(.easeInOut.speed(1.5), value: checkCardType)
            .overlay(alignment: .topLeading) {
                if !isBack {
                    chipView
                }
            }
            .overlay(alignment: .topLeading) {
                if isBack {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color.black)
                            .frame(height: 30)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 24)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if !isBack {
                    ZStack {
                        content()
                    }
                }
            }
            .overlay {
                if isBack {
                    content()
                        .scaleEffect(x: -1, y: 1)
                        .padding(.top, 36)
                }
            }
            .rotation3DEffect(
                .degrees(degree), axis: (x: 0, y: 60, z: 0)
            )
            .frame(width: 300, height: 185)
    }
    
    @ViewBuilder var chipView: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.gold)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.gray, lineWidth: 1)
                )
                .overlay(
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            chipSectionView
                            
                            chipSectionView
                        }
                        HStack(spacing: 4) {
                            chipSectionView
                            
                            chipSectionView
                        }
                        HStack(spacing: 4) {
                            chipSectionView
                            
                            chipSectionView
                        }
                    }
                    .padding(8)
                )
                .frame(width: 35, height: 25)
        }
        .padding()
    }
    
    var chipSectionView: some View {
        Capsule()
            .stroke(.black.opacity(0.3), style: StrokeStyle(lineWidth: 1, lineCap: .round))
            .frame(width: 12, height: 4)
    }
}

// MARK: Variables
extension CreditCardView {
    var checkCardType: CreditCardType {
        creditCardState.checkCreditCardType
    }
    
    var isFlipped: Bool {
        creditCardState.isFlipped
    }
    
    var creditCardColor: Color {
        switch checkCardType {
            case .visa: return .blue
            case .mastercard: return .orange
            case .americanExpress: return .cyan
            case .dinersClub: return .brown
            case .discover: return .purple
            case .unknown: return .lightestGray
        }
    }
    
    var redactedCreditCardNumber: String {
        let digits = Array(creditCardState.cardNumber.text.filter { $0.isNumber })
        
        // Always show 16 positions
        var result = Array(repeating: Character("#"), count: 16)
        
        // Show digits in their actual positions as typed
        for i in 0..<min(digits.count, 16) {
            // Show first 4 digits (positions 0-3)
            if i < 4 {
                result[i] = digits[i]
            }
            // Show last 4 digits (positions 12-15) only
            else if i >= 12 {
                result[i] = digits[i]
            }
            // Hide middle 8 digits (positions 4-11)
            // These stay as "#"
        }
        
        // Convert to string and add spaces every 4 characters
        let redacted = String(result)
        return redacted.enumerated().map { index, char in
            index > 0 && index % 4 == 0 ? " \(char)" : "\(char)"
        }.joined()
    }
    
    var visibleExperation: String {
        let digits = Array(creditCardState.expirationDate.text.filter { $0.isNumber })
        
        // Always show MM/YY format with dashes as placeholders
        var result = Array(repeating: Character("-"), count: 4)
        
        // Show digits in their actual positions as typed
        for i in 0..<min(digits.count, 4) {
            result[i] = digits[i]
        }
        
        // Convert to string and add slash after position 2
        let formatted = String(result)
        return "\(formatted.prefix(2))/\(formatted.suffix(2))"
    }
}

// MARK: Views
extension CreditCardView {
    @ViewBuilder func cardTypeImage() -> some View {
        switch checkCardType {
        case .visa:
            cardTypeBaseImage("VisaImage")
        case .mastercard:
            cardTypeBaseImage("MasterCardImage")
        case .americanExpress:
            cardTypeBaseImage("AmericanExpressImage")
        case .dinersClub:
            cardTypeBaseImage("DinersClubImage")
        case .discover:
            cardTypeBaseImage("DiscoverImage")
        default:
            EmptyView()
        }
    }
}

// MARK: Functions
extension CreditCardView {
    func cardTypeBaseImage(_ image: String) -> some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .frame(width: 55)
    }
    
    func flipCard() {
        if isFlipped {
            withAnimation(.easeInOut(duration: durationAndDelay)) {
                frontDegree = 90.0
            }
            withAnimation(.bouncy(duration: durationAndDelay, extraBounce: 0.2).delay(durationAndDelay)) {
                backDegree = 180.0
            }
        } else {
            withAnimation(.easeInOut(duration: durationAndDelay)) {
                backDegree = 90.0
            }
            withAnimation(.bouncy(duration: durationAndDelay, extraBounce: 0.2).delay(durationAndDelay)) {
                frontDegree = 0.0
            }
        }
    }
}

#Preview("Initial View") {
    CreditCardView()
        .environment(MockData.emptyCreditCardState)
    
    CreditCardView()
        .environment(MockData.flippedCreditCardState)
}

#Preview("Set View") {
    CreditCardView()
        .environment(MockData.baseCreditCardState)
}
