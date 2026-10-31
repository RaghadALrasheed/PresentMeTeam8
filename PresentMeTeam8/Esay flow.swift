
import SwiftUI
import Combine
import AudioToolbox

// MARK: - Bloomove Design Colors
// Shared colors for all Easy Flow workout screens.

private enum EasyFlowColors {

    static let background = Color(
        red: 254/255,
        green: 249/255,
        blue: 243/255
    )

    static let circleFill = Color(
        red: 234/255,
        green: 239/255,
        blue: 225/255
    )

    static let darkGreen = Color(
        red: 32/255,
        green: 61/255,
        blue: 46/255
    )

    static let pink = Color(
        red: 184/255,
        green: 76/255,
        blue: 112/255
    )

    static let sageGreen = Color(
        red: 89/255,
        green: 102/255,
        blue: 94/255
    )
}

// MARK: - Exercise Model
// Keep the original exercise information and asset names.

struct Exercise: Identifiable {

    let id = UUID()
    let subtitle: String
    let minutes: Int
    let image: String
    let description: String
}

// MARK: - Easy Flow Exercise Library
// All nine original exercise assets are preserved.

extension Exercise {

    static let all: [Exercise] = [

        Exercise(
            subtitle: "Slow Walking",
            minutes: 1,
            image: "Esay flow1",
            description: "Walk slowly in place or around the room. Keep your shoulders relaxed and breathe naturally."
        ),

        Exercise(
            subtitle: "Standing Pelvic Tilts",
            minutes: 1,
            image: "Esay flow 2",
            description: "Stand tall with hands on your hips. Gently tilt your pelvis forward and back."
        ),

        Exercise(
            subtitle: "Slow Walking",
            minutes: 2,
            image: "Esay flow 3",
            description: "Walk slowly in place or around the room. Keep your shoulders relaxed and breathe naturally."
        ),

        Exercise(
            subtitle: "Pelvic Tilt",
            minutes: 1,
            image: "Esay flow 4",
            description: "Lie on your back with knees bent. Press your lower back down, then release slowly."
        ),

        Exercise(
            subtitle: "Cat-Cow",
            minutes: 1,
            image: "Esay flow 5",
            description: "On hands and knees, arch your back up, then dip it down. Move with your breath."
        ),

        Exercise(
            subtitle: "Gentle Standing March",
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
            subtitle: "Standing Hip Circles",
            minutes: 3,
            image: "Esay flow 8",
            description: "Hands on hips, draw slow circles with your hips. Switch direction halfway."
        ),

        Exercise(
            subtitle: "Standing Side Stretches",
            minutes: 3,
            image: "Esay flow 9",
            description: "Reach one arm overhead and lean to the side. Hold a moment, then switch sides."
        )
    ]
}

// MARK: - Session Step
// Store the exercise and its active duration separately.

fileprivate struct EasyFlowStep {

    let exercise: Exercise
    let seconds: Int

    init(exercise: Exercise, seconds: Int? = nil) {
        self.exercise = exercise
        self.seconds = seconds ?? exercise.minutes * 60
    }

    // Display only the exercise name above the image.
    var name: String {
        exercise.subtitle
    }

    // Display the current exercise duration below instructions.
    var durationLabel: String {
        "\(seconds / 60) Min"
    }
}

// MARK: - Easy Flow Workout Plans
// Each plan matches the exact exercise distribution requested.

private enum EasyFlowPlan {

    static func steps(for minutes: Int) -> [EasyFlowStep] {

        let all = Exercise.all

        switch minutes {

        case 2:

            // 2-minute session:
            // 1 min Slow Walking
            // 1 min Standing Pelvic Tilts

            return [
                EasyFlowStep(exercise: all[0]),
                EasyFlowStep(exercise: all[1])
            ]

        case 5:

            // 5-minute session:
            // 2 min Slow Walking
            // 1 min Pelvic Tilt
            // 1 min Cat-Cow
            // 1 min Gentle Standing March

            return [
                EasyFlowStep(exercise: all[2]),
                EasyFlowStep(exercise: all[3]),
                EasyFlowStep(exercise: all[4]),
                EasyFlowStep(exercise: all[5])
            ]

        default:

            // 10-minute session:
            // 4 min Comfortable Walking
            // 3 min Standing Hip Circles
            // 3 min Standing Side Stretches

            return [
                EasyFlowStep(exercise: all[6]),
                EasyFlowStep(exercise: all[7]),
                EasyFlowStep(exercise: all[8])
            ]
        }
    }
}

