import SwiftUI
import Combine

struct Step {
    let name: String
    let text: String
    let seconds: Int
    let icon: String
    let image: String
}

enum Plan {
    static func steps(for minutes: Int) -> [Step] {
        switch minutes {
        case 2:
            return [
                Step(name: "Shoulder Rolls", text: "Stand tall, arms relaxed, slowly roll your shoulders up, back, and down, then reverse.", seconds: 30, icon: "figure.mind.and.body", image: "shoulderRolls"),
                Step(name: "Gentle Neck Tilts", text: "Stand tall, shoulders relaxed, gently tilt your ear toward each shoulder without forcing.", seconds: 30, icon: "figure.cooldown", image: "neckTilts"),
                Step(name: "Walking", text: "Walk with comfortable steps, looking ahead and swinging your arms naturally.", seconds: 60, icon: "figure.walk", image: "walking")
            ]
        case 5:
            return [
                Step(name: "Shoulder Rolls and Neck Tilts", text: "Stand tall, slowly circle your shoulders, then gently tilt your head toward each shoulder.", seconds: 60, icon: "figure.mind.and.body", image: "shoulderNeck"),
                Step(name: "Walking", text: "Walk with comfortable steps, looking ahead and swinging your arms naturally.", seconds: 120, icon: "figure.walk", image: "walking"),
                Step(name: "Standing Calf Stretch", text: "Face a wall, hands supported, step one foot back, heel down, knee straight, and bend your front knee. Switch sides.", seconds: 120, icon: "figure.flexibility", image: "calfStretch")
            ]
        default:
            return [
                Step(name: "Slow Walking", text: "Stand tall, lift one knee forward to a comfortable height, then lower and alternate.", seconds: 180, icon: "figure.walk", image: "slowWalking"),
                Step(name: "Standing Hip Circles", text: "Stand with feet hip-width apart, knees soft, slowly circle your hips in both directions.", seconds: 240, icon: "figure.cooldown", image: "hipCircles"),
                Step(name: "Standing Overhead Stretch", text: "Stand tall, reach both arms overhead, and gently stretch upward without arching your back.", seconds: 180, icon: "figure.flexibility", image: "")
            ]
        }
    }
}

enum Route: Hashable {
    case mood
    case time(String)
    case ready(String, Int)
    case workout(String, Int)
    case done(String, Int)
}

func clock(_ s: Int) -> String {
    String(format: "%02d:%02d", s / 60, s % 60)
}

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button { dismiss() } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
            .font(.system(size: 16))
            .foregroundColor(Theme.textDark)
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(Capsule().fill(Color.black.opacity(0.05)))
        }
    }
}

struct Dhay22: View {
    @State private var selected = 0
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                Theme.background.ignoresSafeArea()

                if selected == 0 {
                    HomeView(path: $path)
                } else {
                    GardenView()
                }

                HStack(spacing: 0) {
                    tabItem(icon: "house.fill", title: "Home", index: 0)
                    tabItem(icon: "leaf", title: "Garden", index: 1)
                }
                .padding(4)
                .frame(height: 62)
                .background(Capsule().fill(Color.white))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                .padding(.horizontal, 21)
                .padding(.bottom, 6)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .mood:
                    MoodView(path: $path)
                case .time(let mood):
                    TimeView(path: $path, mood: mood)
                case .ready(let mood, let minutes):
                    ReadyView(path: $path, mood: mood, minutes: minutes)
                case .workout(let mood, let minutes):
                    WorkoutView(path: $path, mood: mood, minutes: minutes)
                case .done(let mood, let minutes):
                    DoneView(path: $path, mood: mood, minutes: minutes)
                }
            }
        }
    }

    func tabItem(icon: String, title: String, index: Int) -> some View {
        let isSelected = selected == index
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selected = index }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon).font(.system(size: 20))
                Text(title).font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isSelected ? Theme.pink : Theme.green)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Capsule().fill(isSelected ? Theme.pinkLight : Color.clear))
        }
        .buttonStyle(.plain)
    }
}

struct HomeView: View {
    @Binding var path: [Route]

    @AppStorage("workoutsDone") private var workoutsDone = 0
    @AppStorage("totalMinutes") private var totalMinutes = 0

    private let slots: [CGPoint] = [
        CGPoint(x: 0.27, y: 0.53), CGPoint(x: 0.73, y: 0.55),
        CGPoint(x: 0.22, y: 0.68), CGPoint(x: 0.78, y: 0.69),
        CGPoint(x: 0.20, y: 0.84), CGPoint(x: 0.76, y: 0.85)
    ]

