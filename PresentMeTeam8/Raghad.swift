
import SwiftUI

struct Raghad1: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 0) {

                        Text("Switch My Vibe")
                            .font(.system(size: 32, weight: .regular))
                            .foregroundStyle(Theme.textDark)
                            .padding(.top, 55)

                        Text("Focus on yourself")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.textMuted)
                            .padding(.top, 20)

                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Theme.greenLight)
                                .overlay {
                                    Circle()
                                        .stroke(
                                            Theme.green,
                                            lineWidth: 4
                                        )
                                }
//عدلي الوقت حسب التمرين كامل
                            Text("05:00")
                                .font(.system(size: 40))
                                .foregroundStyle(Theme.textDark)
                        }
                        .frame(width: 230, height: 230)

                        Spacer()

                        NavigationLink(destination: workoutView()) {
                            Text("Start Now")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 65)
                                .background(Theme.pink)
                                .cornerRadius(24)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 45)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.background)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 45)
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                }
            }
        }
    }
}

#Preview {
    Raghad1()
}
