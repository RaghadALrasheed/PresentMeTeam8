import SwiftUI

struct OnboardingPage2: View {
    var onGetStarted: () -> Void = {}

    let accent = Color(red: 184/255, green: 76/255, blue: 112/255)       // #B84C70
    let background = Color(red: 254/255, green: 249/255, blue: 243/255)  // #FEF9F3
    let titleColor = Color(red: 32/255, green: 61/255, blue: 46/255)     // #203D2E
    let subtitleColor = Color(red: 89/255, green: 102/255, blue: 94/255) // #59665E

    var body: some View {
        List {
            Color.clear
                .frame(height: 44)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            VStack(alignment: .leading, spacing: 12) {
                Image(.flower)
                    .resizable()
                    .frame(width: 280, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                Text("Your movement grows your garden!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(titleColor)

                Text("Each run gives you something\nworth returning to.")
                    .font(.system(size: 16))
                    .foregroundColor(subtitleColor)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            HStack(spacing: 8) {
                Circle()
                    .fill(accent.opacity(0.3))
                    .frame(width: 10, height: 10)
                Circle()
                    .fill(accent)
                    .frame(width: 10, height: 10)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Button {
                onGetStarted()
            } label: {
                Text("Get Started")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.borderless)
            .padding(.top, 20)
            .padding(.horizontal, 24)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .scrollContentBackground(.hidden)
        .background(background)
    }
}

#Preview {
    OnboardingPage2()
}
