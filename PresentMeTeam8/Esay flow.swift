
import SwiftUI
import Combine
import AudioToolbox


// MARK: - Bloomove Design Colors
// Use the official Bloomove color palette across Easy Flow screens.

private enum EasyFlowColors {

    // Official Bloomove cream background.
    static let background = Color(
        red: 254/255,
        green: 249/255,
        blue: 243/255
    )

    // Light sage green used inside timer circles and controls.
    static let circleFill = Color(
        red: 234/255,
        green: 239/255,
        blue: 225/255
    )

    // Official dark green used for titles and primary text.
    static let darkGreen = Color(
        red: 32/255,
        green: 61/255,
        blue: 46/255
    )

    // Official Bloomove pink used for primary buttons.
    static let pink = Color(
        red: 184/255,
        green: 76/255,
        blue: 112/255
    )

    // Muted sage green for secondary text and timer outlines.
    static let sageGreen = Color(
        red: 89/255,
        green: 102/255,
        blue: 94/255
    )
}


// MARK: - Original Exercise Model
// Preserve the exercise information created by the team.
struct Exercise: Identifiable {

    let id = UUID()
    let subtitle: String
    let minutes: Int
    let image: String
    let description: String
}

// MARK: - Original Exercise Library
// All nine exercises remain available for future workout plans.
extension Exercise {

    static let all: [Exercise] = [

        Exercise(
            subtitle: " Slow Walking",
            minutes: 1,
            image: "Esay flow1",
            description: "Walk slowly in place or around the room. Keep your shoulders relaxed and breathe naturally."
        ),

        Exercise(
            subtitle: "Standing Pelvic",
            minutes: 1,
            image: "Esay flow 2",
            description: "Stand tall with hands on your hips. Gently tilt your pelvis forward and back."
        ),

        Exercise(
            subtitle: "Slow Walking",
            minutes: 2,
            image: "Esay flow 3",
            description: "Keep a calm, steady pace. Lift your knees a little and swing your arms softly."
        ),

        Exercise(
            subtitle: " Pelvic Tilt",
            minutes: 1,
            image: "Esay flow 4",
            description: "Lie on your back with knees bent. Press your lower back down, then release slowly."
        ),

        Exercise(
            subtitle: " Cat-Cow",
            minutes: 1,
            image: "Esay flow 5",
            description: "On hands and knees, arch your back up, then dip it down. Move with your breath."
        ),

        Exercise(
            subtitle: "Gentle Standing",
            minutes: 1,
            image: "Esay flow 6",
            description: "Stand comfortably and lift one knee at a time. Go gently and keep your balance."
        ),

        Exercise(
            subtitle: "Comfortable Walking",
            minutes: 4,
            image: "Esay flow 7",
            description: "Walk at a comfortable pace with relaxed arm swings. Stop if you feel any pain."
        ),

        Exercise(
            subtitle: " Standing Hip",
            minutes: 3,
            image: "Esay flow 8",
            description: "Hands on hips, draw slow circles with your hips. Switch direction halfway."
        ),

        Exercise(
            subtitle: " Standing Side",
            minutes: 3,
            image: "Esay flow 9",
            description: "Reach one arm overhead and lean to the side. Hold a moment, then switch sides."
        )
    ]
}

// MARK: - Session Step
// Allow a workout to use an exercise for a selected duration
// without changing its original information in Exercise.all.
private struct EasyFlowStep {

    let exercise: Exercise
    let seconds: Int
    let subtitle: String

    init(
        exercise: Exercise,
        seconds: Int? = nil,
        subtitle: String? = nil
    ) {
        self.exercise = exercise
        self.seconds = seconds ?? exercise.minutes * 60
        self.subtitle = subtitle ?? exercise.subtitle
    }
}

// MARK: - Easy Flow Workout Plans
// Build sessions of exactly 2, 5, or 10 ACTIVE minutes.
private enum EasyFlowPlan {

