
import SwiftUI

// MARK: - Onboarding Page 1
// A full-screen onboarding layout that adapts to iPhone sizes.

struct OnboardingPage1: View {

    var onSkip: () -> Void = {}

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

                // Cover the entire screen, including safe areas.
                background
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: - Skip Button

                    HStack {

                        Spacer()

                        Button {
                            onSkip()
                        } label: {

                            Text("Skip")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(titleColor)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 16)

                    Spacer(minLength: 20)



                    

                    // MARK: - Main Illustration
                    // Use the same image dimensions on both onboarding pages.

                    Image(.shoes)
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

                    Text("Small Steps\nBig Changes!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(titleColor)
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)

                    // MARK: - Description

                    Text("A fun and flexible way to move\nat your own pace.")
                        .font(.system(size: 16))
                        .foregroundColor(subtitleColor)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 16)

                    Spacer(minLength: 20)

                    // MARK: - Page Indicators

                    // First dot is active on Onboarding Page 1.
                    HStack(spacing: 10) {

                        Circle()
                            .fill(accent)
                            .frame(width: 10, height: 10)

                        Circle()
                            .fill(accent.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                    .padding(.bottom, 48)
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
    OnboardingPage1()
}
