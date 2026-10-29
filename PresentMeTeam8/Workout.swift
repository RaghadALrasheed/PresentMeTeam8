import Foundation

import SwiftUI
import Combine
import AudioToolbox

// MARK: - Switch My Vibe Exercise Model
// Each exercise has its own duration, image, and instructions.
private struct SwitchVibeExercise {

    let name: String
    let imageName: String
    let description: String
    let seconds: Int

    var durationLabel: String {
        let minutes = seconds / 60
        return "\(minutes) min \(name)"
    }
}

// MARK: - Switch My Vibe Workout Plans
// Preserve the original exercises for 2, 5, and 10 minutes.
private enum SwitchVibePlan {

    static func exercises(for minutes: Int) -> [SwitchVibeExercise] {

        switch minutes {

        case 2:
            // Original 2-minute plan: 1 + 1 minutes.
            return [
                SwitchVibeExercise(
                    name: "Marching",
                    imageName: "Marching Exercise",
                    description: "Stand tall and march in place, lifting your knees alternately while swinging your arms naturally.",
                    seconds: 60
                ),

                SwitchVibeExercise(
                    name: "Side Movement",
                    imageName: "side Movement",
                    description: "Stand tall, take a step to one side, bring your feet together, then repeat in the opposite direction.",
                    seconds: 60
                )
            ]

        case 10:
            // Original 10-minute plan: 2 + 6 + 2 minutes.
            return [
                SwitchVibeExercise(
                    name: "Warm-up",
                    imageName: "warm-up",
                    description: "Move gently to warm up your body. Relax your shoulders and prepare for movement.",
                    seconds: 120
                ),

                SwitchVibeExercise(
                    name: "Alternating Arm and Leg Swings",
                    imageName: "arm and leg swings Exercise",
                    description: "Stand tall, swing one arm forward with the opposite leg, then switch sides while maintaining your balance.",
                    seconds: 360
                ),

                SwitchVibeExercise(
                    name: "Cool-down",
                    imageName: "cool-down Exercise",
                    description: "Slow down your movements and gently stretch while breathing comfortably.",
                    seconds: 120
                )
            ]

        default:
            // Original 5-minute plan: 1 + 2 + 1 + 1 minutes.
            return [
                SwitchVibeExercise(
                    name: "Marching",
                    imageName: "Marching Exercise",
                    description: "Stand tall and march in place, lifting your knees alternately to a comfortable height while swinging your arms naturally.",
                    seconds: 60
                ),

                SwitchVibeExercise(
                    name: "Standing Hamstring Curls",
                    imageName: "standing Hamstring Curls",
                    description: "Stand tall, bend one knee to bring your heel toward your buttocks, then lower and alternate legs.",
                    seconds: 120
                ),

                SwitchVibeExercise(
                    name: "Knee Lifts",
                    imageName: "knee lifts",
                    description: "Stand tall, lift one knee forward to a comfortable height, then lower it slowly and alternate legs.",
                    seconds: 60
                ),

                SwitchVibeExercise(
                    name: "Cool-down",
                    imageName: "cool-down Exercise",
                    description: "Slow your pace, breathe deeply, and gently stretch your arms and legs.",
                    seconds: 60
                )
            ]
        }
    }
}

// MARK: - Switch My Vibe Workout Screen
// One reusable screen supports all three session durations.
struct workoutView: View {

    // MARK: - Shared Garden Progress

    @EnvironmentObject var gardenManager: GardenProgressManager

    // Keep the existing initializer used by TimePageView.
    let selectedMood: String
    let durationMinutes: Int

    // Use the original exercise plan for the selected duration.
    private let exercises: [SwitchVibeExercise]

    // Store ACTIVE workout time only.
    // Break seconds are never subtracted from this value.
    @State private var secondsRemaining: Int

    // MARK: - Pause State

    @State private var isPaused = false

    // MARK: - Exercise Break State

    // Give users 20 seconds before the next exercise.
    private let breakDuration = 20

    @State private var isOnBreak = false
    @State private var breakSecondsRemaining = 0

    // MARK: - End Confirmation State

    // Show Bloomove's existing custom confirmation page.
    @State private var showEndConfirmation = false

    // Remember the pause state before opening confirmation.
    @State private var wasPausedBeforeConfirmation = false

