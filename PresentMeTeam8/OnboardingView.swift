import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showHome = false

    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingPage1(onSkip: {
                showHome = true
            })
            .tag(0)

            OnboardingPage2(onGetStarted: {
                showHome = true
            })
            .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showHome) {
            HomeView()
        }
    }
}

#Preview {
    OnboardingView()
}
