import SwiftUI

struct EasyFlowFlow: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Text("Easy Flow")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Theme.textDark)
        }
    }
}


struct SwitchMyVibeFlow: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Text("Switch My Vibe")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Theme.textDark)
        }
    }
}

struct BloomWithEnergyFlow: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            Text("Bloom with Energy")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Theme.textDark)
        }
    }
}
