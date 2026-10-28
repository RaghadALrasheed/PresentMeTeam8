
import SwiftUI
import Combine
import AudioToolbox

// MARK: - Bloom with Energy Colors
// Defines the colors used across the workout screens.
enum Palette {
    static let accent = Color(red: 184/255, green: 76/255, blue: 112/255)
    static let background = Color(red: 254/255, green: 249/255, blue: 243/255)
    static let title = Color(red: 32/255, green: 61/255, blue: 46/255)
    static let subtitle = Color(red: 89/255, green: 102/255, blue: 94/255)
    static let ringFill = Color(red: 234/255, green: 239/255, blue: 225/255)
}

// MARK: - Exercise Model
// Stores the name, image, and instructions for each exercise.
struct WorkoutExercise: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let instruction: String
}

// MARK: - Bloom with Energy Plan
// Keeps the five original exercises and their asset names.
enum WorkoutPlan {

    static let moodTitle = "Bloom with Energy"

    // This category supports longer sessions.
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
// Converts seconds into MM:SS format.
func timeString(_ seconds: Int) -> String {
    String(format: "%02d:%02d", seconds / 60, seconds % 60)
}

// MARK: - Root Navigation
// Allows a parent screen to provide an action for returning Home.
private struct PopToRootKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var popToRoot: () -> Void {
        get { self[PopToRootKey.self] }
        set { self[PopToRootKey.self] = newValue }
    }
}

// MARK: - Workout Preparation Screen
// Displays the selected duration before starting the workout.
struct WorkoutStartPage: View {

    let minutes: Int

    @Environment(\.dismiss) private var dismiss

    // Controls navigation to the workout session.
    @State private var showSession = false

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // Return to the time selection page.
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

                Text(WorkoutPlan.moodTitle)
                    .font(.system(size: 30))
                    .foregroundColor(Palette.title)
                    .padding(.top, 60)

                Text("Focus on yourself")
                    .font(.system(size: 14))
                    .foregroundColor(Palette.subtitle)
                    .padding(.top, 8)

                Spacer()

                // Show the session duration before the countdown begins.
                ZStack {
                    Circle()
                        .fill(Palette.ringFill)

                    Circle()
                        .stroke(Palette.subtitle, lineWidth: 3)

                    Text(timeString(minutes * 60))
                        .font(.system(size: 48))
                        .monospacedDigit()
                        .foregroundColor(Palette.title)
                }
                .frame(width: 230, height: 230)

                Spacer()

                // Start the selected workout.
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

        // Pass the selected duration to the workout.
        .navigationDestination(isPresented: $showSession) {
            WorkoutSessionPage(minutes: minutes)
        }
    }
}

// MARK: - Workout Session Screen
// Manages workout time, exercise breaks, and completion screens.
struct WorkoutSessionPage: View {

    let minutes: Int

    // Use the shared garden progress manager.
    @EnvironmentObject var gardenManager: GardenProgressManager

    // Use the navigation callback provided by HomePage.
    @Environment(\.popToRoot) private var popToRoot

    // Identify each workout session to prevent duplicate rewards.
    @State private var workoutSessionID = UUID().uuidString

    // Store remaining ACTIVE workout seconds.
    // Exercise breaks never decrease this value.
    @State private var remaining: Int

    // Control pause and resume.
    @State private var isPaused = false

    // MARK: - Exercise Break State

    // Every transition between exercises has a 10-second break.
    private let breakDuration = 20

    // Determine whether the break screen is displayed.
    @State private var isOnBreak = false

    // Count down the transition between exercises.
    @State private var breakSecondsRemaining = 0

    // MARK: - End Confirmation State

    // Show the original "You're Doing Great!" screen.
    @State private var showEndConfirmation = false

    // Remember whether the workout was paused before confirmation.
    @State private var wasPausedBeforeConfirmation = false

    // Wait for the confirmation screen to close before navigating.
    @State private var finishEarlyAfterDismiss = false

    // Restore the previous pause state after Keep Exercising.
    @State private var resumeAfterDismiss = false

    // MARK: - Result Navigation

    @State private var showCompletion = false
    @State private var showEarlyCompletion = false
    @State private var showGarden = false

    // Store the number of completed full minutes.
    @State private var earnedMinutes = 0

    // Publish a timer event every second.
    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    // Reuse the original exercises created by the team.
    private let exercises = WorkoutPlan.exercises

