
import SwiftUI

// MARK: - Splash Screen
// Show the Bloomove logo and loading animation on every app launch.

struct SplashScreen: View {

    // Notify ContentView when the splash animation finishes.
    var onFinished: () -> Void

    // MARK: - Colors

    private let accent = Color(
        red: 184/255,
        green: 76/255,
        blue: 112/255
    )

    private let background = Color(
        red: 254/255,
        green: 249/255,
        blue: 243/255
    )

    // Track loading progress from 0 to 1.
    @State private var progress: CGFloat = 0

    var body: some View {

        ZStack {

            background.ignoresSafeArea()

            VStack {

                Spacer()

                // Keep the team's original Bloomove logo.
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)

                Spacer()

                // MARK: - Loading Bar

                ZStack(alignment: .leading) {

                    Capsule()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 140, height: 5)

                    Capsule()
                        .fill(accent)
                        .frame(
                            width: 140 * progress,
                            height: 5
                        )
                }
                .padding(.bottom, 200)
            }
        }

        // MARK: - Splash Animation

        .task {

            // Animate the loading bar for 2.5 seconds.
            withAnimation(.linear(duration: 2.5)) {
                progress = 1
            }

            // Keep the Splash visible until loading finishes.
            do {
                try await Task.sleep(for: .seconds(2.7))
            } catch {
                // Do not navigate if this screen was cancelled.
                return
            }

            // Let ContentView decide the next screen.
            onFinished()
        }
    }
}


// MARK: - Preview

#Preview {
    SplashScreen(onFinished: {})
}