// MARK: - Easy Flow Preparation Screen
// Show the selected session time before the workout starts.

struct EasyFlowReady: View {

    let minutes: Int

    @Environment(\.dismiss) private var dismiss
    @State private var showWorkout = false

    var body: some View {

        ZStack {

            EasyFlowColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Back Button

                HStack {

                    Button {
                        dismiss()
                    } label: {
                        Label(
                            "Back",
                            systemImage: "chevron.left"
                        )
                        .font(.system(size: 16))
                        .foregroundColor(EasyFlowColors.darkGreen)
                    }

                    Spacer()
                }
                .padding(.top, 12)

                // MARK: - Workout Title

                Text("Easy Flow")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(EasyFlowColors.darkGreen)
                    .padding(.top, 55)

                Text("Move gently, at your own pace")
                    .font(.system(size: 15))
                    .foregroundColor(EasyFlowColors.sageGreen)
                    .padding(.top, 10)

                Spacer()

                // MARK: - Selected Workout Duration
                // This is a preview; the timer starts on the next screen.

                ZStack {

                    Circle()
                        .fill(EasyFlowColors.circleFill)

                    Circle()
                        .stroke(
                            EasyFlowColors.sageGreen,
                            lineWidth: 3
                        )

                    Text(
                        String(format: "%02d:00", minutes)
                    )
                    .font(.system(size: 45))
                    .monospacedDigit()
                    .foregroundColor(EasyFlowColors.darkGreen)
                }
                .frame(width: 225, height: 225)

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
                            EasyFlowColors.pink,
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)

        // Start the exact workout plan selected by the user.
        .navigationDestination(isPresented: $showWorkout) {
            ExerciseFlowView(minutes: minutes)
        }
    }
}

// MARK: - Easy Flow Session Controller
// Manage active time, 20-second breaks, results, and garden rewards.

struct ExerciseFlowView: View {

    @EnvironmentObject var gardenManager: GardenProgressManager

    let minutes: Int

    private let steps: [EasyFlowStep]

    // Active movement seconds only.
    @State private var remaining: Int

    // MARK: - Pause State

    @State private var isPaused = false

    // MARK: - Exercise Break

    private let breakDuration = 20

    @State private var isOnBreak = false
    @State private var breakRemaining = 0

    // MARK: - End Confirmation

    @State private var showEndConfirmation = false
    @State private var wasPausedBeforeConfirmation = false

    @State private var finishEarlyAfterDismiss = false
    @State private var resumeAfterDismiss = false

    // MARK: - Result Screens

    @State private var showCompletion = false
    @State private var showEarlyCompletion = false
    @State private var showGarden = false

    @State private var earnedMinutes = 0

    // A unique session ID prevents duplicate rewards.
    @State private var workoutSessionID = UUID().uuidString

    // MARK: - Timer

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

    // Find the exercise according to cumulative active seconds.
    // At a break boundary, this selects the next exercise.
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

    // Overall session progress.
    private var progress: Double {

        guard total > 0 else {
            return 0
        }

        return Double(elapsed) / Double(total)
    }

    private var hasEnded: Bool {
        showCompletion || showEarlyCompletion
    }

    // MARK: - Main Workout Screen

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

        // MARK: - Timer Updates

        .onReceive(timer) { _ in
            tick()
        }

        // Keep the phone awake during the workout.
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

                // Wait for confirmation to close before navigating.
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

        // Remember the state before confirmation.
        wasPausedBeforeConfirmation = isPaused

        // Freeze exercise or break countdowns.
        isPaused = true

        showEndConfirmation = true
    }

    // MARK: - Timer Logic

    private func tick() {

        // Never count during pause, confirmation, or completion.
        guard !isPaused,
              !showEndConfirmation,
              !hasEnded else {
            return
        }

        // MARK: - Break Countdown

        if isOnBreak {

            if breakRemaining > 1 {

                breakRemaining -= 1

            } else {

                // Start the next exercise automatically.
                breakRemaining = 0
                isOnBreak = false
            }

            // Break seconds do not count as activity.
            return
        }

        // MARK: - Active Exercise Countdown

        guard remaining > 0 else {
            return
        }

        remaining -= 1

        // Finish immediately after the final active second.
        if remaining == 0 {
            finishWorkout()
            return
        }

        // Show a 20-second break between exercises.
        if isExerciseBoundary {
            startBreak()
        }
    }

    // MARK: - Exercise Boundary Detection

    private var isExerciseBoundary: Bool {

        var accumulated = 0

        // Never show a break after the final exercise.
        for step in steps.dropLast() {

            accumulated += step.seconds

            if elapsed == accumulated {
                return true
            }
        }

        return false
    }

    // MARK: - Start Exercise Break

    private func startBreak() {

        isOnBreak = true
        breakRemaining = breakDuration

        // Play the same transition alert as the other categories.
        AudioServicesPlaySystemSound(1005)
    }

    // MARK: - Full Completion

    private func finishWorkout() {

        earnedMinutes = total / 60

        // Record completed active minutes in the garden.
        gardenManager.recordWorkout(
            id: workoutSessionID,
            completedMinutes: earnedMinutes
        )

        showCompletion = true
    }

    // MARK: - Early Completion

    private func finishEarly() {

        // Reward only completed full minutes of active exercise.
        // Break time is excluded.
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

        // HomePage closes the workout flow after this notification.
        NotificationCenter.default.post(
            name: Notification.Name("BloomoveReturnHome"),
            object: nil
        )
    }
}

