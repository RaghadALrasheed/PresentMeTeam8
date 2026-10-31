
import SwiftUI
import Combine
import AudioToolbox

// MARK: - Find My Calm Workout Session
// Connects existing exercises, timer, breaks,
// completion screens, and garden progress.

struct FindMyCalmWorkout: View {

    let minutes: Int

    @EnvironmentObject private var gardenManager: GardenProgressManager

    private let exercises: [FindMyCalmExercise]
    private let breakDuration = 20

    @State private var secondsRemaining: Int
    @State private var isPaused = false
    @State private var isOnBreak = false
    @State private var breakSecondsRemaining = 0

    @State private var showEndConfirmation = false
    @State private var wasPausedBeforeConfirmation = false
    @State private var finishEarlyAfterDismiss = false
    @State private var resumeAfterDismiss = false

    @State private var showCompletion = false
    @State private var showEarlyCompletion = false
    @State private var showGarden = false

    @State private var earnedMinutes = 0
    @State private var workoutSessionID = UUID().uuidString

    private let timer = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    init(minutes: Int) {
        self.minutes = minutes

        let plan = FindMyCalmPlan.exercises(for: minutes)
        self.exercises = plan

        let total = plan.reduce(0) { $0 + $1.seconds }
        _secondsRemaining = State(initialValue: total)
    }

    // MARK: - Timer Calculations

    private var totalSeconds: Int {
        exercises.reduce(0) { $0 + $1.seconds }
    }

    private var elapsedSeconds: Int {
        totalSeconds - secondsRemaining
    }

    private var currentExerciseIndex: Int {
        guard !exercises.isEmpty else { return 0 }

        var accumulated = 0

        for (index, exercise) in exercises.enumerated() {
            accumulated += exercise.seconds

            if elapsedSeconds < accumulated {
                return index
            }
        }

        return exercises.count - 1
    }

    private var currentExercise: FindMyCalmExercise {
        exercises[currentExerciseIndex]
    }

    private var currentExerciseProgress: Double {
        guard !exercises.isEmpty else { return 0 }

        let previousSeconds = exercises
            .prefix(currentExerciseIndex)
            .reduce(0) { $0 + $1.seconds }

        let completed = elapsedSeconds - previousSeconds

        return min(
            max(
                Double(completed) / Double(currentExercise.seconds),
                0
            ),
            1
        )
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

    // MARK: - Main Screen

    var body: some View {

        ZStack {

            if isOnBreak {

                
                // MARK: - Break Screen
                // Show the upcoming exercise with its image
                // and instructions during the 20-second break.

                Theme.background
                    .ignoresSafeArea()

                VStack(spacing: 8) {

                    // MARK: - Category Title

                    Text("Find My Calm")
                        .font(.system(size: 30))
                        .foregroundStyle(Theme.textDark)
                        .padding(.top, 18)

                    // MARK: - Up Next

                    Text("Up Next")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(Theme.pink)

                    // MARK: - Next Exercise Name

                    Text(currentExercise.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Theme.textDark)
                        .multilineTextAlignment(.center)

                    Spacer(minLength: 8)

                    // MARK: - Next Exercise Image

                    Image(currentExercise.image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 230)
                        .id(currentExerciseIndex)

                    // MARK: - Next Exercise Instructions

                    Text(currentExercise.text)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 12)
                        .padding(.top, 8)

                    Spacer(minLength: 8)

                    Text("Starting in")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.textDark)

                    // MARK: - Break Countdown

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
                                to: Double(
                                    breakDuration - breakSecondsRemaining
                                ) / Double(breakDuration)
                            )
                            .stroke(
                                Theme.green,
                                style: StrokeStyle(
                                    lineWidth: 4,
                                    lineCap: .round
                                )
                            )
                            .rotationEffect(.degrees(-90))

                        Text(formatTime(breakSecondsRemaining))
                            .font(.system(size: 32, weight: .medium))
                            .monospacedDigit()
                            .foregroundStyle(Theme.textDark)
                    }
                    .frame(width: 145, height: 145)
                    .padding(.top, 10)

                    // MARK: - Break Controls

                    HStack {

                        breakControlButton(
                            icon: isPaused ? "play.fill" : "pause.fill",
                            label: isPaused ? "Resume" : "Pause"
                        ) {
                            isPaused.toggle()
                        }

                        Spacer()

                        breakControlButton(
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


            } else {

                // MARK: - Existing Exercise Screen

                FindMyCalmExerciseView(
                    exercise: currentExercise,
                    timeText: formatTime(secondsRemaining),
                    onPause: {
                        isPaused.toggle()
                    },
                    onEnd: {
                        openEndConfirmation()
                    },
                    isPaused: isPaused,
                    progress: currentExerciseProgress
                )
            }
        }
        .navigationBarBackButtonHidden(true)

        // MARK: - Timer

        .onReceive(timer) { _ in
            tick()
        }

        // MARK: - End Workout Confirmation

        .fullScreenCover(
            isPresented: $showEndConfirmation,
            onDismiss: {

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

        // MARK: - Full Completion

        .navigationDestination(
            isPresented: $showCompletion
        ) {

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

        .navigationDestination(
            isPresented: $showEarlyCompletion
        ) {

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

        // MARK: - Garden

        .sheet(isPresented: $showGarden) {

            NavigationStack {

                TarfahGardenView(
                    gardenManager: gardenManager
                )
            }
        }
    }

    // MARK: - Timer Logic

    private func tick() {

        guard !isPaused,
              !showEndConfirmation,
              !hasEnded else {
            return
        }

        if isOnBreak {

            if breakSecondsRemaining > 1 {

                breakSecondsRemaining -= 1

            } else {

                breakSecondsRemaining = 0
                isOnBreak = false

                // Play a sound when the next exercise starts.
                AudioServicesPlaySystemSound(1005)
            }

            return
        }

        guard secondsRemaining > 0 else {
            return
        }

        secondsRemaining -= 1

        if secondsRemaining == 0 {
            finishWorkout()
            return
        }

        if isExerciseBoundary {
            isOnBreak = true
            breakSecondsRemaining = breakDuration

            // Play a sound when the exercise ends.
            AudioServicesPlaySystemSound(1005)
        }
    }

    // MARK: - Exercise Transition

    private var isExerciseBoundary: Bool {

        var accumulated = 0

        for exercise in exercises.dropLast() {

            accumulated += exercise.seconds

            if elapsedSeconds == accumulated {
                return true
            }
        }

        return false
    }

    // MARK: - End Confirmation

    private func openEndConfirmation() {

        wasPausedBeforeConfirmation = isPaused
        isPaused = true
        showEndConfirmation = true
    }

    // MARK: - Normal Completion

    private func finishWorkout() {

        earnedMinutes = totalSeconds / 60

        gardenManager.recordWorkout(
            id: workoutSessionID,
            completedMinutes: earnedMinutes
        )

        showCompletion = true
    }

    // MARK: - Early Completion

    private func finishEarly() {

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

        NotificationCenter.default.post(
            name: Notification.Name("BloomoveReturnHome"),
            object: nil
        )
    }
    
    // MARK: - Unified Break Controls
    // Match the exercise screen buttons.

    private func breakControlButton(
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
            }
            .buttonStyle(.plain)

            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textDark)
        }
        .frame(width: 100)
    }

}
