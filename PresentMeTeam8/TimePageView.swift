
import SwiftUI

// MARK: - Time Selection Screen
// Allows users to choose a workout duration before starting.

struct TimePageView: View {

    // The workout category selected on MoodPage.
    let selectedMood: String

    // MARK: - Navigation

    // Use the native Apple navigation back button.
    // Do not hide the navigation bar on this screen.

    @Environment(\.dismiss) private var dismiss

    // No duration is selected when the screen first opens.
    @State private var selectedMinutes: Int? = nil

    // Controls navigation to the selected workout.
    @State private var showWorkout = false

    // MARK: - Available Durations

    // Bloom with Energy offers longer workouts.
    // Other categories offer 2, 5, and 10 minutes.
    private var options: [Int] {
        selectedMood == "Bloom with Energy"
            ? [10, 15, 30]
            : [2, 5, 10]
    }

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

    // MARK: - Main Layout

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                // Fill the screen with Bloomove's background.
                background
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: - Page Question

                    // Add extra top spacing so the question
                    // sits comfortably below Apple's back button.
                    Text("How many minutes would you like to workout?")
                        .font(.system(size: 27, weight: .bold))
                        .foregroundColor(titleColor)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 38)

                    // Flexible spacing before the options.
                    Spacer(minLength: 35)

                    // MARK: - Time Options

                    VStack(spacing: 20) {

                        ForEach(options, id: \.self) { minutes in
                            optionRow(minutes)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Flexible spacing after the options.
                    Spacer(minLength: 35)

                    // MARK: - Continue Button

                    Button {

                        // Continue only when a duration is selected.
                        guard selectedMinutes != nil else {
                            return
                        }

                        showWorkout = true

                    } label: {

                        Text("Continue")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                selectedMinutes == nil
                                    ? accent.opacity(0.45)
                                    : accent,
                                in: RoundedRectangle(cornerRadius: 18)
                            )
                    }
                    .disabled(selectedMinutes == nil)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
            }
        }

        // MARK: - Native Apple Navigation

        // Make the native navigation bar visible.
        .toolbar(.visible, for: .navigationBar)

        // Hide any large navigation title.
        .navigationBarTitleDisplayMode(.inline)

        // Use Apple's native back button.
        .navigationBarBackButtonHidden(false)

        // Keep the navigation bar background consistent.
        .toolbarBackground(background, for: .navigationBar)

        // MARK: - Workout Navigation

        .navigationDestination(isPresented: $showWorkout) {

            if let minutes = selectedMinutes {

                if selectedMood == "Bloom with Energy" {

                    WorkoutStartPage(minutes: minutes)

                } else if selectedMood == "Find My Calm" {

                    FindMyCalmReady(minutes: minutes)

                } else if selectedMood == "Easy Flow" {

                    EasyFlowReady(minutes: minutes)

                } else if selectedMood == "Switch My Vibe" {

                    // Show the preparation screen before the workout begins.
                    SwitchMyVibeReadyView(minutes: minutes)
                }
            }
        }

        // MARK: - Reset Selection

        // Reset the selected duration if the mood changes.
        .onChange(of: selectedMood) { _, _ in
            selectedMinutes = nil
            showWorkout = false
        }
    }

    // MARK: - Reusable Duration Card

    // The pink highlight is shown only after selecting a duration.
    private func optionRow(_ minutes: Int) -> some View {

        let isSelected = selectedMinutes == minutes

        return Button {

            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMinutes = minutes
            }

        } label: {

            ZStack {

                // MARK: - Time Label

                Text("\(minutes) min")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundColor(titleColor)

                // MARK: - Selection Indicator

                HStack {

                    ZStack {

                        Circle()
                            .stroke(
                                isSelected ? accent : titleColor,
                                lineWidth: 2.5
                            )
                            .frame(width: 30, height: 30)

                        if isSelected {

                            Circle()
                                .fill(accent)
                                .frame(width: 30, height: 30)
                        }
                    }

                    Spacer()
                }
                .padding(.leading, 24)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)

            // MARK: - Card Background

            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        isSelected
                            ? accent.opacity(0.16)
                            : Color.white.opacity(0.65)
                    )
            )

            // MARK: - Card Border

            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        isSelected
                            ? accent
                            : subtitleColor.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(minutes) minutes")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview
// Use a NavigationStack to display Apple's native back button
// when this screen is pushed from another page.

#Preview {
    NavigationStack {
        NavigationLink("Choose Workout Time") {
            TimePageView(selectedMood: "Switch My Vibe")
        }
    }
}
