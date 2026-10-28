
import SwiftUI
import Combine
import AudioToolbox

// MARK: - Find My Calm Time Selection
// Keep the original time selection screen created by the team.

struct FindMyCalmFlow: View {

    @Environment(\.dismiss) private var dismiss

    @State private var selected: Int? = nil
    @State private var goNext = false

    let options = [2, 5, 10]

    func optionCard(_ minutes: Int) -> some View {

        let isSelected = selected == minutes

        return Button {
            selected = minutes

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                goNext = true
            }

        } label: {

            ZStack {

                Text("\(minutes) min")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Theme.textDark)

                HStack {

                    ZStack {

                        Circle()
                            .strokeBorder(
                                isSelected ? Theme.pink : Theme.textDark,
                                lineWidth: 2
                            )

                        if isSelected {
                            Circle()
                                .fill(Theme.pink)
                        }
                    }
                    .frame(width: 36, height: 36)

                    Spacer()
                }
                .padding(.leading, 27)
            }
            .frame(width: 330, height: 103)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        isSelected
                        ? Color(hex: "FBE5EB")
                        : Theme.cardFill
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(Theme.cardBorder, lineWidth: 1)
            )
            .shadow(
                color: isSelected ? Theme.pink.opacity(0.25) : .clear,
                radius: 8,
                y: 4
            )
        }
        .buttonStyle(.plain)
    }

    var body: some View {

        ZStack {

            Theme.cardFill.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                Button {
                    dismiss()
                } label: {

                    HStack(spacing: 4) {

                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))

                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(Theme.textDark)
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(
                        Capsule().fill(Theme.background)
                    )
                }
                .padding(.leading, 13)
                .padding(.top, 22)

                Text("How many minutes would you like to workout?")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.textDark)
                    .frame(width: 215, alignment: .leading)
                    .padding(.leading, 13)
                    .padding(.top, 21)

                VStack(spacing: 17) {

                    ForEach(options, id: \.self) { minutes in
                        optionCard(minutes)
                    }
                }
                .padding(.leading, 44)
                .padding(.top, 57)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }
        .toolbar(.hidden, for: .navigationBar)

        .onAppear {
            selected = nil
        }

        .navigationDestination(isPresented: $goNext) {
            FindMyCalmReady(minutes: selected ?? 2)
        }
    }
}


// MARK: - Find My Calm Preparation Screen
// Keep the original start screen and selected session duration.

struct FindMyCalmReady: View {

    let minutes: Int

    @Environment(\.dismiss) private var dismiss

    @State private var start = false

    var body: some View {

        ZStack {

            Theme.cardFill.ignoresSafeArea()

            VStack(spacing: 0) {

                // Return to the previous screen.
                HStack {

                    Button {
                        dismiss()
                    } label: {

                        Label("Back", systemImage: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.textDark)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Text("Find My Calm")
                    .font(.system(size: 34))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 45)

                Text("Focus on yourself")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 39)

                ZStack {

                    Circle()
                        .fill(Color(hex: "E7EEDF"))

                    Circle()
                        .strokeBorder(Theme.green, lineWidth: 4)

                    Text(String(format: "%02d:00", minutes))
                        .font(.system(size: 44))
                        .foregroundColor(Theme.textDark)
                }
                .frame(width: 220, height: 220)
                .padding(.top, 99)

                Spacer(minLength: 0)

                // Start the workout only after tapping Start Now.
                Button {
                    start = true
                } label: {

                    Text("Start Now")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .background(Theme.pink)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 70)
            }
        }
        .toolbar(.hidden, for: .navigationBar)

        .navigationDestination(isPresented: $start) {
            FindMyCalmWorkout(minutes: minutes)
        }
    }
}


// MARK: - Find My Calm Workout
// Controls exercise timing, breaks, results, and garden rewards.

struct FindMyCalmWorkout: View {

    // Share the same garden manager used by HomePage.
    @EnvironmentObject var gardenManager: GardenProgressManager

    let minutes: Int

    // Store the original exercise plan for the chosen duration.
    private let exercises: [FindMyCalmExercise]

    // Store ACTIVE workout time only.
    // Breaks do not reduce this countdown.
    @State private var remaining: Int

    // Control Pause and Resume.
    @State private var paused = false

    // MARK: - Exercise Break State

    // Give users 20 seconds to prepare for the next exercise.
    private let breakDuration = 20

    @State private var isOnBreak = false
    @State private var breakSecondsRemaining = 0

    // MARK: - End Confirmation State

    @State private var showEndConfirmation = false

