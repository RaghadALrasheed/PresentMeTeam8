
import SwiftUI

// MARK: - Bloomove Colors

private enum OnboardingColors {
    static let background = Color(
        red: 254/255,
        green: 249/255,
        blue: 243/255
    )
}

// MARK: - App Entry Flow

struct ContentView: View {

    // Show Splash on every fresh app launch.
    @State private var splashFinished = false

    // Show Onboarding on every fresh app launch.
    @State private var onboardingFinished = false

    var body: some View {

        ZStack {

            OnboardingColors.background
                .ignoresSafeArea()

            if !splashFinished {

                // Step 1: Splash screen.
                SplashScreen {
                    splashFinished = true
                }

            } else if !onboardingFinished {

                // Step 2: Two onboarding pages.
                BloomoveOnboardingFlow {
                    onboardingFinished = true
                }

            } else {

                // Step 3: Home screen.
                HomePage()
            }
        }
    }
}

// MARK: - Onboarding Navigation

struct BloomoveOnboardingFlow: View {

    let onFinished: () -> Void

    @State private var selectedPage = 0

    var body: some View {

        ZStack {

            OnboardingColors.background
                .ignoresSafeArea()

            TabView(selection: $selectedPage) {

                OnboardingPage1(
                    onSkip: onFinished
                )
                .tag(0)

                OnboardingPage2(
                    onGetStarted: onFinished
                )
                .tag(1)
            }
            .tabViewStyle(
                .page(indexDisplayMode: .never)
            )
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(GardenProgressManager())
}
