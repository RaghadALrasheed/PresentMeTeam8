import SwiftUI

extension Color {
    init(hex: String) {
        let s = Scanner(string: hex)
        var v: UInt64 = 0
        s.scanHexInt64(&v)
        self.init(
            red:   Double((v >> 16) & 0xFF) / 255,
            green: Double((v >> 8)  & 0xFF) / 255,
            blue:  Double(v & 0xFF) / 255
        )
    }
}

enum Theme {
    static let background = Color(hex: "FEF9F3")
    static let pink = Color(hex: "B84C70")
    static let pinkLight = Color(hex: "E5BFCC")
    static let green = Color(hex: "59665E")
    static let greenLight = Color(hex: "EAEFE1")
    static let cardFill = Color(hex: "FFF9F3")
    static let cardBorder = Color(hex: "EAD3CA")
    static let textDark = Color(hex: "203D2E")
    static let textMuted = Color(hex: "59665E")
}
