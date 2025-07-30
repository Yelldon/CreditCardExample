//
//  FieldInfo.swift
//  CreditCardExample
//
//  Created by Greg Patrick on 7/30/25.
//

struct FieldInfo {
    var text: String = ""
    var error: FieldError?
    
    mutating func reset() {
        text = ""
        error = nil
    }
}
