//
//  BloomoveColors.swift
//  PresentMeTeam8
//
//  Created by Tarfah Alsaleh on 11/05/1448 AH.
//

import Foundation

import SwiftUI

enum BloomoveColors {
    static let background = Color(hex: 0xFFF9F3)
    static let primaryPink = Color(hex: 0xB84C70)
    static let darkGreen = Color(hex: 0x203D2E)
    static let secondaryText = Color(hex: 0x59665E)
    static let softGreen = Color(hex: 0xE7EEDF)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
