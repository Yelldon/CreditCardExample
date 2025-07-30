//
//  CreditCardExample+View.swift
//  CreditCard
//
//  Created by Greg Patrick on 7/18/25.
//

import SwiftUI

extension View {
    func fieldBorder(borderColor: Color) -> some View {
        self
            .padding(8)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(borderColor, lineWidth: 2)
            )
    }
}