    // Wait for the confirmation page to close before navigating.
    @State private var finishEarlyAfterDismiss = false
    @State private var resumeAfterDismiss = false

    // MARK: - Completion State

    @State private var showCompletion = false
    @State private var showEarlyCompletion = false
    @State private var showGarden = false

    @State private var earnedMinutes = 0

    // Prevent the same workout from being rewarded twice.
    @State private var workoutSessionID = UUID().uuidString

    // Publish one timer event per second.
    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Initialization

    init(
        selectedMood: String = "Switch My Vibe",
        durationMinutes: Int = 5
    ) {

        self.selectedMood = selectedMood
        self.durationMinutes = durationMinutes

        let plan = SwitchVibePlan.exercises(for: durationMinutes)
        self.exercises = plan

        let totalSeconds = plan.reduce(0) {
            $0 + $1.seconds
        }

        _secondsRemaining = State(initialValue: totalSeconds)
    }

    // MARK: - Time Calculations

    // Calculate the total ACTIVE exercise duration.
    private var totalSeconds: Int {
        exercises.reduce(0) {
            $0 + $1.seconds
        }
    }

    // Count completed active exercise seconds.
    private var elapsedSeconds: Int {
        totalSeconds - secondsRemaining
    }

    // Find the current exercise using cumulative exercise durations.
    // During a break, this automatically selects the NEXT exercise.
    private var currentExerciseIndex: Int {

        guard !exercises.isEmpty else {
            return 0
        }

        var accumulatedSeconds = 0

        for (index, exercise) in exercises.enumerated() {

            accumulatedSeconds += exercise.seconds

            if elapsedSeconds < accumulatedSeconds {
                return index
            }
        }

        return exercises.count - 1
    }

    private var currentExercise: SwitchVibeExercise {
        exercises[currentExerciseIndex]
    }

    // Calculate the overall workout progress.
    private var progress: Double {

        guard totalSeconds > 0 else {
            return 0
        }

        return Double(elapsedSeconds) / Double(totalSeconds)
    }

    private var workoutTimeText: String {
        formatTime(secondsRemaining)
    }

    private var breakTimeText: String {
        formatTime(breakSecondsRemaining)
    }

    private var hasEnded: Bool {
        showCompletion || showEarlyCompletion
    }

    // Convert seconds to MM:SS.
    private func formatTime(_ seconds: Int) -> String {
        String(
            format: "%02d:%02d",
            seconds / 60,
            seconds % 60
        )
    }

    // MARK: - Main Screen

