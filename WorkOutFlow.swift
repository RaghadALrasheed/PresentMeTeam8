import SwiftUI
import Combine

// MARK: - الألوان
enum Palette {
    static let accent = Color(red: 184/255, green: 76/255, blue: 112/255)       // #B84C70
    static let background = Color(red: 254/255, green: 249/255, blue: 243/255)  // #FEF9F3
    static let title = Color(red: 32/255, green: 61/255, blue: 46/255)          // #203D2E
    static let subtitle = Color(red: 89/255, green: 102/255, blue: 94/255)      // #59665E
    static let ringFill = Color(red: 234/255, green: 239/255, blue: 225/255)    // أخضر فاتح
}

// MARK: - التمارين
struct WorkoutExercise: Identifiable {
    let id = UUID()
    let name: String        // الاسم اللي يظهر
    let imageName: String   // اسم الصورة في Assets
    let instruction: String
}

enum WorkoutPlan {
    static let moodTitle = "Bloom with Energy"

    static let exercises: [WorkoutExercise] = [
        WorkoutExercise(name: "Warm-up",
                        imageName: "WarmUp",
                        instruction: "Roll your shoulders, circle your arms and gently loosen your neck and hips"),
        WorkoutExercise(name: "Brisk Marching",
                        imageName: "BriskMarching",
                        instruction: "Stand tall and march briskly in place, lifting knees comfortably and swinging opposite arms"),
        WorkoutExercise(name: "Bodyweight Squats",
                        imageName: "BodyWeightSquats",
                        instruction: "Stand with feet shoulder-width apart, bend knees, push hips back, keep heels down, then stand"),
        WorkoutExercise(name: "Standing Knee Lifts",
                        imageName: "StandingKneeLifts",
                        instruction: "Stand tall, lift one knee forward to a comfortable height, then lower and alternate"),
        WorkoutExercise(name: "Cool-Down",
                        imageName: "CoolDown",
                        instruction: "Slow your pace, breathe deeply and gently stretch your arms and legs")
    ]
}

func timeString(_ seconds: Int) -> String {
    String(format: "%02d:%02d", seconds / 60, seconds % 60)
}

// MARK: - الرجوع للهوم
private struct PopToRootKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var popToRoot: () -> Void {
        get { self[PopToRootKey.self] }
        set { self[PopToRootKey.self] = newValue }
    }
}

// MARK: - صفحة البداية (10:00 + Start Now)
struct WorkoutStartPage: View {
    let minutes: Int

    @Environment(\.dismiss) private var dismiss
    @State private var showSession = false

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()

            VStack(spacing: 0) {
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

                ZStack {
                    Circle().fill(Palette.ringFill)
                    Circle().stroke(Palette.subtitle, lineWidth: 3)
                    Text(timeString(minutes * 60))
                        .font(.system(size: 48))
                        .monospacedDigit()
                        .foregroundColor(Palette.title)
                }
                .frame(width: 230, height: 230)

                Spacer()

                Button {
                    showSession = true
                } label: {
                    Text("Start Now")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Palette.accent, in: RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showSession) {
            WorkoutSessionPage(minutes: minutes)
        }
    }
}

// MARK: - صفحة التمرين (التايمر + التمارين)
struct WorkoutSessionPage: View {
    let minutes: Int

    @Environment(\.popToRoot) private var popToRoot
    @AppStorage("totalMinutes") private var totalMinutes = 0

    @State private var remaining: Int
    @State private var isPaused = false
    @State private var showEndAlert = false
    @State private var showFinished = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let exercises = WorkoutPlan.exercises

    init(minutes: Int) {
        self.minutes = minutes
        _remaining = State(initialValue: minutes * 60)
    }

    private var total: Int { minutes * 60 }
    private var segment: Int { total / exercises.count }
    private var elapsed: Int { total - remaining }
    private var index: Int { min(elapsed / segment, exercises.count - 1) }
    private var current: WorkoutExercise { exercises[index] }

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Text(WorkoutPlan.moodTitle)
                    .font(.system(size: 28))
                    .foregroundColor(Palette.title)
                    .padding(.top, 40)

                Text("\(minutes / exercises.count) Min \(current.name)")
                    .font(.system(size: 14))
                    .foregroundColor(Palette.subtitle)
                    .padding(.top, 6)

                Spacer()

                Image(current.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 260)
                    .id(index)
                    .transition(.opacity)

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

                // التايمر
                ZStack {
                    Circle().fill(Palette.ringFill)
                    Circle().stroke(Palette.subtitle.opacity(0.2), lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: CGFloat(elapsed) / CGFloat(total))
                        .stroke(Palette.subtitle, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: remaining)

                    Text(timeString(remaining))
                        .font(.system(size: 30))
                        .monospacedDigit()
                        .foregroundColor(Palette.title)
                        .contentTransition(.identity)
                        .transaction { $0.animation = nil }
                }
                .frame(width: 130, height: 130)
                .padding(.top, 8)

                HStack {
                    circleButton(icon: isPaused ? "play.fill" : "pause.fill",
                                 label: isPaused ? "Resume" : "Pause") {
                        isPaused.toggle()
                    }
                    Spacer()
                    circleButton(icon: "stop.fill", label: "End") {
                        showEndAlert = true
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .animation(.easeInOut(duration: 0.4), value: index)
        .sensoryFeedback(.impact, trigger: index)
        .navigationBarBackButtonHidden(true)
        .onReceive(timer) { _ in tick() }
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .alert("End workout?", isPresented: $showEndAlert) {
            Button("Keep going", role: .cancel) {}
            Button("End", role: .destructive) { endWorkout() }
        } message: {
            Text("You've done \(elapsed / 60) min so far.")
        }
        .alert("Well done! 🌸", isPresented: $showFinished) {
            Button("Done") { popToRoot() }
        } message: {
            Text("You completed \(minutes) minutes of movement.")
        }
    }

    private func tick() {
        guard !isPaused, !showEndAlert, !showFinished, remaining > 0 else { return }
        remaining -= 1
        if remaining == 0 {
            totalMinutes += minutes
            showFinished = true
        }
    }

    private func endWorkout() {
        totalMinutes += elapsed / 60
        popToRoot()
    }

    private func circleButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 4) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Palette.subtitle)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(Palette.ringFill))
            }
            .buttonStyle(.plain)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Palette.title)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutStartPage(minutes: 10)
    }
}
