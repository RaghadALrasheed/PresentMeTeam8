
import SwiftUI
import Combine
import AudioToolbox

// MARK: - Bloom with Energy Colors
// Use the official Bloomove color palette.

enum Palette {

    static let accent = Color(
        red: 184/255,
        green: 76/255,
        blue: 112/255
    )

    static let background = Color(
        red: 254/255,
        green: 249/255,
        blue: 243/255
    )

    static let title = Color(
        red: 32/255,
        green: 61/255,
        blue: 46/255
    )

    static let subtitle = Color(
        red: 89/255,
        green: 102/255,
        blue: 94/255
    )

    static let ringFill = Color(
        red: 234/255,
        green: 239/255,
        blue: 225/255
    )
}

// MARK: - Exercise Model
// Store each exercise's name, image, and instructions.

struct WorkoutExercise: Identifiable {

    let id = UUID()
    let name: String
    let imageName: String
    let instruction: String
}

// MARK: - Bloom with Energy Workout Plan
// Preserve all five exercises and their existing image assets.

enum WorkoutPlan {

    static let moodTitle = "Bloom with Energy"

    // This category supports three workout durations.
    static let supportedMinutes = [10, 15, 30]

    static let exercises: [WorkoutExercise] = [

        WorkoutExercise(
            name: "Warm-up",
            imageName: "warm-up",
            instruction: "Roll your shoulders, circle your arms and gently loosen your neck and hips"
        ),

        WorkoutExercise(
            name: "Brisk Marching",
            imageName: "Marching Exercise",
            instruction: "Stand tall and march briskly in place, lifting knees comfortably and swinging opposite arms"
        ),

        WorkoutExercise(
            name: "Bodyweight Squats",
            imageName: "BodyWeightSquats",
            instruction: "Stand with feet shoulder-width apart, bend knees, push hips back, keep heels down, then stand"
        ),

        WorkoutExercise(
            name: "Standing Knee Lifts",
            imageName: "knee lifts",
            instruction: "Stand tall, lift one knee forward to a comfortable height, then lower and alternate"
        ),

        WorkoutExercise(
            name: "Cool-Down",
            imageName: "cool-down Exercise",
            instruction: "Slow your pace, breathe deeply and gently stretch your arms and legs"
        )
    ]
}

// MARK: - Time Formatter
// Convert seconds to MM:SS.

func timeString(_ seconds: Int) -> String {

    String(
        format: "%02d:%02d",
        seconds / 60,
        seconds % 60
    )
}

// MARK: - Root Navigation
// Keep compatibility with the existing Home navigation flow.

private struct PopToRootKey: EnvironmentKey {

    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {

    var popToRoot: () -> Void {

        get {
            self[PopToRootKey.self]
        }

        set {
            self[PopToRootKey.self] = newValue
        }
    }
}

// MARK: - Workout Preparation Screen
// Show the chosen session duration before starting.

struct WorkoutStartPage: View {

    let minutes: Int

    @Environment(\.dismiss) private var dismiss

    @State private var showSession = false

    var body: some View {

        ZStack {

            Palette.background
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Back Button

                HStack {

                    Button {
                        dismiss()
                    } label: {

                        HStack(spacing: 4) {

                            Image(systemName: "chevron.left")

                            Text("Back")
                        }
                        .font(.system(size: 16))
                        .foregroundColor(Palette.title)
                    }

                    Spacer()
                }

                // MARK: - Workout Title

                Text(WorkoutPlan.moodTitle)
                    .font(.system(size: 30))
                    .foregroundColor(Palette.title)
                    .padding(.top, 60)

                Text("Focus on yourself")
                    .font(.system(size: 14))
                    .foregroundColor(Palette.subtitle)
                    .padding(.top, 8)

                Spacer()

                // MARK: - Selected Session Duration
                // This is a static preview, not a running countdown.

                ZStack {

                    Circle()
                        .fill(Palette.ringFill)

                    Circle()
                        .stroke(
                            Palette.subtitle,
                            lineWidth: 3
                        )

                    Text(timeString(minutes * 60))
                        .font(.system(size: 48))
                        .monospacedDigit()
                        .foregroundColor(Palette.title)
                }
                .frame(width: 230, height: 230)

                Spacer()

                // MARK: - Start Now Button

                Button {

                    showSession = true

                } label: {

                    Text("Start Now")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            Palette.accent,
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)

        // MARK: - Workout Navigation

        .navigationDestination(isPresented: $showSession) {

            WorkoutSessionPage(minutes: minutes)
        }
    }
}

// MARK: - Workout Session Screen
// Manage exercises, breaks, pause/resume, and garden rewards.

struct WorkoutSessionPage: View {

    let minutes: Int

    // MARK: - Shared Garden Progress