    static func steps(for minutes: Int) -> [EasyFlowStep] {

        let all = Exercise.all

        switch minutes {

        case 2:
            // 1 + 1 = 2 active minutes.
            return [
                EasyFlowStep(exercise: all[0]),
                EasyFlowStep(exercise: all[1])
            ]

        case 5:
            // 1 + 1 + 2 + 1 = 5 active minutes.
            return [
                EasyFlowStep(exercise: all[0]),
                EasyFlowStep(exercise: all[1]),
                EasyFlowStep(exercise: all[2]),
                EasyFlowStep(exercise: all[3])
            ]

        default:
            // 1 + 1 + 2 + 1 + 1 + 1 + 3 = 10 active minutes.
            // The final walking exercise is shortened to 3 minutes.
            return [
                EasyFlowStep(exercise: all[0]),
                EasyFlowStep(exercise: all[1]),
                EasyFlowStep(exercise: all[2]),
                EasyFlowStep(exercise: all[3]),
                EasyFlowStep(exercise: all[4]),
                EasyFlowStep(exercise: all[5]),
                EasyFlowStep(
                    exercise: all[6],
                    seconds: 180,
                    subtitle: "3 min comfortable walking"
                )
            ]
        }
    }
}

// MARK: - Easy Flow Preparation Screen
// Show the session duration before the user starts exercising.
struct EasyFlowReady: View {

    let minutes: Int

    @Environment(\.dismiss) private var dismiss
    @State private var showWorkout = false

