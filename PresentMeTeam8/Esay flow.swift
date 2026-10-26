//
//  Esay flow.swift
//  PresentMeTeam8
//
//  Created by lama farhan on 14/05/1448 AH.
//

import SwiftUI
import Combine

// MARK: - Model
struct Exercise: Identifiable {
    let id = UUID()
    let subtitle: String
    let minutes: Int
    let image: String
    let description: String
}

extension Exercise {
    static let all: [Exercise] = [
        Exercise(subtitle: "1 min slow walking", minutes: 1, image: "Esay flow1",
                 description: "Walk slowly in place or around the room. Keep your shoulders relaxed and breathe naturally."),
        Exercise(subtitle: "1 min Standing Pelvic", minutes: 1, image: "Esay flow 2",
                 description: "Stand tall with hands on your hips. Gently tilt your pelvis forward and back."),
        Exercise(subtitle: "2 min slow walking", minutes: 2, image: "Esay flow 3",
                 description: "Keep a calm, steady pace. Lift your knees a little and swing your arms softly."),
        Exercise(subtitle: "1 min Pelvic Tilt", minutes: 1, image: "Esay flow 4",
                 description: "Lie on your back with knees bent. Press your lower back down, then release slowly."),
        Exercise(subtitle: "1 min Cat-Cow", minutes: 1, image: "Esay flow 5",
                 description: "On hands and knees, arch your back up, then dip it down. Move with your breath."),
        Exercise(subtitle: "1 min Gentle Standing", minutes: 1, image: "Esay flow 6",
                 description: "Stand comfortably and lift one knee at a time. Go gently and keep your balance."),
        Exercise(subtitle: "4 min comfortable", minutes: 4, image: "Esay flow 7",
                 description: "Walk at a comfortable pace with relaxed arm swings. Stop if you feel any pain."),
        Exercise(subtitle: "3 min Standing Hip", minutes: 3, image: "Esay flow 8",
                 description: "Hands on hips, draw slow circles with your hips. Switch direction halfway."),
        Exercise(subtitle: "3 min Standing Side", minutes: 3, image: "Esay flow 9",
                 description: "Reach one arm overhead and lean to the side. Hold a moment, then switch sides.")
    ]
}

// MARK: - Flow (يشغّل التمارين بالترتيب)
struct ExerciseFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var index = 0
    private let exercises = Exercise.all

    var body: some View {
        WorkoutPageView(
            exercise: exercises[index],
            onFinish: {
                if index < exercises.count - 1 {
                    index += 1
                } else {
                    dismiss()
                }
            },
            onEnd: { dismiss() }
        )
        .id(index) // يعيد بناء الصفحة والمؤقت لكل تمرين
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Workout Page
struct WorkoutPageView: View {
    let exercise: Exercise
    let onFinish: () -> Void
    let onEnd: () -> Void

    @State private var remaining: Int
    @State private var isPaused = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let background = Color(red: 0.96, green: 0.95, blue: 0.91)
    private let circleFill = Color(red: 0.85, green: 0.92, blue: 0.84)
    private let darkGreen  = Color(red: 0.29, green: 0.42, blue: 0.40)

    init(exercise: Exercise, onFinish: @escaping () -> Void, onEnd: @escaping () -> Void) {
        self.exercise = exercise
        self.onFinish = onFinish
        self.onEnd = onEnd
        _remaining = State(initialValue: exercise.minutes * 60)
    }

    private var progress: Double {
        1 - Double(remaining) / Double(exercise.minutes * 60)
    }

    private var timeText: String {
        String(format: "%d:%02d", remaining / 60, remaining % 60)
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(spacing: 12) {
                // Title
                Text("Easy Flow")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(exercise.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                // Image
                Image(exercise.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)

                // Description
                Text(exercise.description)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black.opacity(0.7))
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                Text("\(exercise.minutes) Min")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()

                // Timer
                ZStack {
                    Circle().fill(circleFill)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(darkGreen, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text(timeText)
                        .font(.title)
                        .fontWeight(.medium)
                        .monospacedDigit()
                }
                .frame(width: 130, height: 130)

                // Pause / End
                HStack {
                    controlButton(
                        icon: isPaused ? "play.fill" : "pause.fill",
                        label: isPaused ? "Resume" : "Pause"
                    ) {
                        isPaused.toggle()
                    }

                    Spacer()

                    controlButton(icon: "stop.fill", label: "End") {
                        onEnd()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
            }
            .padding(.top, 16)
        }
        .onReceive(timer) { _ in
            guard !isPaused else { return }
            if remaining > 1 {
                remaining -= 1
            } else {
                remaining = 0
                onFinish()
            }
        }
    }

    private func controlButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(darkGreen)
                    .frame(width: 52, height: 52)
                    .background(circleFill, in: Circle())
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ExerciseFlowView()
    }
}