    @EnvironmentObject var gardenManager: GardenProgressManager

    // Keep compatibility with the existing navigation environment.
    @Environment(\.popToRoot) private var popToRoot

    // A unique session ID prevents duplicate activity rewards.
    @State private var workoutSessionID = UUID().uuidString

    // Store ACTIVE workout time only.
    // Exercise breaks do not reduce this time.
    @State private var remaining: Int

    // MARK: - Pause State

    @State private var isPaused = false

    // MARK: - Break State

    // Give the user 20 seconds before the next exercise.
    private let breakDuration = 20

    @State private var isOnBreak = false
    @State private var breakSecondsRemaining = 0

    // MARK: - End Confirmation State

    @State private var showEndConfirmation = false
    @State private var wasPausedBeforeConfirmation = false

    @State private var finishEarlyAfterDismiss = false
    @State private var resumeAfterDismiss = false

    // MARK: - Completion Navigation

    @State private var showCompletion = false
    @State private var showEarlyCompletion = false
    @State private var showGarden = false

    @State private var earnedMinutes = 0

    // MARK: - Timer

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Exercises

    private let exercises = WorkoutPlan.exercises

    // MARK: - Initialization

    init(minutes: Int) {

        self.minutes = minutes

        _remaining = State(
            initialValue: minutes * 60
        )
    }

    // MARK: - Workout Calculations

    // Total active workout duration in seconds.
    private var total: Int {
        minutes * 60
    }

    // Completed active workout seconds.
    private var elapsed: Int {
        total - remaining
    }

    // Divide the workout into five equal exercise segments.
    //
    // 10-minute workout: 2 minutes per exercise.
    // 15-minute workout: 3 minutes per exercise.
    // 30-minute workout: 6 minutes per exercise.
    private var segment: Int {
        max(1, total / exercises.count)
    }

    // MARK: - Current Exercise

    // During a break, display the upcoming exercise.
    private var index: Int {

        min(
            elapsed / segment,
            exercises.count - 1
        )
    }

    private var current: WorkoutExercise {
        exercises[index]
    }

    // MARK: - Current Exercise Duration
    // Show the duration of ONE exercise, not the whole session.

    private var currentExerciseDuration: String {

        let exerciseMinutes = segment / 60

        return "\(exerciseMinutes) Min"
    }

    // MARK: - Workout Progress

    // Break time does not affect activity progress.
    private var progress: CGFloat {

        guard total > 0 else {
            return 0
        }

        return CGFloat(elapsed) / CGFloat(total)
    }

    private var hasEnded: Bool {
        showCompletion || showEarlyCompletion
    }

    // MARK: - Main Screen

