
import SwiftUI

// MARK: - Find My Calm Exercise Model
// Keep each exercise's original name, instructions,
// duration, and image asset.

struct FindMyCalmExercise: Identifiable {

    let id = UUID()

    let name: String
    let text: String
    let seconds: Int
    let image: String

    // Display the current exercise duration only.
    // Example: "30 SEC" or "2 Min".
    var label: String {
        seconds < 60
            ? "\(seconds) SEC"
            : "\(seconds / 60) Min"
    }
}

// MARK: - Find My Calm Workout Plans
// Preserve the original 2, 5, and 10-minute plans.

enum FindMyCalmPlan {

    static func exercises(for minutes: Int) -> [FindMyCalmExercise] {

        switch minutes {

        case 2:

            // 2 minutes: 30 + 30 + 60 seconds.
            return [

                FindMyCalmExercise(
                    name: "Shoulder Rolls",
                    text: "Stand tall, arms relaxed, slowly roll your shoulders up, back, and down, then reverse.",
                    seconds: 30,
                    image: "shoulderRolls"
                ),

                FindMyCalmExercise(
                    name: "Gentle Neck Tilts",
                    text: "Stand tall, shoulders relaxed, gently tilt your ear toward each shoulder without forcing.",
                    seconds: 30,
                    image: "neckTilts"
                ),

                FindMyCalmExercise(
                    name: "Walking",
                    text: "Walk with comfortable steps, looking ahead and swinging your arms naturally.",
                    seconds: 60,
                    image: "Walking"
                )
            ]

        case 5:

            // 5 minutes: 1 + 2 + 2 minutes.
            return [

                FindMyCalmExercise(
                    name: "Shoulder Rolls and Neck Tilts",
                    text: "Stand tall, slowly circle your shoulders, then gently tilt your head toward each shoulder.",
                    seconds: 60,
                    image: "shoulderNeck"
                ),

                FindMyCalmExercise(
                    name: "Walking",
                    text: "Walk with comfortable steps, looking ahead and swinging your arms naturally.",
                    seconds: 120,
                    image: "Walking"
                ),

                FindMyCalmExercise(
                    name: "Standing Calf Stretch",
                    text: "Face a wall, hands supported, step one foot back, heel down, knee straight, and bend your front knee slightly.",
                    seconds: 120,
                    image: "calfStretch"
                )
            ]

        default:

            // 10 minutes: 3 + 4 + 3 minutes.
            return [

                FindMyCalmExercise(
                    name: "Slow Walking",
                    text: "Stand tall, lift one knee forward to a comfortable height, then lower, and alternate.",
                    seconds: 180,
                    image: "slowWalking"
                ),

                FindMyCalmExercise(
                    name: "Standing Hip Circles",
                    text: "Stand with feet hip-width apart, hands on hips, slowly circle your hips in both directions.",
                    seconds: 240,
                    image: "hipCircles"
                ),

                FindMyCalmExercise(
                    name: "Standing Overhead Stretch",
                    text: "Stand tall, reach both arms overhead, and gently stretch upward without arching your back.",
                    seconds: 180,
                    image: "overheadStretch"
                )
            ]
        }
    }
}

// MARK: - Find My Calm Exercise Screen
// Match the layout used by the other Bloomove categories.

struct FindMyCalmExerciseView: View {

    let exercise: FindMyCalmExercise

    // Keep existing parameters for compatibility
    // with FindMyCalm's workout controller.
    var timeText: String? = nil

    var onPause: () -> Void = {}
    var onEnd: () -> Void = {}

    var isPaused: Bool = false
    var progress: Double = 1

    // MARK: - Timer Formatting

    private var clock: String {
        timeText ?? String(
            format: "%02d:%02d",
            exercise.seconds / 60,
            exercise.seconds % 60
        )
    }

    // MARK: - Main Exercise Screen

    var body: some View {

        ZStack {

            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 8) {

                // MARK: - Category Title

                Text("Find My Calm")
                    .font(.system(size: 30))
                    .foregroundStyle(Theme.textDark)
                    .padding(.top, 18)

                // MARK: - Exercise Name
                // Show only the exercise name.
                // Do not place the duration next to the name.

                Text(exercise.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Theme.textDark)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 8)

                // MARK: - Exercise Image
                // Preserve the original exercise illustrations.

                Image(exercise.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 280)
                    .id(exercise.id)

                // MARK: - Exercise Instructions

                Text(exercise.text)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                Spacer(minLength: 8)

                // MARK: - Current Exercise Duration
                // Show the duration below the instructions
                // and directly above the circular timer.

                Text(exercise.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textMuted)

                // MARK: - Circular Timer
                // Keep the time supplied by the session controller.

                ZStack {

                    Circle()
                        .fill(Theme.greenLight)

                    Circle()
                        .stroke(
                            Theme.green.opacity(0.25),
                            lineWidth: 4
                        )

                    Circle()
                        .trim(
                            from: 0,
                            to: min(max(progress, 0), 1)
                        )
                        .stroke(
                            Theme.green,
                            style: StrokeStyle(
                                lineWidth: 4,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))

                    Text(clock)
                        .font(
                            .system(
                                size: 32,
                                weight: .medium
                            )
                        )
                        .monospacedDigit()
                        .foregroundStyle(Theme.textDark)
                }
                .frame(width: 145, height: 145)
                .padding(.top, 10)

                // MARK: - Unified Workout Controls
                // Use the same control dimensions as
                // Switch My Vibe, Easy Flow, and Bloom with Energy.

                HStack {

                    controlButton(
                        icon: isPaused
                            ? "play.fill"
                            : "pause.fill",
                        label: isPaused
                            ? "Resume"
                            : "Pause",
                        action: onPause
                    )

                    Spacer()

                    controlButton(
                        icon: "stop.fill",
                        label: "End",
                        action: onEnd
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Unified Workout Control
    // Pause and End both use 72x72 circles.

    private func controlButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {

        VStack(spacing: 8) {

            Button(action: action) {

                Image(systemName: icon)
                    .font(
                        .system(
                            size: 25,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(Theme.textDark)
                    .frame(width: 72, height: 72)
                    .background(
                        Theme.greenLight,
                        in: Circle()
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)

            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textDark)
        }
        .frame(width: 100)
    }
}

// MARK: - Preview

#Preview {

    FindMyCalmExerciseView(
        exercise: FindMyCalmPlan.exercises(for: 2)[0]
    )
}