    var greeting: String {
        Calendar.current.component(.hour, from: Date()) < 12 ? "Good Morning!" : "Good Evening!"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(greeting)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Theme.textDark)
                .frame(height: 32, alignment: .leading)

            Text("Every move brings you closer to a better you")
                .font(.system(size: 16))
                .foregroundColor(Theme.textMuted)
                .frame(height: 24, alignment: .leading)

            Image("garden")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 330)
                .clipped()
                .overlay(
                    GeometryReader { geo in
                        ForEach(0..<min(workoutsDone, slots.count), id: \.self) { i in
                            Image(systemName: "camera.macro")
                                .font(.system(size: 28))
                                .foregroundColor(Theme.pink)
                                .position(x: geo.size.width * slots[i].x,
                                          y: geo.size.height * slots[i].y)
                                .transition(.scale)
                        }
                    }
                )
                .background(Theme.greenLight)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.top, 24)

            VStack(spacing: 4) {
                Text("Total Activity Minutes")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.green)
                Text("\(totalMinutes) mins")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textDark)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 98)
            .background(Theme.greenLight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.top, 18)
            .onLongPressGesture {
                withAnimation { workoutsDone = 0; totalMinutes = 0 }
            }

            Button(action: { path.append(.mood) }) {
                Text("Start Workout")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 330, height: 75)
                    .background(Theme.pink)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 25)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 58)
    }
}

