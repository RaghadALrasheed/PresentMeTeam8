import Foundation
import SwiftUI

struct workoutView: View {
    @State private var secondsRemaining = 300
    @State private var isPaused = false

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing:4) {

                Text("Switch My Vibe")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.textDark)
                Text("1 min Marching")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.textDark)
                
                Image("Marching Exercise")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )

                VStack(spacing: 10) {
                    Text("Stand tall and march in place, lifting your knees alternately to a comfortable height while swinging your arms naturally.")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity)

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

                    // زر Pause / Resume
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

                    // زر End
                    VStack(spacing: 8) {
                        Button {
                            secondsRemaining = 0
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
                }
            }
        }
    }
}

#Preview {
    workoutView()
}
