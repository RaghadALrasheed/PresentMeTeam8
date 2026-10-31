//
//  10 min Switch My Vibe.swift
//  PresentMeTeam8
//
//  Created by Raghad Alrasheed on 16/05/1448 AH.
//
//
//  10 Min Switch My Vibe.swift
//  PresentMeTeam8
//

import Foundation

import SwiftUI

struct min10 : View {

    @State private var secondsRemaining = 600
    @State private var isPaused = false
    @State private var didEndEarly = false
    @State private var showResultAlert = false

 
    private var currentExercise: Int {
        if secondsRemaining > 480 {
            return 0
        } else if secondsRemaining > 120 {
            return 1
        } else if secondsRemaining > 0 {
            return 2
        } else {
            return 3
        }
    }

    private let exerciseMinutes = [
        2,
        6,
        2
    ]

    private let exerciseNames = [
        "Warm-up",
        "Alternating Arm and Leg Swings",
        "Cool-down"
    ]

    private let exerciseImages = [
        "warm-up",
        "arm and leg swings Exercise",
        "cool-down Exercise"
    ]

    private let exerciseDescriptions = [
        "",
        "Stand tall, swing one arm forward with the opposite leg, then switch sides while maintaining your balance.",
        ""
    ]

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 4) {

                Text("Switch My Vibe")
                    .font(.system(size: 30))
                    .foregroundStyle(Theme.textDark)

                Text(
                    currentExercise < 3
                    ? "\(exerciseMinutes[currentExercise]) min \(exerciseNames[currentExercise])"
                    : "Workout Complete"
                )
                .font(.system(size: 16))
                .foregroundStyle(Theme.textDark)
                .multilineTextAlignment(.center)

                if currentExercise < 3 {
                    Image(exerciseImages[currentExercise])
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 240)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 20)
                        )

                    Text(exerciseDescriptions[currentExercise])
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }

                ZStack {
                    Circle()
                        .fill(Theme.greenLight)
                        .overlay {
                            Circle()
                                .stroke(Theme.green, lineWidth: 3)
                        }

                    Text(
                        String(
                            format: "%02d:%02d",
                            secondsRemaining / 60,
                            secondsRemaining % 60
                        )
                    )
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(Theme.textDark)
                }
                .frame(width: 120, height: 120)
                .padding(.top, 12)

                HStack {
                    VStack(spacing: 8) {
                        Button {
                            isPaused.toggle()
                        } label: {
                            Image(
                                systemName: isPaused
                                ? "play.fill"
                                : "pause.fill"
                            )
                            .font(.system(size: 26))
                            .foregroundStyle(Theme.textDark)
                            .frame(width: 65, height: 65)
                            .background(Theme.greenLight)
                            .clipShape(Circle())
                        }

                        Text(isPaused ? "Resume" : "Pause")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textDark)
                    }

                    Spacer()

                    VStack(spacing: 8) {
                        Button {
                            didEndEarly = true
                            isPaused = true
                            showResultAlert = true
                        } label: {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(Theme.textDark)
                                .frame(width: 65, height: 65)
                                .background(Theme.greenLight)
                                .clipShape(Circle())
                        }

                        Text("End")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textDark)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(24)
        }
        .task {
            while secondsRemaining > 0 && !didEndEarly {
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    break
                }

                if !isPaused && !didEndEarly {
                    secondsRemaining -= 1

                    if secondsRemaining == 0 {
                        didEndEarly = false
                        showResultAlert = true
                    }
                }
            }
        }
        .alert(
            didEndEarly ? "Workout Ended" : "Workout Complete",
            isPresented: $showResultAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            if didEndEarly {
                Text(
                    "You ended the workout early. \(secondsRemaining / 60) minutes and \(secondsRemaining % 60) seconds remaining."
                )
            } else {
                Text("Great job! You completed the full 10-minute workout.")
            }
        }
    }
}

#Preview {
    min10()
}
