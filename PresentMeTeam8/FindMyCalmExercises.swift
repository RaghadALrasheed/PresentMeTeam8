import SwiftUI

struct FindMyCalmExercise: Identifiable {
    let id = UUID()
    let name: String
    let text: String
    let seconds: Int
    let image: String

    var label: String {
        seconds < 60 ? "\(seconds) SEC" : "\(seconds / 60) Min"
    }
}

enum FindMyCalmPlan {
    static func exercises(for minutes: Int) -> [FindMyCalmExercise] {
        switch minutes {
        case 2:
            return [
                FindMyCalmExercise(name: "Shoulder Rolls",
                                   text: "Stand tall, arms relaxed, slowly roll your shoulders up, back, and down, then reverse.",
                                   seconds: 30, image: "shoulderRolls"),
                FindMyCalmExercise(name: "Gentle Neck Tilts",
                                   text: "Stand tall, shoulders relaxed, gently tilt your ear toward each shoulder without forcing.",
                                   seconds: 30, image: "neckTilts"),
                FindMyCalmExercise(name: "Walking",
                                   text: "Walk with comfortable steps, looking ahead and swinging your arms naturally.",
                                   seconds: 60, image: "Walking")
            ]
        case 5:
            return [
                FindMyCalmExercise(name: "Shoulder Rolls and Neck Tilts",
                                   text: "Stand tall, slowly circle your shoulders, then gently tilt your head toward each shoulder.",
                                   seconds: 60, image: "shoulderNeck"),
                FindMyCalmExercise(name: "Walking",
                                   text: "Walk with comfortable steps, looking ahead and swinging your arms naturally.",
                                   seconds: 120, image: "Walking"),
                FindMyCalmExercise(name: "Standing Calf Stretch",
                                   text: "Face a wall, hands supported, step one foot back, heel down, knee straight, and bend your front knee slightly.",
                                   seconds: 120, image: "calfStretch")
            ]
        default:
            return [
                FindMyCalmExercise(name: "Slow Walking",
                                   text: "Stand tall, lift one knee forward to a comfortable height, then lower, and alternate.",
                                   seconds: 180, image: "slowWalking"),
                FindMyCalmExercise(name: "Standing Hip Circles",
                                   text: "Stand with feet hip-width apart, hands on hips, slowly circle your hips in both directions.",
                                   seconds: 240, image: "hipCircles"),
                FindMyCalmExercise(name: "Standing Overhead Stretch",
                                   text: "Stand tall, reach both arms overhead, and gently stretch upward without arching your back.",
                                   seconds: 180, image: "overheadStretch")
            ]
        }
    }
}

struct FindMyCalmExerciseView: View {
    let exercise: FindMyCalmExercise
    var timeText: String? = nil
    var onPause: () -> Void = {}
    var onEnd: () -> Void = {}
    var isPaused: Bool = false
    var progress: Double = 1

    private var clock: String {
        timeText ?? String(format: "%02d:%02d", exercise.seconds / 60, exercise.seconds % 60)
    }

    var body: some View {
        ZStack {
            Theme.cardFill

            Text("Find My Calm")
                .font(.system(size: 36))
                .foregroundColor(Theme.textDark)
                .position(x: 201, y: 121)

            Text(exercise.name)
                .font(.system(size: 17))
                .foregroundColor(Theme.textDark)
                .position(x: 201, y: 163)

            Image(exercise.image)
                .resizable()
                .scaledToFit()
                .frame(width: 330, height: 280)
                .position(x: 201, y: 340)

            Text(exercise.text)
                .font(.system(size: 13))
                .foregroundColor(Theme.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(width: 380)
                .position(x: 201, y: 526)

            Text(exercise.label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.textDark)
                .position(x: 201, y: 564)

            ZStack {
                Circle().fill(Color(hex: "E7EEDF"))
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Theme.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .padding(2)
                Text(clock)
                    .font(.system(size: 48))
                    .foregroundColor(Theme.textDark)
            }
            .frame(width: 160, height: 160)
            .position(x: 201, y: 689)

            Button(action: onPause) {
                ZStack {
                    Circle().fill(Color(hex: "E7EEDF"))
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.green)
                }
                .frame(width: 72, height: 72)
            }
            .buttonStyle(.plain)
            .position(x: 69, y: 785)

            Text(isPaused ? "Resume" : "Pause")
                .font(.system(size: 11))
                .foregroundColor(Theme.textDark)
                .position(x: 69, y: 843)

            Button(action: onEnd) {
                ZStack {
                    Circle().fill(Color(hex: "E7EEDF"))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Theme.green)
                        .frame(width: 24, height: 24)
                }
                .frame(width: 72, height: 72)
            }
            .buttonStyle(.plain)
            .position(x: 333, y: 785)

            Text("End")
                .font(.system(size: 11))
                .foregroundColor(Theme.textDark)
                .position(x: 333, y: 843)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    FindMyCalmExerciseView(exercise: FindMyCalmPlan.exercises(for: 2)[0])
}
