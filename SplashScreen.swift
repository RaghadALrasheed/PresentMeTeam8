import SwiftUI

struct SplashScreen: View {
    let accent = Color(red: 184/255, green: 76/255, blue: 112/255)      // #B84C70
    let background = Color(red: 254/255, green: 249/255, blue: 243/255) // #FEF9F3

    @State private var progress: CGFloat = 0
    @State private var isFinished = false

    var body: some View {
        if isFinished {
            OnboardingView()
        } else {
            ZStack {
                background.ignoresSafeArea()

                VStack {
                    Spacer()

                    Image(.logo) 
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)

                    Spacer()

                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 140, height: 5)

                        Capsule()
                            .fill(accent)
                            .frame(width: 140 * progress, height: 5)
                    }
                    .padding(.bottom, 200)
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 2.5)) {
                    progress = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                    isFinished = true
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
