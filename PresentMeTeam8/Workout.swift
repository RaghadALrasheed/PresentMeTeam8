
import Foundation
import SwiftUI
import Combine
import AudioToolbox

// MARK: - Switch My Vibe Exercise Model
// Each exercise keeps its original duration, image, and instructions.

private struct SwitchVibeExercise {
    let name: String
    let imageName: String
    let description: String
    let seconds: Int

    // Display only the current exercise duration.
    // The exercise name is displayed separately above the image.
    var durationLabel: String {
        let minutes = seconds / 60
        return "\(minutes) Min"
    }
}

// MARK: - Switch My Vibe Workout Plans
// Preserve the original 2, 5, and 10-minute exercise plans.

private enum SwitchVibePlan {

    static func exercises(for minutes: Int) -> [SwitchVibeExercise] {

        switch minutes {

        case 2:
            // 2-minute plan: 1 + 1 minutes.
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
            // 10-minute plan: 2 + 6 + 2 minutes.
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
            // 5-minute plan: 1 + 2 + 1 + 1 minutes.
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

struct workoutView: View {

    // MARK: - Shared Garden Progress

    @EnvironmentObject var gardenManager: GardenProgressManager

    // Keep the initializer used by TimePageView.
    let selectedMood: String
    let durationMinutes: Int

    private let exercises: [SwitchVibeExercise]

    // Count only active workout seconds.
    // Breaks never reduce this timer.
    @State private var secondsRemaining: Int

    // MARK: - Pause State

    @State private var isPaused = false

    // MARK: - Break State

    private let breakDuration = 20

    @State private var isOnBreak = false
    @State private var breakSecondsRemaining = 0

    // MARK: - End Confirmation

    @State private var showEndConfirmation = false
    @State private var wasPausedBeforeConfirmation = false

    @State private var finishEarlyAfterDismiss = false
    @State private var resumeAfterDismiss = false

    // MARK: - Completion State

    @State private var showCompletion = false
    @State private var showEarlyCompletion = false
    @State private var showGarden = false

    @State private var earnedMinutes = 0

    // Use a unique ID to prevent duplicate workout rewards.
    @State private var workoutSessionID = UUID().uuidString

    // MARK: - Timer

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

    private var totalSeconds: Int {
        exercises.reduce(0) {
            $0 + $1.seconds
        }
    }

    private var elapsedSeconds: Int {
        totalSeconds - secondsRemaining
    }

    // Find the current exercise using cumulative durations.
    // During a break, display the upcoming exercise.
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

    private func formatTime(_ seconds: Int) -> String {
        String(
            format: "%02d:%02d",
            seconds / 60,
            seconds % 60
        )
    }

    // MARK: - Bloomove Colors

    // MARK: - Bloomove Colors
    // Match Easy Flow and Bloom with Energy.

    private let accent = Color(
        red: 184/255,
        green: 76/255,
        blue: 112/255
    )

    private let workoutBackground = Color(
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
    // MARK: - Workout Screen

    var body: some View {

        ZStack {

            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 8) {

                // MARK: - Workout Category

                Text(selectedMood)
                    .font(.system(size: 30))
                    .foregroundStyle(Theme.textDark)
                    .padding(.top, 18)

                if isOnBreak {

                    // Show an upcoming-exercise announcement.
                    Text("Up Next")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(accent)

                    // Show the exercise name without its duration.
                    Text(currentExercise.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Theme.textDark)
                        .multilineTextAlignment(.center)

                    Text("Get ready for your next move!")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textMuted)

                } else {

                    // MARK: - Exercise Name
                    // Display only the exercise name above the image.
                    // Example: "Side Movement", not "1 min Side Movement".

                    Text(currentExercise.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Theme.textDark)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 8)

                // MARK: - Exercise Image
                // Keep the team's original image for each exercise.

                Image(currentExercise.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: isOnBreak ? 230 : 280)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    .id(currentExerciseIndex)

                // MARK: - Exercise Instructions

                Text(currentExercise.description)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                Spacer(minLength: 8)

                // MARK: - Exercise Duration Label
                // Show the duration of the CURRENT exercise.
                // Do not display the total workout duration here.

                if isOnBreak {

                    Text("Starting in")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.textDark)

                } else {

                    Text(currentExercise.durationLabel)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textMuted)
                }

                // MARK: - Circular Timer
                // Keep the existing workout and break countdown logic.

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
                // Use identical 72x72 circular controls.

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

        // Keep the screen awake during workout sessions.
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }

        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }

        // MARK: - Custom End Confirmation

        .fullScreenCover(
            isPresented: $showEndConfirmation,
            onDismiss: {

                // Navigate only after the confirmation screen closes.
                if finishEarlyAfterDismiss {

                    finishEarlyAfterDismiss = false
                    finishEarly()

                } else if resumeAfterDismiss {

                    resumeAfterDismiss = false
                    isPaused = wasPausedBeforeConfirmation
                }
            }
        ) {

            EndWorkoutConfirmationView(
                totalMinutes: durationMinutes,
                completedMinutes: elapsedSeconds / 60,

                onKeepExercising: {
                    resumeAfterDismiss = true
                    showEndConfirmation = false
                },

                onEndWorkout: {
                    finishEarlyAfterDismiss = true
                    showEndConfirmation = false
                }
            )
            .interactiveDismissDisabled(true)
        }

        // MARK: - Full Workout Completion

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

        .sheet(isPresented: $showGarden) {

            NavigationStack {
                TarfahGardenView(
                    gardenManager: gardenManager
                )
            }
        }
    }

