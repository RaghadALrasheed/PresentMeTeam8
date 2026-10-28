
import SwiftUI

// MARK: - App Entry Flow
// Controls the Splash, Onboarding, and Home screens.

struct ContentView: View {

    // Remember whether the user has completed onboarding.
    // This value stays saved after closing the app.
    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    // Track whether the splash animation has finished.
    @State private var splashFinished = false

    var body: some View {

        Group {

            if !splashFinished {

                // Always show the Splash screen when launching.
                SplashScreen {
                    splashFinished = true
                }

            } else if !hasCompletedOnboarding {

                // Show onboarding only for first-time users.
                BloomoveOnboardingFlow {

                    // Save onboarding completion permanently.
                    hasCompletedOnboarding = true
                }

            } else {

                // Open the real Home screen.
                // The existing garden manager remains shared.
                HomePage()
            }
        }
    }
}


// MARK: - Onboarding Navigation
// Connect the two original onboarding pages.
// Keep their existing designs, images, and colors.

struct BloomoveOnboardingFlow: View {

    let onFinished: () -> Void

    // Track the currently displayed onboarding page.
    @State private var selectedPage = 0

    var body: some View {

        TabView(selection: $selectedPage) {

            // MARK: - First Onboarding Page

            OnboardingPage1(

                // Skip onboarding and go directly Home.
                onSkip: {
                    onFinished()
                }
            )
            .tag(0)

            // MARK: - Second Onboarding Page

            OnboardingPage2(

                // Complete onboarding and open Home.
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

        // Hide default navigation controls.
        .toolbar(.hidden, for: .navigationBar)
    }
}


// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(GardenProgressManager())
}
