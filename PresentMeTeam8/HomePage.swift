import SwiftUI

struct HomePage: View {
    @AppStorage("totalMinutes") private var totalMinutes = 0
    @State private var showMood = false

    // الألوان
    private let accent = Color(red: 184/255, green: 76/255, blue: 112/255)       // #B84C70
    private let background = Color(red: 254/255, green: 249/255, blue: 243/255)  // #FEF9F3
    private let titleColor = Color(red: 32/255, green: 61/255, blue: 46/255)     // #203D2E
    private let subtitleColor = Color(red: 89/255, green: 102/255, blue: 94/255) // #59665E
    private let statsCard = Color(red: 234/255, green: 239/255, blue: 225/255)   // أخضر فاتح

    var greeting: String {
        Calendar.current.component(.hour, from: Date()) < 12 ? "Good Morning!" : "Good Evening!"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    Text(greeting)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(titleColor)

                    Text("Every move brings you closer to a better you")
                        .font(.system(size: 16))
                        .foregroundColor(subtitleColor)
                        .padding(.top, 4)

                    Image(.garden)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 330)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.top, 24)

                    VStack(spacing: 4) {
                        Text("Total Activity Minutes")
                            .font(.system(size: 16))
                            .foregroundColor(subtitleColor)
                        Text("\(totalMinutes) mins")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(titleColor)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 98)
                    .background(statsCard)
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
                            .background(accent)
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
                    .foregroundColor(accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Capsule().fill(accent.opacity(0.15)))

                    VStack(spacing: 2) {
                        Image(systemName: "leaf")
                            .font(.system(size: 20))
                        Text("Garden")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(subtitleColor)
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
    HomePage()
}