    var body: some View {

        ZStack {

            EasyFlowColors.background.ignoresSafeArea()

            VStack(spacing: 0) {

                HStack {

                    Button {
                        dismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(EasyFlowColors.darkGreen)
                    }

                    Spacer()
                }
                .padding(.top, 12)

                Text("Easy Flow")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(EasyFlowColors.darkGreen)
                    .padding(.top, 55)

                Text("Move gently, at your own pace")
                    .font(.system(size: 15))
                    .foregroundColor(EasyFlowColors.darkGreen.opacity(0.8))
                    .padding(.top, 10)

                Spacer()

                // Show the selected duration before starting.
                ZStack {

                    Circle()
                        .fill(EasyFlowColors.circleFill)

                    Circle()
                        .stroke(
                            EasyFlowColors.darkGreen,
                            lineWidth: 3
                        )

                    Text(String(format: "%02d:00", minutes))
                        .font(.system(size: 45))
                        .monospacedDigit()
                        .foregroundColor(EasyFlowColors.darkGreen)
                }
                .frame(width: 225, height: 225)

                Spacer()

                Button {
                    showWorkout = true
                } label: {

                    Text("Start Now")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 65)
                        .background(
                            EasyFlowColors.pink,
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)

        .navigationDestination(isPresented: $showWorkout) {
            ExerciseFlowView(minutes: minutes)
        }
    }
}

// MARK: - Easy Flow Session Controller
// Manage active exercise seconds, 20-second breaks, and rewards.
struct ExerciseFlowView: View {

    @EnvironmentObject var gardenManager: GardenProgressManager

    let minutes: Int

    // Store the exercise plan for this specific session.
    private let steps: [EasyFlowStep]

    // Count only ACTIVE workout time.
    @State private var remaining: Int

    @State private var isPaused = false

    // MARK: - Break State

    // Give the user 20 seconds before each next exercise.
    private let breakDuration = 20

    @State private var isOnBreak = false
    @State private var breakRemaining = 0

    // MARK: - Confirmation State

    @State private var showEndConfirmation = false
    @State private var wasPausedBeforeConfirmation = false
    @State private var finishEarlyAfterDismiss = false
    @State private var resumeAfterDismiss = false

    // MARK: - Result State

    @State private var showCompletion = false
    @State private var showEarlyCompletion = false
    @State private var showGarden = false

    @State private var earnedMinutes = 0

    // A unique ID prevents duplicate rewards for the same session.
    @State private var workoutSessionID = UUID().uuidString

    // Update the countdown every second.
    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Initialization

    init(minutes: Int = 2) {

        self.minutes = minutes

        let selectedSteps = EasyFlowPlan.steps(for: minutes)

        self.steps = selectedSteps

        let totalSeconds = selectedSteps.reduce(0) {
            $0 + $1.seconds
        }

        _remaining = State(initialValue: totalSeconds)
    }

    // MARK: - Time Calculations

    private var total: Int {
        steps.reduce(0) {
            $0 + $1.seconds
        }
    }

    private var elapsed: Int {
        total - remaining
    }

    // Find the current exercise using its actual duration.
    // At the start of a break, this points to the NEXT exercise.
    private var currentIndex: Int {

        guard !steps.isEmpty else {
            return 0
        }

        var accumulated = 0

        for (index, step) in steps.enumerated() {

            accumulated += step.seconds

            if elapsed < accumulated {
                return index
            }
        }

        return steps.count - 1
    }

    private var currentStep: EasyFlowStep {
        steps[currentIndex]
    }

    private var progress: Double {
        guard total > 0 else {
            return 0
        }

        return Double(elapsed) / Double(total)
    }

    private var hasEnded: Bool {
        showCompletion || showEarlyCompletion
    }

    // MARK: - Main Screen

    var body: some View {

        WorkoutPageView(
            step: currentStep,
            remaining: remaining,
            progress: progress,
            isPaused: isPaused,
            isOnBreak: isOnBreak,
            breakRemaining: breakRemaining,

            onPause: {
                isPaused.toggle()
            },

            onEnd: {
                openEndConfirmation()
            }
        )

        .navigationBarBackButtonHidden(true)

        // Update workout time or break time.
        .onReceive(timer) { _ in
            tick()
        }

        // Keep the device awake during the session.
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

                // Wait until the confirmation closes before navigating.
                if finishEarlyAfterDismiss {

                    finishEarlyAfterDismiss = false
                    finishEarly()

                } else if resumeAfterDismiss {

                    // Return to the same time and exercise.
                    resumeAfterDismiss = false
                    isPaused = wasPausedBeforeConfirmation
                }
            }
        ) {

            EndWorkoutConfirmationView(
                totalMinutes: minutes,
                completedMinutes: elapsed / 60,

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

        // Open the same garden used by HomePage.
        .sheet(isPresented: $showGarden) {
            NavigationStack {
                TarfahGardenView(gardenManager: gardenManager)
            }
        }
    }

    // MARK: - End Confirmation

    private func openEndConfirmation() {

        // Remember whether the user had already paused.
        wasPausedBeforeConfirmation = isPaused

        isPaused = true
        showEndConfirmation = true
    }

    // MARK: - Timer Logic

    private func tick() {

        // Never count while paused, confirming, or finished.
        guard !isPaused,
              !showEndConfirmation,
              !hasEnded else {
            return
        }

        // MARK: Break Countdown

        if isOnBreak {

            if breakRemaining > 1 {

                breakRemaining -= 1

            } else {

                // Start the next exercise automatically.
                breakRemaining = 0
                isOnBreak = false
            }

            // Break time does not count as active movement.
            return
        }

        // MARK: Active Workout Countdown

        guard remaining > 0 else {
            return
        }

        remaining -= 1

        // Do not show a break after the final exercise.
        if remaining == 0 {
            finishWorkout()
            return
        }

        // Show a break whenever an exercise is completed.
        if isExerciseBoundary {
            startBreak()
        }
    }

    // MARK: - Exercise Boundary Detection

    // Detect the end of each exercise using cumulative seconds.
    // Exclude the final exercise so the workout completes directly.
    private var isExerciseBoundary: Bool {

        var accumulated = 0

        for step in steps.dropLast() {

            accumulated += step.seconds

            if elapsed == accumulated {
                return true
            }
        }

        return false
    }

    // MARK: - Start Break

    private func startBreak() {

        isOnBreak = true
        breakRemaining = breakDuration

        // Play the same alert used in the other Bloomove categories.
        AudioServicesPlaySystemSound(1005)
    }

    // MARK: - Full Completion

    private func finishWorkout() {

        earnedMinutes = total / 60

        // Save the completed active minutes exactly once.
        gardenManager.recordWorkout(
            id: workoutSessionID,
            completedMinutes: earnedMinutes
        )

        showCompletion = true
    }

    // MARK: - Early Completion

    private func finishEarly() {

        // Reward only full minutes of actual movement.
        // Seconds spent on preparation breaks are excluded.
        earnedMinutes = elapsed / 60

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

        // HomePage listens for this notification and closes the flow.
        NotificationCenter.default.post(
            name: Notification.Name("BloomoveReturnHome"),
            object: nil
        )
    }
}

// MARK: - Workout Page
// Preserve the original Easy Flow exercise design.
// Switch between the current exercise and the next-exercise preview.
struct WorkoutPageView: View {

    fileprivate let step: EasyFlowStep

    let remaining: Int
    let progress: Double

    let isPaused: Bool
    let isOnBreak: Bool
    let breakRemaining: Int

    let onPause: () -> Void
    let onEnd: () -> Void

    // MARK: - Timer Text

    private var timeText: String {
        String(
            format: "%02d:%02d",
            remaining / 60,
            remaining % 60
        )
    }

    private var breakTimeText: String {
        String(
            format: "%02d:%02d",
            breakRemaining / 60,
            breakRemaining % 60
        )
    }

    var body: some View {

        ZStack {

            EasyFlowColors.background.ignoresSafeArea()

            VStack(spacing: 12) {

                // MARK: - Workout Title

                Text("Easy Flow")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(EasyFlowColors.darkGreen)
                    .padding(.top, 16)

                if isOnBreak {

                    // MARK: - Break Header

                    Text("Up Next")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(EasyFlowColors.pink)

                    Text(step.subtitle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(EasyFlowColors.darkGreen)
                        .multilineTextAlignment(.center)

                    Text("Get ready for your next move!")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)

                } else {

                    // MARK: - Active Exercise Header

                    Text(step.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                // MARK: - Exercise Image

                // Display the next exercise image during a break.
                Image(step.exercise.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: isOnBreak ? 230 : 280)
                    .id(step.exercise.id)

                // MARK: - Exercise Instructions

                Text(step.exercise.description)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                // Use the official Bloomove secondary text color.
                .foregroundStyle(EasyFlowColors.sageGreen)
                    .padding(.horizontal, 22)
                    .padding(.top, 8)

                Spacer(minLength: 8)

                if isOnBreak {

                    Text("Starting in")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                } else {

                    Text("\(step.seconds / 60) Min")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                // MARK: - Circular Countdown

                ZStack {

                    Circle()
                        .fill(EasyFlowColors.circleFill)

                    Circle()
                        .trim(
                            from: 0,
                            to: isOnBreak
                                ? Double(20 - breakRemaining) / 20.0
                                : progress
                        )
                    // Use Bloomove sage green for the timer progress ring.
                    .stroke(
                        EasyFlowColors.sageGreen,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round
                        )
                    )
                        .rotationEffect(.degrees(-90))

                    Text(isOnBreak ? breakTimeText : timeText)
                        .font(.system(size: 30, weight: .medium))
                        .monospacedDigit()
                        .foregroundColor(EasyFlowColors.darkGreen)
                }
                .frame(width: 130, height: 130)

                // MARK: - Pause / Resume / End

                HStack {

                    controlButton(
                        icon: isPaused ? "play.fill" : "pause.fill",
                        label: isPaused ? "Resume" : "Pause"
                    ) {
                        onPause()
                    }

                    Spacer()

                    controlButton(
                        icon: "stop.fill",
                        label: "End"
                    ) {
                        onEnd()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 12)
        }
    }

    // MARK: - Reusable Control Button

    private func controlButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            VStack(spacing: 6) {

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(EasyFlowColors.darkGreen)
                    .frame(width: 52, height: 52)
                    .background(
                        EasyFlowColors.circleFill,
                        in: Circle()
                    )

                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
// Preview the Easy Flow preparation screen.

#Preview {
    NavigationStack {
        EasyFlowReady(minutes: 2)
            .environmentObject(GardenProgressManager())
    }
}
