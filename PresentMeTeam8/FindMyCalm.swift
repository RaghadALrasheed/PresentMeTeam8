import SwiftUI
import Combine

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
                            .strokeBorder(isSelected ? Theme.pink : Theme.textDark, lineWidth: 2)
                        if isSelected {
                            Circle().fill(Theme.pink)
                        }
                    }
                    .frame(width: 36, height: 36)
                    Spacer()
                }
                .padding(.leading, 27)
            }
            .frame(width: 330, height: 103)
            .background(RoundedRectangle(cornerRadius: 24).fill(isSelected ? Color(hex: "FBE5EB") : Theme.cardFill))
            .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(Theme.cardBorder, lineWidth: 1))
            .shadow(color: isSelected ? Theme.pink.opacity(0.25) : .clear, radius: 8, y: 4)
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
                    .background(Capsule().fill(Theme.background))
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
                    ForEach(options, id: \.self) { m in
                        optionCard(m)
                    }
                }
                .padding(.leading, 44)
                .padding(.top, 57)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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

struct FindMyCalmReady: View {
    let minutes: Int
    @State private var start = false

    var body: some View {
        ZStack {
            Theme.cardFill.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Find My Calm")
                    .font(.system(size: 34))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 65)

                Text("Focus on yourself")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 39)

                ZStack {
                    Circle().fill(Color(hex: "E7EEDF"))
                    Circle().strokeBorder(Theme.green, lineWidth: 4)
                    Text("\(minutes):00")
                        .font(.system(size: 44))
                        .foregroundColor(Theme.textDark)
                }
                .frame(width: 220, height: 220)
                .padding(.top, 99)

                Spacer(minLength: 0)

                Button {
                    start = true
                } label: {
                    Text("Start Now")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .background(Theme.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $start) {
            FindMyCalmWorkout(minutes: minutes)
        }
    }
}

struct FindMyCalmWorkout: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("totalMinutes") private var totalMinutes = 0
    @AppStorage("workoutsDone") private var workoutsDone = 0

    let minutes: Int
    @State private var remaining: Int
    @State private var paused = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(minutes: Int) {
        self.minutes = minutes
        _remaining = State(initialValue: FindMyCalmPlan.exercises(for: minutes).reduce(0) { $0 + $1.seconds })
    }

    private var list: [FindMyCalmExercise] {
        FindMyCalmPlan.exercises(for: minutes)
    }

    private var total: Int {
        list.reduce(0) { $0 + $1.seconds }
    }

    private var index: Int {
        let elapsed = total - remaining
        var acc = 0
        for (i, e) in list.enumerated() {
            acc += e.seconds
            if elapsed < acc { return i }
        }
        return list.count - 1
    }

    private var clock: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }

    var body: some View {
        FindMyCalmExerciseView(
            exercise: list[index],
            timeText: clock,
            onPause: { paused.toggle() },
            onEnd: { dismiss() },
            isPaused: paused,
            progress: total == 0 ? 0 : Double(remaining) / Double(total)
        )
        .onReceive(ticker) { _ in
            guard !paused, remaining > 0 else { return }
            remaining -= 1
            if remaining == 0 {
                totalMinutes += minutes
                workoutsDone += 1
                NotificationCenter.default.post(name: Notification.Name("goHome"), object: nil)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        FindMyCalmFlow()
    }
}
