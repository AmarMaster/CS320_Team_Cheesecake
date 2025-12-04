//
//  helperFunctions.swift
//  EventTracker
//

import Foundation
import SwiftUI

func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: 1.0
    )
}

func isValidPassword(_ password: String) -> Bool {
    return password.count >= 8 && password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*")) != nil
}
