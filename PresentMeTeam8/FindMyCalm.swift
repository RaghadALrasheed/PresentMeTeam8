
import SwiftUI

// MARK: - Find My Calm Preparation Screen
// Displays the selected workout duration before starting.
// Time selection is already handled by TimePageView.

struct FindMyCalmReady: View {

    let minutes: Int

    @Environment(\.dismiss) private var dismiss

    @State private var startWorkout = false

    // MARK: - Bloomove Colors

    private let background = Color(
        red: 254/255,
        green: 249/255,
        blue: 243/255
    )

    private let darkGreen = Color(
        red: 32/255,
        green: 61/255,
        blue: 46/255
    )

    private let mutedGreen = Color(
        red: 89/255,
        green: 102/255,
        blue: 94/255
    )

    private let lightGreen = Color(
        red: 234/255,
        green: 239/255,
        blue: 225/255
    )

    private let pink = Color(
        red: 184/255,
        green: 76/255,
        blue: 112/255
    )

    // MARK: - Main Screen

    var body: some View {

        ZStack {

            background
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Workout Title

                Text("Find My Calm")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(darkGreen)
                    .padding(.top, 55)

                Text("Focus on yourself")
                    .font(.system(size: 16))
                    .foregroundStyle(mutedGreen)
                    .padding(.top, 12)

                Spacer()

                // MARK: - Selected Workout Duration
                // This is a static duration preview.
                // The actual timer starts after Start Now.

                ZStack {

                    Circle()
                        .fill(lightGreen)

                    Circle()
                        .stroke(
                            mutedGreen,
                            lineWidth: 3
                        )

                    Text(
                        String(
                            format: "%02d:00",
                            minutes
                        )
                    )
                    .font(
                        .system(
                            size: 46,
                            weight: .medium
                        )
                    )
                    .monospacedDigit()
                    .foregroundStyle(darkGreen)
                }
                .frame(
                    width: 230,
                    height: 230
                )

                Spacer()

                // MARK: - Start Workout Button

                Button {

                    startWorkout = true

                } label: {

                    Text("Start Now")
                        .font(
                            .system(
                                size: 20,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 65)
                        .background(
                            pink,
                            in: RoundedRectangle(
                                cornerRadius: 18
                            )
                        )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }

        // MARK: - Native Apple Navigation

        .navigationBarBackButtonHidden(false)
        .toolbar(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Workout Navigation
        // Pass the selected duration to the existing
        // Find My Calm workout controller.

        .navigationDestination(
            isPresented: $startWorkout
        ) {

            FindMyCalmWorkout(
                minutes: minutes
            )
        }
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {

        FindMyCalmReady(
            minutes: 5
        )
        .environmentObject(
            GardenProgressManager()
        )
    }
}