// MARK: - Easy Flow Workout Page
// Match the layout and control dimensions of Switch My Vibe.

struct WorkoutPageView: View {

    fileprivate let step: EasyFlowStep

    let remaining: Int
    let progress: Double

    let isPaused: Bool
    let isOnBreak: Bool
    let breakRemaining: Int

    let onPause: () -> Void
    let onEnd: () -> Void

    // MARK: - Timer Formatting

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

    // MARK: - Main Screen

    var body: some View {

        ZStack {

            EasyFlowColors.background
                .ignoresSafeArea()

            VStack(spacing: 8) {

                // MARK: - Workout Category

                Text("Easy Flow")
                    .font(.system(size: 30))
                    .foregroundColor(EasyFlowColors.darkGreen)
                    .padding(.top, 18)

                if isOnBreak {

                    // MARK: - Next Exercise Announcement

                    Text("Up Next")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(EasyFlowColors.pink)

                    Text(step.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(EasyFlowColors.darkGreen)
                        .multilineTextAlignment(.center)

                    Text("Get ready for your next move!")
                        .font(.system(size: 14))
                        .foregroundColor(EasyFlowColors.sageGreen)

                } else {

                    // MARK: - Current Exercise Name
                    // Show only the name, without "1 min" or "2 min".

                    Text(step.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(EasyFlowColors.darkGreen)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 8)

                // MARK: - Exercise Image
                // Keep the team's original exercise illustration.
                // During breaks, show the upcoming exercise.

                Image(step.exercise.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: isOnBreak ? 230 : 280)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    .id(step.exercise.id)

                // MARK: - Exercise Instructions

                Text(step.exercise.description)
                    .font(.system(size: 13))
                    .foregroundColor(EasyFlowColors.sageGreen)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)

                Spacer(minLength: 8)

                // MARK: - Exercise Duration
                // Display the CURRENT exercise duration above the timer.
                // Never display the total session duration here.

                if isOnBreak {

                    Text("Starting in")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(EasyFlowColors.darkGreen)

                } else {

                    Text(step.durationLabel)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(EasyFlowColors.sageGreen)
                }

                // MARK: - Circular Timer
                // Show overall active workout time or the 20-second break.

                ZStack {

                    Circle()
                        .fill(EasyFlowColors.circleFill)

                    Circle()
                        .stroke(
                            EasyFlowColors.sageGreen.opacity(0.25),
                            lineWidth: 4
                        )

                    Circle()
                        .trim(
                            from: 0,
                            to: isOnBreak
                                ? Double(20 - breakRemaining) / 20.0
                                : progress
                        )
                        .stroke(
                            EasyFlowColors.sageGreen,
                            style: StrokeStyle(
                                lineWidth: 4,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))

                    Text(
                        isOnBreak ? breakTimeText : timeText
                    )
                    .font(.system(size: 32, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(EasyFlowColors.darkGreen)
                }
                .frame(width: 145, height: 145)
                .padding(.top, 10)

                // MARK: - Pause and End Controls
                // Match Switch My Vibe's 72x72 button dimensions.

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
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Unified Workout Control
    // Both Pause and End use the same 72x72 circle.
    // The same size is used by Switch My Vibe.

    private func controlButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {

        VStack(spacing: 8) {

            Button(action: action) {

                Image(systemName: icon)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(EasyFlowColors.darkGreen)
                    .frame(width: 72, height: 72)
                    .background(
                        EasyFlowColors.circleFill,
                        in: Circle()
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(EasyFlowColors.darkGreen)
        }
        .frame(width: 100)
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
