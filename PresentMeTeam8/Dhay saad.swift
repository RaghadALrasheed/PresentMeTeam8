import SwiftUI

struct Dhay22: View {
    @AppStorage("totalMinutes") private var totalMinutes = 0
    @State private var showMood = false

    var greeting: String {
        Calendar.current.component(.hour, from: Date()) < 12 ? "Good Morning!" : "Good Evening!"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Theme.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    Text(greeting)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.textDark)

                    Text("Every move brings you closer to a better you")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.textMuted)
                        .padding(.top, 4)

                    Image("garden")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 330)
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
                        totalMinutes = 0
                    }

                    Button {
                        showMood = true
                    } label: {
                        Text("Start Workout")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 330, height: 75)
                            .background(Theme.pink)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 25)
                }
                .padding(.horizontal, 20)
                .padding(.top, 58)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                HStack(spacing: 0) {
                    VStack(spacing: 2) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 20))
                        Text("Home")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Theme.pink)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Capsule().fill(Theme.pinkLight))

                    VStack(spacing: 2) {
                        Image(systemName: "leaf")
                            .font(.system(size: 20))
                        Text("Garden")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Theme.green)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(4)
                .frame(height: 62)
                .background(Capsule().fill(Color.white))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                .padding(.horizontal, 21)
                .padding(.bottom, 6)
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showMood) {
                MoodPage()
            }
        }
    }
}

#Preview {
    Dhay22()
}