    // Preserve the pause state when opening the confirmation.
    @State private var wasPausedBeforeConfirmation = false

    // Wait until the confirmation closes before opening results.
    @State private var finishEarlyAfterDismiss = false
    @State private var resumeAfterDismiss = false

    // MARK: - Result State

    @State private var showCompletion = false
    @State private var showEarlyCompletion = false
    @State private var showGarden = false

    @State private var earnedMinutes = 0

    // A unique ID prevents duplicate garden rewards.
    @State private var workoutSessionID = UUID().uuidString

    // Run one timer event per second.
    private let ticker = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Initialization

    init(minutes: Int) {

        self.minutes = minutes

        // Load the team's exact exercise durations and images.
        let plan = FindMyCalmPlan.exercises(for: minutes)

        self.exercises = plan

        // Sum exercise seconds without adding break seconds.
        let activeSeconds = plan.reduce(0) {
            $0 + $1.seconds
        }

        _remaining = State(initialValue: activeSeconds)
    }

    // MARK: - Workout Calculations

    private var total: Int {
        exercises.reduce(0) {
            $0 + $1.seconds
        }
    }

    private var elapsed: Int {
        total - remaining
    }

    // Determine the correct exercise using cumulative durations.
    // This supports 30-second, 60-second, and longer exercises.
    private var currentIndex: Int {

        guard !exercises.isEmpty else {
            return 0
        }

        var accumulatedSeconds = 0

        for (index, exercise) in exercises.enumerated() {

            accumulatedSeconds += exercise.seconds

            if elapsed < accumulatedSeconds {
                return index
            }
        }

        return exercises.count - 1
    }

    private var currentExercise: FindMyCalmExercise {
        exercises[currentIndex]
    }

    private var clock: String {
        String(
            format: "%02d:%02d",
            remaining / 60,
            remaining % 60
        )
    }

    // Keep the existing circular timer behavior.
    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(remaining) / Double(total)
    }

    private var hasEnded: Bool {
        showCompletion || showEarlyCompletion
    }

    // MARK: - Main Workout Screen

    var body: some View {

        Group {

            if isOnBreak {

                // Preview the upcoming exercise for 20 seconds.
                FindMyCalmBreakView(
                    exercise: currentExercise,
                    remainingSeconds: breakSecondsRemaining,
                    isPaused: paused,

                    onPause: {
                        paused.toggle()
                    },

                    onEnd: {
                        openEndConfirmation()
                    }
                )

            } else {

                // Keep the original workout design from the team.
                FindMyCalmExerciseView(
                    exercise: currentExercise,
                    timeText: clock,

                    onPause: {
                        paused.toggle()
                    },

                    // Show Bloomove's custom confirmation screen.
                    onEnd: {
                        openEndConfirmation()
                    },

                    isPaused: paused,
                    progress: progress
                )
            }
        }

        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)

        // MARK: - Timer Updates

        .onReceive(ticker) { _ in
            tick()
        }

        // Keep the screen awake while the session is active.
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

                // Open the early result only after closing the cover.
                if finishEarlyAfterDismiss {

                    finishEarlyAfterDismiss = false
                    endWorkout()

                } else if resumeAfterDismiss {

                    // Restore the exact pause state.
                    resumeAfterDismiss = false
                    paused = wasPausedBeforeConfirmation
                }
            }
        ) {

            EndWorkoutConfirmationView(
                totalMinutes: minutes,
                completedMinutes: elapsed / 60,

                // Continue from the same exercise and time.
                onKeepExercising: {
                    resumeAfterDismiss = true
                    showEndConfirmation = false
                },

                // Finish early and save completed active minutes.
                onEndWorkout: {
                    finishEarlyAfterDismiss = true
                    showEndConfirmation = false
                }
            )
            .interactiveDismissDisabled(true)
        }

        // MARK: - Normal Completion

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

        // Show the real garden without creating another manager.
        .sheet(isPresented: $showGarden) {

            NavigationStack {
                TarfahGardenView(gardenManager: gardenManager)
            }
        }
    }

    // MARK: - Open End Confirmation

    // Pause the session before opening the custom confirmation.
    private func openEndConfirmation() {

        wasPausedBeforeConfirmation = paused

        paused = true

        showEndConfirmation = true
    }

    // MARK: - Timer Logic

    // Run either the active workout or the break countdown.
    private func tick() {

        // Never count while paused or while showing results.
        guard !paused,
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

            // Do not change active workout time during breaks.
            return
        }

        // MARK: Active Workout Countdown

        guard remaining > 0 else {
            return
        }

        remaining -= 1

        // Finish immediately after the last exercise.
        if remaining == 0 {
            finishWorkout()
            return
        }

        // Start a break when the current exercise ends.
        if isExerciseBoundary {
            startExerciseBreak()
        }
    }

    // MARK: - Exercise Boundary Detection

    // Find cumulative boundaries between exercises.
    // Example: a 2-minute session switches at 30s and 60s.
    // Never create a break after the final exercise.
    private var isExerciseBoundary: Bool {

        var accumulatedSeconds = 0

        for exercise in exercises.dropLast() {

            accumulatedSeconds += exercise.seconds

            if elapsed == accumulatedSeconds {
                return true
            }
        }

        return false
    }

    // MARK: - Start Exercise Break

    // Display the upcoming exercise and play an alert sound.
    private func startExerciseBreak() {

        isOnBreak = true

        breakSecondsRemaining = breakDuration

        // Use the same short notification sound as Bloom with Energy.
        AudioServicesPlaySystemSound(1005)
    }

    // MARK: - Complete Full Workout

    // Save the workout to the shared garden progress manager.
    private func finishWorkout() {

        earnedMinutes = minutes

        gardenManager.recordWorkout(
            id: workoutSessionID,
            completedMinutes: earnedMinutes
        )

        showCompletion = true
    }

    // MARK: - Complete Early Workout

    // Reward only full minutes of ACTIVE movement.
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

    // HomePage already listens for this notification.
    // Close the entire workout flow after completion.
    private func returnHome() {

        NotificationCenter.default.post(
            name: Notification.Name("BloomoveReturnHome"),
            object: nil
        )
    }
}