struct GardenView: View {
    var body: some View {
        Text("Garden")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(Theme.textDark)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MoodView: View {
    @Binding var path: [Route]

    private let moods: [(title: String, text: String, icon: String)] = [
        ("Easy Flow", "Gentle moves to help you feel comfortable during your period", "drop"),
        ("Find My Calm", "Slow down, release tension and find your calm through gentle movement", "bolt"),
        ("Switch My Vibe", "Move your body, refresh your mood and feel a little brighter", "leaf"),
        ("Bloom with Energy", "Turn your energy into movement and enjoy a fun challenge", "waveform.path.ecg")
    ]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                BackButton()

                Text("What's your mood today?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textDark)
                    .frame(height: 32)
                    .padding(.top, 36)

                Text("Choose the energy that suits you")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textMuted)
                    .frame(height: 24)
                    .padding(.top, 8)

                LazyVGrid(columns: [GridItem(.fixed(176), spacing: 10), GridItem(.fixed(176))],
                          spacing: 10) {
                    ForEach(moods, id: \.title) { mood in
                        moodCard(mood)
                    }
                }
                .padding(.top, 32)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 2)
        }
        .navigationBarBackButtonHidden(true)
    }

    func moodCard(_ mood: (title: String, text: String, icon: String)) -> some View {
        Button { path.append(.time(mood.title)) } label: {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(Theme.greenLight)
                    Image(systemName: mood.icon)
                        .font(.system(size: 28))
                        .foregroundColor(Theme.green)
                }
                .frame(width: 72, height: 72)
                .padding(.top, 12)

                Text(mood.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 8)

                Text(mood.text)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .frame(width: 176, height: 208)
            .background(RoundedRectangle(cornerRadius: 20).fill(Theme.cardFill))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Theme.cardBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct TimeView: View {
    @Binding var path: [Route]
    let mood: String

    @State private var chosen: Int? = nil
    private let options = [2, 5, 10]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                BackButton()

                Text("How many minutes would you like to workout?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 36)

                VStack(spacing: 20) {
                    ForEach(options, id: \.self) { m in
                        option(m)
                    }
                }
                .padding(.top, 40)

                Spacer()

                Button {
                    if let chosen { path.append(.ready(mood, chosen)) }
                } label: {
                    Text("Continue")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 330, height: 75)
                        .background(Theme.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .frame(maxWidth: .infinity)
                .opacity(chosen == nil ? 0.4 : 1)
                .disabled(chosen == nil)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 2)
        }
        .navigationBarBackButtonHidden(true)
    }

    func option(_ m: Int) -> some View {
        let on = chosen == m
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { chosen = m }
        } label: {
            HStack {
                ZStack {
                    Circle().stroke(Theme.textDark, lineWidth: 1.5)
                    if on { Circle().fill(Theme.pink) }
                }
                .frame(width: 28, height: 28)

                Spacer()
                Text("\(m) min")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.textDark)
                Spacer()
                Color.clear.frame(width: 28, height: 28)
            }
            .padding(.horizontal, 24)
            .frame(width: 330, height: 84)
            .background(RoundedRectangle(cornerRadius: 24).fill(on ? Color(hex: "FBE5EB") : Theme.cardFill))
            .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(on ? Theme.pink : Theme.cardBorder, lineWidth: on ? 1.5 : 1))
            .shadow(color: on ? Theme.pink.opacity(0.25) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

struct ReadyView: View {
    @Binding var path: [Route]
    let mood: String
    let minutes: Int

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Text(mood)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 60)

                Text("Focus on yourself")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top, 8)

                Spacer()

                ZStack {
                    Circle().fill(Theme.greenLight)
                    Circle().strokeBorder(Theme.green, lineWidth: 1.5)
                    Text("\(minutes):00")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Theme.textDark)
                }
                .frame(width: 180, height: 180)

                Spacer()

                Button { path.append(.workout(mood, minutes)) } label: {
                    Text("Start Now")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 330, height: 75)
                        .background(Theme.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct WorkoutView: View {
    @Binding var path: [Route]
    let mood: String
    let minutes: Int

    @State private var remaining: Int
    @State private var paused = false
    private let steps: [Step]
    private let total: Int
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(path: Binding<[Route]>, mood: String, minutes: Int) {
        _path = path
        self.mood = mood
        self.minutes = minutes
        let s = Plan.steps(for: minutes)
        let t = s.reduce(0) { $0 + $1.seconds }
        steps = s
        total = t
        _remaining = State(initialValue: t)
    }

    var current: Int {
        var elapsed = total - remaining
        for (i, s) in steps.enumerated() {
            if elapsed < s.seconds { return i }
            elapsed -= s.seconds
        }
        return steps.count - 1
    }

    func label(_ s: Int) -> String {
        s < 60 ? "\(s) SEC" : "\(s / 60) Min"
    }

    var body: some View {
        let step = steps[current]

        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Text(mood)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 60)

                Text(step.name)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top, 6)

                ZStack {
                    RoundedRectangle(cornerRadius: 20).fill(Theme.greenLight)
                    if step.image.isEmpty {
                        Image(systemName: step.icon)
                            .font(.system(size: 90))
                            .foregroundColor(Theme.green)
                    } else {
                        Image(step.image)
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                    }
                }
                .frame(width: 330, height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.top, 24)

                Text(step.text)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textDark)
                    .multilineTextAlignment(.center)
                    .frame(width: 310, height: 60)
                    .padding(.top, 16)

                Text(label(step.seconds))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top, 4)

                Spacer()

                ZStack {
                    Circle().fill(Theme.greenLight)
                    Circle()
                        .trim(from: 0, to: CGFloat(total - remaining) / CGFloat(total))
                        .stroke(Theme.pink, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: remaining)
                    Text(clock(remaining))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.textDark)
                }
                .frame(width: 130, height: 130)
                .onLongPressGesture { remaining = 1 }

                HStack {
                    Button { paused.toggle() } label: {
                        VStack(spacing: 4) {
                            Image(systemName: paused ? "play.fill" : "pause.fill")
                                .font(.system(size: 22))
                            Text(paused ? "Resume" : "Pause")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Theme.textDark)
                    }

                    Spacer()

                    Button { path.removeAll() } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 22))
                            Text("End")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Theme.textDark)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(ticker) { _ in
            guard !paused, remaining > 0 else { return }
            if remaining > 1 {
                remaining -= 1
            } else {
                remaining = 0
                path.append(.done(mood, minutes))
            }
        }
    }
}

struct DoneView: View {
    @Binding var path: [Route]
    let mood: String
    let minutes: Int

    @AppStorage("workoutsDone") private var workoutsDone = 0
    @AppStorage("totalMinutes") private var totalMinutes = 0
    @State private var saved = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                ZStack {
                    Circle().fill(Theme.greenLight)
                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(Theme.green)
                }
                .frame(width: 120, height: 120)

                Text("Great Job!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textDark)

                Text("You completed \(minutes) min of \(mood)")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textMuted)

                Spacer()

                Button { path.removeAll() } label: {
                    Text("Back to Home")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 330, height: 75)
                        .background(Theme.pink)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            guard !saved else { return }
            saved = true
            workoutsDone += 1
            totalMinutes += minutes
        }
    }
}

#Preview {
    Dhay22()
}
