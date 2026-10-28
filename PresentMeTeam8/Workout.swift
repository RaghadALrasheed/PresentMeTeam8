import Foundation
import SwiftUI

struct workoutView: View {
    //عدلي الثواني على حسب تمرينك
    @State private var secondsRemaining = 300
    @State private var isPaused = false
    @State private var didEndEarly = false
    @State private var showResultAlert = false
    
    private var currentExercise: Int {
        if secondsRemaining > 240 {
            return 0
        } else if secondsRemaining > 120 {
            return 1
        } else if secondsRemaining > 60 {
            return 2
        } else if secondsRemaining > 0 {
            return 3
        } else {
            return 4
        }
    }

    private let exerciseNames = [
        "Marching",
        "Standing Hamstring Curls",
        "knee Lifts",
        "Cool-down"
    ]

    private let exerciseImages = [
        "marching Exercise",
        "standing Hamstring Curls",
        "knee lifts",
        "Cool-down"
    ]

    private let exerciseDescriptions = [
        "Stand tall and march in place, lifting your knees alternately to a comfortable height while swinging your arms naturally.",
        "Stand tall, bend one knee to bring your heel toward your buttocks, then lower and alternate legs.",
        "Stand tall, lift one knee forward to a comfortable height, then lower it slowly and alternate legs.",
        ""
    ]

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing:4) {
//عدلي اسم التمرين الاساسي
                Text("Switch My Vibe")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.textDark)
                
                Text(
                    currentExercise < 4
                    ? ["1 min Marching",
                       "2 min Standing Hamstring Curls",
                       "1 min Knee Lifts",
                       "1 min Cool-down"][currentExercise]
                    : "Workout Complete"
                )
                .font(.system(size: 16))
                .foregroundStyle(Theme.textDark)

                //غيري الصوره
                if currentExercise < 4 {
                    Image(exerciseImages[currentExercise])
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 280)
                        .clipped()
                        .clipShape(
                            RoundedRectangle(cornerRadius: 20)
                        )
                }
//عدلي وصف التمرين من هنا
               
                if currentExercise < 4 {
                    VStack(spacing: 10) {
                        Text(exerciseDescriptions[currentExercise])
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                    }
                    .frame(maxWidth: .infinity)
                }

                ZStack {
                    Circle()
                        .fill(Theme.greenLight)
                        .overlay {
                            Circle()
                                .stroke(Theme.green, lineWidth: 4)
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
                .frame(width: 160, height: 160)
                .padding(.top, 16)
                HStack {

                   
                    VStack(spacing: 8) {
                        Button {
                            isPaused.toggle()
                        } label: {
                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(Theme.textDark)
                                .frame(width: 75, height: 75)
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
                                .font(.system(size: 28))
                                .foregroundStyle(Theme.textDark)
                                .frame(width: 75, height: 75)
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
            while secondsRemaining > 0 {
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    break
                }

                if !isPaused {
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
                Text("Great job! You completed the full 5-minute workout.")
            }
        }
    }
}

#Preview {
    workoutView()
}
