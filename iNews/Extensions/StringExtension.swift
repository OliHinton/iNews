//
//  StringExtension.swift
//  iNews
//
//  Created by Oli Hinton on 12/08/2026.
//

import Foundation

// if the string is empty return nil else return the string itself
extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}