    var body: some View {

        ZStack {

            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 8) {

                // MARK: Workout Title

                Text(selectedMood)
                    .font(.system(size: 30))
                    .foregroundStyle(Theme.textDark)
                    .padding(.top, 18)

                if isOnBreak {

                    // Show the next exercise before it starts.
                    Text("Up Next")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(
                            Color(
                                red: 184/255,
                                green: 76/255,
                                blue: 112/255
                            )
                        )

                    Text(currentExercise.durationLabel)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Theme.textDark)
                        .multilineTextAlignment(.center)

                    Text("Get ready for your next move!")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textMuted)

                } else {

                    // Show the name and duration of the active exercise.
                    Text(currentExercise.durationLabel)
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.textDark)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 8)

                // MARK: Exercise Image

                // The image automatically changes at each exercise boundary.
                Image(currentExercise.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: isOnBreak ? 230 : 280)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    .id(currentExerciseIndex)

                // MARK: Exercise Instructions

                Text(currentExercise.description)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                Spacer(minLength: 8)

                if isOnBreak {

                    Text("Starting in")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.textDark)

                } else {

                    Text("\(durationMinutes) Min Workout")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textMuted)
                }

                // MARK: - Circular Timer

                // Show the break countdown or the active workout countdown.
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
                            to: isOnBreak
                                ? Double(
                                    breakDuration - breakSecondsRemaining
                                  ) / Double(breakDuration)
                                : progress
                        )
                        .stroke(
                            Theme.green,
                            style: StrokeStyle(
                                lineWidth: 4,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))

                    Text(
                        isOnBreak
                            ? breakTimeText
                            : workoutTimeText
                    )
                    .font(.system(size: 32, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(Theme.textDark)
                }
                .frame(width: 145, height: 145)
                .padding(.top, 10)

                // MARK: - Workout Controls

                // Allow Pause/Resume and End during exercises and breaks.
                HStack {

                    controlButton(
                        icon: isPaused ? "play.fill" : "pause.fill",
                        label: isPaused ? "Resume" : "Pause"
                    ) {
                        isPaused.toggle()
                    }

                    Spacer()

                    controlButton(
                        icon: "stop.fill",
                        label: "End"
                    ) {
                        openEndConfirmation()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
        }

        .navigationBarBackButtonHidden(true)

        // MARK: - Timer Updates

        .onReceive(timer) { _ in
            tick()
        }

        // Keep the phone screen awake during the workout.
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }

        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }

        // MARK: - Custom End Confirmation

        // Show the original "You're Doing Great!" page.
        .fullScreenCover(
            isPresented: $showEndConfirmation,
            onDismiss: {

                // Open the result only after the confirmation closes.
                if finishEarlyAfterDismiss {

                    finishEarlyAfterDismiss = false
                    finishEarly()

                } else if resumeAfterDismiss {

                    // Return to the same exercise and remaining time.
                    resumeAfterDismiss = false
                    isPaused = wasPausedBeforeConfirmation
                }
            }
        ) {

            EndWorkoutConfirmationView(
                totalMinutes: durationMinutes,
                completedMinutes: elapsedSeconds / 60,

                // Continue from the exact moment the user stopped.
                onKeepExercising: {
                    resumeAfterDismiss = true
                    showEndConfirmation = false
                },

                // Confirm ending the session early.
                onEndWorkout: {
                    finishEarlyAfterDismiss = true
                    showEndConfirmation = false
                }
            )
            .interactiveDismissDisabled(true)
        }

        // MARK: - Full Workout Completion

        // Open the existing Bloomove completion screen.
        .navigationDestination(isPresented: $showCompletion) {

            CompletionView(
                gardenManager: gardenManager,
                workoutSessionID: workoutSessionID,
                completedMinutes: earnedMinutes,
                flowerProgressMinutes: gardenManager.currentFlowerProgress,

                onViewGarden: {
                    showGarden = true
                },

                onBackHome: {
                    returnHome()
                }
            )
            .navigationBarBackButtonHidden(true)
        }

        // MARK: - Early Workout Completion

        // Open the original "You Did Your Best!" screen.
        .navigationDestination(isPresented: $showEarlyCompletion) {

            EarlyCompletionView(
                gardenManager: gardenManager,
                workoutSessionID: workoutSessionID,
                completedMinutes: earnedMinutes,
                flowerProgressMinutes: gardenManager.currentFlowerProgress,

                onViewGarden: {
                    showGarden = true
                },

                onBackHome: {
                    returnHome()
                }
            )
            .navigationBarBackButtonHidden(true)
        }

        // MARK: - Interactive Garden

        // Use the same saved garden progress as HomePage.
        .sheet(isPresented: $showGarden) {

            NavigationStack {
                TarfahGardenView(gardenManager: gardenManager)
            }
        }
    }

    // MARK: - End Confirmation Logic

    private func openEndConfirmation() {

        // Remember whether the user had already paused.
        wasPausedBeforeConfirmation = isPaused

        // Freeze all countdowns before opening the confirmation.
        isPaused = true

        showEndConfirmation = true
    }

    // MARK: - Timer Logic

    private func tick() {

        // Never count while paused, confirming, or showing results.
        guard !isPaused,
              !showEndConfirmation,
              !hasEnded else {
            return
        }

        // MARK: Break Countdown

        if isOnBreak {

            if breakSecondsRemaining > 1 {

                breakSecondsRemaining -= 1

            } else {

                // Start the next exercise automatically.
                breakSecondsRemaining = 0
                isOnBreak = false
            }

            // Breaks do not count toward activity minutes.
            return
        }

        // MARK: Active Exercise Countdown

        guard secondsRemaining > 0 else {
            return
        }

        secondsRemaining -= 1

        // Show the completion page after the final exercise.
        if secondsRemaining == 0 {
            finishWorkout()
            return
        }

        // Start a break after each exercise except the last.
        if isExerciseBoundary {
            startExerciseBreak()
        }
    }

    // MARK: - Exercise Boundary Detection

    // Use the original duration of every exercise.
    // Exclude the last exercise to avoid an unnecessary final break.
    private var isExerciseBoundary: Bool {

        var accumulatedSeconds = 0

        for exercise in exercises.dropLast() {

            accumulatedSeconds += exercise.seconds

            if elapsedSeconds == accumulatedSeconds {
                return true
            }
        }

        return false
    }

    // MARK: - Start Exercise Break

    private func startExerciseBreak() {

        isOnBreak = true
        breakSecondsRemaining = breakDuration

        // Play the same sound used in the other Bloomove categories.
        AudioServicesPlaySystemSound(1005)
    }

    // MARK: - Normal Completion

    private func finishWorkout() {

        earnedMinutes = totalSeconds / 60

        // Record activity minutes and update garden progress.
        gardenManager.recordWorkout(
            id: workoutSessionID,
            completedMinutes: earnedMinutes
        )

        showCompletion = true
    }

    // MARK: - Early Completion

    private func finishEarly() {

        // Save completed full minutes only.
        // The 20-second breaks never increase earned minutes.
        earnedMinutes = elapsedSeconds / 60

        if earnedMinutes > 0 {

            gardenManager.recordWorkout(
                id: workoutSessionID,
                completedMinutes: earnedMinutes
            )
        }

        showEarlyCompletion = true
    }

    // MARK: - Return Home

    // HomePage listens for this notification.
    // It closes the entire workout navigation flow.
    private func returnHome() {

        NotificationCenter.default.post(
            name: Notification.Name("BloomoveReturnHome"),
            object: nil
        )
    }

    // MARK: - Reusable Workout Control

    // Use the original green circular Pause and End buttons.
    private func controlButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {

        VStack(spacing: 8) {

            Button(action: action) {

                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(Theme.textDark)
                    .frame(width: 68, height: 68)
                    .background(Theme.greenLight)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Theme.textDark)
        }
    }
}