    var body: some View {

        ZStack {

            Palette.background
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Display either the exercise or the transition break.
                if isOnBreak {

                    exerciseBreakContent

                } else {

                    activeExerciseContent
                }

                // Keep the controls visible during workouts and breaks.
                workoutControls
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }

        .animation(
            .easeInOut(duration: 0.3),
            value: isOnBreak
        )

        .sensoryFeedback(
            .impact,
            trigger: index
        )

        .navigationBarBackButtonHidden(true)

        // MARK: - Timer Updates

        .onReceive(timer) { _ in
            tick()
        }

        // Keep the screen awake during the session.
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

                // Navigate only after the confirmation has closed.
                if finishEarlyAfterDismiss {

                    finishEarlyAfterDismiss = false
                    endWorkout()

                } else if resumeAfterDismiss {

                    resumeAfterDismiss = false

                    // Restore the previous pause state.
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

    // MARK: - Active Exercise Layout
    // Display the exercise name without a duration prefix.
    // Show the current exercise duration above the circular timer.

    private var activeExerciseContent: some View {

        VStack(spacing: 0) {

            // MARK: - Category Title

            Text(WorkoutPlan.moodTitle)
                .font(.system(size: 30))
                .foregroundColor(Palette.title)
                .padding(.top, 18)

            // MARK: - Exercise Name
            // Example: "Brisk Marching", not "2 Min Brisk Marching".

            Text(current.name)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Palette.title)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Spacer(minLength: 8)

            // MARK: - Exercise Image

            Image(current.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 280)
                .id(index)

            // MARK: - Exercise Instructions

            Text(current.instruction)
                .font(.system(size: 13))
                .foregroundColor(Palette.subtitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            Spacer(minLength: 8)

            // MARK: - Current Exercise Duration
            // Show only the active exercise's duration.
            // Do not show the total workout duration here.

            Text(currentExerciseDuration)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Palette.subtitle)

            // MARK: - Circular Workout Timer

            ZStack {

                Circle()
                    .fill(Palette.ringFill)

                Circle()
                    .stroke(
                        Palette.subtitle.opacity(0.25),
                        lineWidth: 4
                    )

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Palette.subtitle,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .linear(duration: 1),
                        value: remaining
                    )

                // Keep the overall ACTIVE session countdown.
                Text(timeString(remaining))
                    .font(.system(size: 32, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(Palette.title)
                    .transaction {
                        $0.animation = nil
                    }
            }
            .frame(width: 145, height: 145)
            .padding(.top, 10)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    // MARK: - Exercise Break Layout
    // Show the next exercise and a 20-second countdown.

    private var exerciseBreakContent: some View {

        VStack(spacing: 8) {

            Text(WorkoutPlan.moodTitle)
                .font(.system(size: 30))
                .foregroundColor(Palette.title)
                .padding(.top, 18)

            Text("Up Next")
                .font(.system(size: 23, weight: .bold))
                .foregroundColor(Palette.accent)
                .padding(.top, 8)

            // Show the name only, without its duration.
            Text(current.name)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Palette.title)
                .multilineTextAlignment(.center)

            Text("Get ready for your next move!")
                .font(.system(size: 14))
                .foregroundColor(Palette.subtitle)

            Spacer(minLength: 8)

            // MARK: - Upcoming Exercise Image

            Image(current.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 230)
                .id(index)

            // MARK: - Upcoming Exercise Instructions

            Text(current.instruction)
                .font(.system(size: 13))
                .foregroundColor(Palette.subtitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            Spacer(minLength: 8)

            Text("Starting in")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Palette.title)

            // MARK: - Circular Break Countdown

            ZStack {

                Circle()
                    .fill(Palette.ringFill)

                Circle()
                    .stroke(
                        Palette.subtitle.opacity(0.25),
                        lineWidth: 4
                    )

                Circle()
                    .trim(
                        from: 0,
                        to: Double(
                            breakDuration - breakSecondsRemaining
                        ) / Double(breakDuration)
                    )
                    .stroke(
                        Palette.subtitle,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                Text(timeString(breakSecondsRemaining))
                    .font(.system(size: 32, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(Palette.title)
            }
            .frame(width: 145, height: 145)
            .padding(.top, 10)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    // MARK: - Workout Controls
    // Use the same dimensions as Switch My Vibe and Easy Flow.

    private var workoutControls: some View {

        HStack {

            circleButton(
                icon: isPaused ? "play.fill" : "pause.fill",
                label: isPaused ? "Resume" : "Pause"
            ) {
                isPaused.toggle()
            }

            Spacer()

            circleButton(
                icon: "stop.fill",
                label: "End"
            ) {

                // Remember the pause state before confirmation.
                wasPausedBeforeConfirmation = isPaused

                isPaused = true
                showEndConfirmation = true
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    // MARK: - Timer Logic

    private func tick() {

        // Never count while paused, confirming, or finished.
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

                // Start the next exercise automatically.
                breakSecondsRemaining = 0
                isOnBreak = false
            }

            // Break time never counts as active movement.
            return
        }

        // MARK: - Active Workout Countdown

        guard remaining > 0 else {
            return
        }

        remaining -= 1

        // Complete the session after the last active second.
        if remaining == 0 {
            finishWorkout()
            return
        }

        // Start a 20-second break between exercise segments.
        // There is no break after the final exercise.
        if elapsed % segment == 0 && elapsed < total {
            startExerciseBreak()
        }
    }

    // MARK: - Start Exercise Break

    private func startExerciseBreak() {

        isOnBreak = true
        breakSecondsRemaining = breakDuration

        // Play the existing exercise transition sound.
        AudioServicesPlaySystemSound(1005)
    }

    // MARK: - Full Workout Completion

    private func finishWorkout() {

        earnedMinutes = minutes

        // Record the session once using its unique ID.
        gardenManager.recordWorkout(
            id: workoutSessionID,
            completedMinutes: earnedMinutes
        )

        showCompletion = true
    }

    // MARK: - Early Workout Completion

    private func endWorkout() {

        // Reward only completed active minutes.
        // Exercise breaks are excluded.
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

        // Notify HomePage to close the workout flow.
        NotificationCenter.default.post(
            name: Notification.Name("BloomoveReturnHome"),
            object: nil
        )
    }

    // MARK: - Unified Workout Control
    // Pause, Resume, and End use matching 72x72 circles.

    private func circleButton(
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
                    .foregroundColor(Palette.title)
                    .frame(width: 72, height: 72)
                    .background(
                        Palette.ringFill,
                        in: Circle()
                    )
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Palette.title)
        }
        .frame(width: 100)
    }
}

// MARK: - Xcode Preview

#Preview {

    NavigationStack {

        WorkoutStartPage(minutes: 10)
            .environmentObject(GardenProgressManager())
    }
}