    // MARK: - End Confirmation Logic

    private func openEndConfirmation() {

        // Remember the user's original pause state.
        wasPausedBeforeConfirmation = isPaused

        // Stop active and break timers during confirmation.
        isPaused = true

        showEndConfirmation = true
    }

    // MARK: - Timer Logic

    private func tick() {

        // Do not count while paused, confirming, or completed.
        guard !isPaused,
              !showEndConfirmation,
              !hasEnded else {
            return
        }

        // MARK: - Break Countdown

        if isOnBreak {

            if breakSecondsRemaining > 1 {

                breakSecondsRemaining -= 1

            } else {

                // Automatically start the next exercise.
                breakSecondsRemaining = 0
                isOnBreak = false
            }

            // Breaks never increase earned activity minutes.
            return
        }

        // MARK: - Active Exercise Countdown

        guard secondsRemaining > 0 else {
            return
        }

        secondsRemaining -= 1

        // Finish after all active exercise seconds are completed.
        if secondsRemaining == 0 {
            finishWorkout()
            return
        }

        // Show a break after each exercise except the final one.
        if isExerciseBoundary {
            startExerciseBreak()
        }
    }

    // MARK: - Exercise Boundary Detection

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

        // Play the original sound at exercise transitions.
        AudioServicesPlaySystemSound(1005)
    }

    // MARK: - Normal Completion

    private func finishWorkout() {

        earnedMinutes = totalSeconds / 60

        // Save full activity minutes and update the garden.
        gardenManager.recordWorkout(
            id: workoutSessionID,
            completedMinutes: earnedMinutes
        )

        showCompletion = true
    }

    // MARK: - Early Completion

    private func finishEarly() {

        // Save completed full minutes only.
        // Exclude the 20-second exercise breaks.
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

    private func returnHome() {

        // HomePage handles this notification.
        NotificationCenter.default.post(
            name: Notification.Name("BloomoveReturnHome"),
            object: nil
        )
    }

    // MARK: - Unified Workout Controls
    // Both buttons are exactly 72x72 points.
    // The same dimensions can be used by other workout categories.

    private func controlButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {

        VStack(spacing: 8) {

            Button(action: action) {

                Image(systemName: icon)
                    .font(.system(size: 25, weight: .semibold))
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

// MARK: - Switch My Vibe Preparation Screen
// Show the selected workout time before starting.
// The actual countdown starts after the user taps Start Now.

struct SwitchMyVibeReadyView: View {

    let minutes: Int

    @Environment(\.dismiss) private var dismiss

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
                // This is a static time preview, not an active timer.

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

                // MARK: - Start Workout

                Button {

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

        // MARK: - Native Navigation

        .navigationBarBackButtonHidden(false)
        .toolbar(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)

        // MARK: - Workout Navigation

        .navigationDestination(isPresented: $showWorkout) {

            workoutView(
                selectedMood: "Switch My Vibe",
                durationMinutes: minutes
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        workoutView(
            selectedMood: "Switch My Vibe",
            durationMinutes: 5
        )
        .environmentObject(GardenProgressManager())
    }
}
