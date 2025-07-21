//
//  CreditCardExampleApp.swift
//  CreditCardExample
//
//  Created by Greg Patrick on 7/20/25.
//

import SwiftUI

@main
struct CreditCardExampleApp: App {
    @State var creditCardState = CreditCardState()
    
    var body: some Scene {
        WindowGroup {
            FormView()
                .environment(creditCardState)
        }
    }
}
