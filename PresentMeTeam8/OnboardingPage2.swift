
import SwiftUI

// MARK: - Onboarding Page 2
// Full-screen responsive layout matching Onboarding Page 1.

struct OnboardingPage2: View {

    // Open the Home screen when Get Started is tapped.
    var onGetStarted: () -> Void = {}

    // MARK: - Bloomove Colors

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

    private let titleColor = Color(
        red: 32/255,
        green: 61/255,
        blue: 46/255
    )

    private let subtitleColor = Color(
        red: 89/255,
        green: 102/255,
        blue: 94/255
    )

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                // Fill the entire screen, including safe areas.
                background
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: - Top Spacing
                    // Match the top spacing of Onboarding Page 1.
                    Color.clear
                        .frame(height: 38)

                    Spacer(minLength: 8)

                    // MARK: - Main Illustration
                    // Match the exact image dimensions of Onboarding Page 1.

                    Image(.flower)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: min(geometry.size.width - 48, 350),
                            height: geometry.size.height * 0.43
                        )
                        .clipped()
                        .clipShape(
                            RoundedRectangle(cornerRadius: 24)
                        )

                    // MARK: - Main Title

                    Text("Your movement grows your garden!")
                        .font(.system(size: 27, weight: .bold))
                        .foregroundColor(titleColor)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    // MARK: - Description
                    // Keep the team's original onboarding copy.

                    Text("Each run gives you something\nworth returning to.")
                        .font(.system(size: 16))
                        .foregroundColor(subtitleColor)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 14)

                    Spacer(minLength: 16)

                    // MARK: - Page Indicators
                    // The second dot is active on Onboarding Page 2.

                    HStack(spacing: 10) {

                        Circle()
                            .fill(accent.opacity(0.3))
                            .frame(width: 10, height: 10)

                        Circle()
                            .fill(accent)
                            .frame(width: 10, height: 10)
                    }
                    .padding(.bottom, 24)

                    // MARK: - Get Started Button
                    // Complete onboarding and open HomePage.

                    Button {
                        onGetStarted()
                    } label: {

                        Text("Get Started")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                accent,
                                in: RoundedRectangle(cornerRadius: 20)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingPage2()
}
