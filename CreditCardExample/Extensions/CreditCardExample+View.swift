//
//  CreditCardExample+View.swift
//  CreditCard
//
//  Created by Greg Patrick on 7/18/25.
//

import SwiftUI

extension View {
    func fieldBorder(focused: Bool) -> some View {
        self
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(focused ? .blue : .secondary, lineWidth: 2)
            )
    }
}