    // Initialize the countdown with the selected duration.
    init(minutes: Int) {
        self.minutes = minutes
        _remaining = State(initialValue: minutes * 60)
    }

    // MARK: - Workout Calculations

    // Total active workout time in seconds.
    private var total: Int {
        minutes * 60
    }

    // Completed active workout time in seconds.
    private var elapsed: Int {
        total - remaining
    }

    // Divide the session into five equal exercise durations.
    // 10 minutes: 2 minutes per exercise.
    // 15 minutes: 3 minutes per exercise.
    // 30 minutes: 6 minutes per exercise.
    private var segment: Int {
        max(1, total / exercises.count)
    }

    // Select the exercise based on completed active seconds.
    private var index: Int {
        min(elapsed / segment, exercises.count - 1)
    }

    // Get the active exercise or the upcoming exercise during a break.
    private var current: WorkoutExercise {
        exercises[index]
    }

    // Show progress without including break time.
    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(elapsed) / CGFloat(total)
    }

    // Stop the countdown after a workout result is displayed.
    private var hasEnded: Bool {
        showCompletion || showEarlyCompletion
    }

    // MARK: - Main Screen

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // Switch between the active exercise and the break screen.
                if isOnBreak {
                    exerciseBreakContent
                } else {
                    activeExerciseContent
                }

                // Keep Pause and End available during exercises and breaks.
                workoutControls
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .animation(.easeInOut(duration: 0.3), value: isOnBreak)
        .sensoryFeedback(.impact, trigger: index)
        .navigationBarBackButtonHidden(true)

        // Update the active workout or break countdown.
        .onReceive(timer) { _ in
            tick()
        }

        // Keep the screen awake while the workout is in use.
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }

        // Restore the normal device sleep behavior after leaving.
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }

        // MARK: - Original End Confirmation

        // Show the existing Bloomove confirmation design.
        // Do not record minutes until End Anyway is confirmed.
        .fullScreenCover(
            isPresented: $showEndConfirmation,
            onDismiss: {
                // Finish the session only after the cover has closed.
                // This prevents conflicting SwiftUI presentations.
                if finishEarlyAfterDismiss {
                    finishEarlyAfterDismiss = false
                    endWorkout()
                } else if resumeAfterDismiss {
                    resumeAfterDismiss = false
                    isPaused = wasPausedBeforeConfirmation
                }
            }
        ) {
            EndWorkoutConfirmationView(
                totalMinutes: minutes,
                completedMinutes: elapsed / 60,

                // Return to the same exercise and saved time.
                onKeepExercising: {
                    resumeAfterDismiss = true
                    showEndConfirmation = false
                },

                // Confirm early ending and navigate to the result screen.
                onEndWorkout: {
                    finishEarlyAfterDismiss = true
                    showEndConfirmation = false
                }
            )
            .interactiveDismissDisabled(true)
        }

        // MARK: - Normal Completion

        // Display the existing achievement page after finishing.
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

        // MARK: - Early Completion

        // Display the early achievement page after End Anyway.
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

        // Open the real garden with the same saved progress.
        .sheet(isPresented: $showGarden) {
            NavigationStack {
                TarfahGardenView(gardenManager: gardenManager)
            }
        }
    }

    // MARK: - Active Exercise Layout

    // Show the current exercise name, image, instructions, and timer.
    private var activeExerciseContent: some View {
        VStack(spacing: 0) {

            Text(WorkoutPlan.moodTitle)
                .font(.system(size: 28))
                .foregroundColor(Palette.title)
                .padding(.top, 40)

            Text("\(segment / 60) Min \(current.name)")
                .font(.system(size: 14))
                .foregroundColor(Palette.subtitle)
                .padding(.top, 6)

            Spacer()

            Image(current.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 260)
                .id(index)

            Text(current.instruction)
                .font(.system(size: 13))
                .foregroundColor(Palette.subtitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.top, 16)

            Spacer()

            Text("\(minutes) Min")
                .font(.system(size: 13))
                .foregroundColor(Palette.title)

            // Display the ACTIVE session countdown.
            ZStack {
                Circle()
                    .fill(Palette.ringFill)

                Circle()
                    .stroke(
                        Palette.subtitle.opacity(0.2),
                        lineWidth: 3
                    )

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Palette.subtitle,
                        style: StrokeStyle(
                            lineWidth: 3,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .linear(duration: 1),
                        value: remaining
                    )

                Text(timeString(remaining))
                    .font(.system(size: 30))
                    .monospacedDigit()
                    .foregroundColor(Palette.title)
                    .transaction {
                        $0.animation = nil
                    }
            }
            .frame(width: 130, height: 130)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Exercise Break Layout

    // Preview the NEXT exercise while the active workout is paused.
    private var exerciseBreakContent: some View {
        VStack(spacing: 12) {

            Text(WorkoutPlan.moodTitle)
                .font(.system(size: 26))
                .foregroundColor(Palette.title)
                .padding(.top, 30)

            Text("Up Next")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Palette.accent)
                .padding(.top, 18)

            Text(current.name)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Palette.title)
                .multilineTextAlignment(.center)

            Text("Get ready for your next move!")
                .font(.system(size: 15))
                .foregroundColor(Palette.subtitle)

            Spacer(minLength: 8)

            // Show the upcoming exercise image.
            Image(current.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 230)

            // Show the upcoming exercise instructions.
            Text(current.instruction)
                .font(.system(size: 13))
                .foregroundColor(Palette.subtitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)

            Spacer(minLength: 8)

            Text("Starting in")
                .font(.system(size: 17))
                .foregroundColor(Palette.subtitle)

            // Count down 10 seconds before starting the next exercise.
            ZStack {
                Circle()
                    .fill(Palette.ringFill)

                Circle()
                    .stroke(Palette.subtitle, lineWidth: 3)

                Text(timeString(breakSecondsRemaining))
                    .font(.system(size: 32, weight: .bold))
                    .monospacedDigit()
                    .foregroundColor(Palette.title)
            }
            .frame(width: 125, height: 125)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Shared Workout Controls

    // Reuse the same Pause and End buttons during exercises and breaks.
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
                // Save the existing pause state before showing confirmation.
                wasPausedBeforeConfirmation = isPaused
                isPaused = true
                showEndConfirmation = true
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
    }

    // MARK: - Timer Logic

    // Handle the workout and break countdown with one timer.
    private func tick() {

        // Do not count while paused, confirming, or viewing results.
        guard !isPaused,
              !showEndConfirmation,
              !hasEnded else {
            return
        }

        // Count down the break without reducing workout minutes.
        if isOnBreak {

            if breakSecondsRemaining > 1 {
                breakSecondsRemaining -= 1
            } else {
                breakSecondsRemaining = 0
                isOnBreak = false
            }

            return
        }

        guard remaining > 0 else {
            return
        }

        // Decrease active workout time by one second.
        remaining -= 1

        // Complete the session immediately after the final exercise.
        if remaining == 0 {
            finishWorkout()
            return
        }

        // Start a break whenever an exercise segment is completed.
        // No break is shown after the final exercise.
        if elapsed % segment == 0 && elapsed < total {
            startExerciseBreak()
        }
    }

    // MARK: - Start Exercise Break

    // Pause active workout time and prepare the upcoming exercise.
    private func startExerciseBreak() {
        isOnBreak = true
        breakSecondsRemaining = breakDuration

        // Play a short system notification sound.
        // Device volume and silent mode may affect playback.
        AudioServicesPlaySystemSound(1005)
    }

    // MARK: - Normal Workout Completion

    // Save the full session once and open the achievement screen.
    private func finishWorkout() {
        earnedMinutes = minutes

        gardenManager.recordWorkout(
            id: workoutSessionID,
            completedMinutes: earnedMinutes
        )

        showCompletion = true
    }

    // MARK: - Early Workout Completion

    // Record only completed full minutes after End Anyway.
    // Time spent on exercise breaks is never included.
    private func endWorkout() {
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
    // Notify HomePage to close the entire workout navigation flow.
    // This returns the user directly Home after a workout.
    private func returnHome() {
        NotificationCenter.default.post(
            name: Notification.Name("BloomoveReturnHome"),
            object: nil
        )
    }

    // MARK: - Reusable Control Button

    // Keep Pause, Resume, and End buttons visually consistent.
    private func circleButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 4) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Palette.subtitle)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle().fill(Palette.ringFill)
                    )
            }
            .buttonStyle(.plain)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Palette.title)
        }
    }
}

// MARK: - Xcode Preview
// Preview a supported Bloom with Energy workout duration.
#Preview {
    NavigationStack {
        WorkoutStartPage(minutes: 10)
            .environmentObject(GardenProgressManager())
    }
}
