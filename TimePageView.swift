import SwiftUI

struct TimePageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMinutes: Int = 10

    private let options = [10, 15, 30]

    // الألوان
    private let accent = Color(red: 184/255, green: 76/255, blue: 112/255)      // #B84C70
    private let background = Color(red: 254/255, green: 249/255, blue: 243/255) // #FEF9F3
    private let titleColor = Color(red: 32/255, green: 61/255, blue: 46/255)    // #203D2E
    private let minutesColor = Color(red: 89/255, green: 102/255, blue: 94/255) // #59665E

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                Text("How many minutes would you like to workout?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(titleColor)
                    .padding(.top, 24)

                Spacer()

                // MARK: - Options
                VStack(spacing: 16) {
                    ForEach(options, id: \.self) { minutes in
                        optionRow(minutes)
                    }
                }

                Spacer()

                // MARK: - Continue
                Button {
                    print("Selected: \(selectedMinutes) min")
                } label: {
                    Text("Continue")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(accent, in: RoundedRectangle(cornerRadius: 18))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Option row
    @ViewBuilder
    private func optionRow(_ minutes: Int) -> some View {
        let isSelected = selectedMinutes == minutes

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMinutes = minutes
            }
        } label: {
            ZStack {
                Text("\(minutes) min")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(minutesColor)

                HStack {
                    ZStack {
                        Circle()
                            .stroke(isSelected ? accent : Color.black, lineWidth: 2.5)
                            .frame(width: 28, height: 28)
                        if isSelected {
                            Circle()
                                .fill(accent)
                                .frame(width: 28, height: 28)
                        }
                    }
                    Spacer()
                }
                .padding(.leading, 24)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(isSelected ? accent.opacity(0.25) : Color.white.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? accent : Color.gray.opacity(0.35),
                            lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        TimePageView()
    }
}
