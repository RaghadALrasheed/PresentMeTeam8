
import SwiftUI

// MARK: - Bloomove Colors
// Use one consistent background throughout the onboarding flow.
private enum OnboardingColors {
    static let background = Color(
        red: 254/255,
        green: 249/255,
        blue: 243/255
    )
}

// MARK: - App Entry Flow
// Always show Splash and Onboarding on a fresh app launch.
struct ContentView: View {

    // Track when the splash animation finishes.
    @State private var splashFinished = false

    // Track when the user finishes onboarding.
    // Using State means onboarding will appear on a fresh app launch.
    @State private var onboardingFinished = false

    var body: some View {

        ZStack {

            // Keep the background consistent during screen transitions.
            OnboardingColors.background
                .ignoresSafeArea()

            Group {

                if !splashFinished {

                    // Show Splash when the app launches.
                    SplashScreen {
                        splashFinished = true
                    }

                } else if !onboardingFinished {

                    // Show the two original onboarding pages.
                    BloomoveOnboardingFlow {

                        // Skip or Get Started opens HomePage.
                        onboardingFinished = true
                    }

                } else {

                    // Keep the existing Home screen and garden progress.
                    HomePage()
                }
            }
        }
    }
}

// MARK: - Onboarding Navigation
// Connect both onboarding pages in one full-screen swipeable flow.
struct BloomoveOnboardingFlow: View {

    let onFinished: () -> Void

    // Track the current onboarding page.
    @State private var selectedPage = 0

    var body: some View {

        ZStack {

            // Extend Bloomove's cream background behind all safe areas.
            OnboardingColors.background
                .ignoresSafeArea()

            TabView(selection: $selectedPage) {

                // MARK: - Onboarding Page 1

                OnboardingPage1(
                    onSkip: {
                        onFinished()
                    }
                )
                .tag(0)

                // MARK: - Onboarding Page 2

                OnboardingPage2(
                    onGetStarted: {
                        onFinished()
                    }
                )
                .tag(1)
            }

            // Enable horizontal swiping between the two pages.
            .tabViewStyle(
                .page(indexDisplayMode: .never)
            )

            // Make onboarding content fill the screen.
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }

        // Hide navigation controls but keep the system status bar.
        .toolbar(.hidden, for: .navigationBar)

        // Apply the same cream background to the complete flow.
        .background {
            OnboardingColors.background
                .ignoresSafeArea()
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(GardenProgressManager())
}