// MARK: - Find My Calm Exercise Break Screen
// Display the next exercise during the 20-second preparation period.
// This screen uses the existing Find My Calm color theme.

private struct FindMyCalmBreakView: View {

    let exercise: FindMyCalmExercise

    let remainingSeconds: Int

    let isPaused: Bool

    let onPause: () -> Void

    let onEnd: () -> Void

    var body: some View {

        ZStack {

            Theme.cardFill.ignoresSafeArea()

            VStack(spacing: 12) {

                Text("Find My Calm")
                    .font(.system(size: 30))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 30)

                Text("Up Next")
                    .font(.system(size: 23, weight: .bold))
                    .foregroundColor(Theme.pink)
                    .padding(.top, 12)

                // Show the next exercise name.
                Text(exercise.name)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Theme.textDark)
                    .multilineTextAlignment(.center)

                Text("Get ready for your next move!")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textMuted)

                Spacer(minLength: 8)

                // Show the next exercise image from Assets.xcassets.
                Image(exercise.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 240)

                // Explain how to perform the upcoming exercise.
                Text(exercise.text)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Spacer(minLength: 8)

                Text("Starting in")
                    .font(.system(size: 17))
                    .foregroundColor(Theme.textDark)

                // Count down from 20 seconds to zero.
                ZStack {

                    Circle()
                        .fill(Color(hex: "E7EEDF"))

                    Circle()
                        .strokeBorder(
                            Theme.green,
                            lineWidth: 4
                        )

                    Text(
                        String(
                            format: "%02d:%02d",
                            remainingSeconds / 60,
                            remainingSeconds % 60
                        )
                    )
                    .font(.system(size: 34, weight: .semibold))
                    .monospacedDigit()
                    .foregroundColor(Theme.textDark)
                }
                .frame(width: 145, height: 145)

                // Pause and End stay available during the break.
                HStack {

                    breakButton(
                        icon: isPaused ? "play.fill" : "pause.fill",
                        title: isPaused ? "Resume" : "Pause",
                        action: onPause
                    )

                    Spacer()

                    breakButton(
                        icon: "stop.fill",
                        title: "End",
                        action: onEnd
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Reusable Break Control
    // Match the existing circular workout control style.
    private func breakButton(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {

        VStack(spacing: 4) {

            Button(action: action) {

                Image(systemName: icon)
                    .font(.system(size: 23))
                    .foregroundColor(Theme.green)
                    .frame(width: 65, height: 65)
                    .background(
                        Circle()
                            .fill(Color(hex: "E7EEDF"))
                    )
            }
            .buttonStyle(.plain)

            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Theme.textDark)
        }
    }
}


// MARK: - Preview
// Preview the existing time selection flow.

#Preview {

    NavigationStack {
        FindMyCalmFlow()
            .environmentObject(GardenProgressManager())
    }
}