// MARK: - Switch My Vibe Preparation Screen
// Shows the selected workout duration before starting.
// The countdown begins only after the user taps Start Now.

struct SwitchMyVibeReadyView: View {

    let minutes: Int

    @Environment(\.dismiss) private var dismiss

    // Controls navigation to the active workout.
    @State private var showWorkout = false

    // MARK: - Bloomove Colors

    private let background = Color(
        red: 254/255,
        green: 249/255,
        blue: 243/255
    )

    private let accent = Color(
        red: 184/255,
        green: 76/255,
        blue: 112/255
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

    private let ringFill = Color(
        red: 234/255,
        green: 239/255,
        blue: 225/255
    )

    var body: some View {

        ZStack {

            background
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Workout Title

                Text("Switch My Vibe")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(titleColor)
                    .padding(.top, 55)

                Text("Focus on yourself")
                    .font(.system(size: 16))
                    .foregroundColor(subtitleColor)
                    .padding(.top, 12)

                Spacer()

                // MARK: - Selected Duration

                // This is a static preview of the selected time.
                // The workout timer starts on the next screen.

                ZStack {

                    Circle()
                        .fill(ringFill)

                    Circle()
                        .stroke(
                            subtitleColor,
                            lineWidth: 3
                        )

                    Text(
                        String(
                            format: "%02d:00",
                            minutes
                        )
                    )
                    .font(.system(size: 46, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(titleColor)
                }
                .frame(width: 230, height: 230)

                Spacer()

                // MARK: - Start Workout Button

                Button {

                    // Open the selected workout.
                    showWorkout = true

                } label: {

                    Text("Start Now")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 65)
                        .background(
                            accent,
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }

        // MARK: - Native Apple Back Button

        // Keep the default system back button available.
        .navigationBarBackButtonHidden(false)
        .toolbar(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Workout Navigation

        // Pass the selected duration to the existing workout system.
        .navigationDestination(isPresented: $showWorkout) {

            workoutView(
                selectedMood: "Switch My Vibe",
                durationMinutes: minutes
            )
        }
    }
}

// MARK: - Preview
// Preview the 5-minute Switch My Vibe workout.

#Preview {
    NavigationStack {
        workoutView(
            selectedMood: "Switch My Vibe",
            durationMinutes: 5
        )
        .environmentObject(GardenProgressManager())
    }
}
