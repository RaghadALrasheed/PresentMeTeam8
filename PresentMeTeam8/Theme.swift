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
    static let background  = Color(hex: "F6ECE6")
    static let pink        = Color(hex: "B84C70")
    static let pinkLight   = Color(hex: "E5BFCC")
    static let green       = Color(hex: "59665E")
    static let greenLight  = Color(hex: "DCE8D6")
    static let cardFill    = Color(hex: "FFF9F3")
    static let cardBorder  = Color(hex: "EAD3CA")
    static let textDark    = Color(hex: "283C2E")
    static let textMuted   = Color(hex: "7A6A66")
}
