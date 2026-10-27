import SwiftUI

struct MoodPage: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: String? = nil
    @State private var goTo: String? = nil

    // الألوان
    private let accent = Color(red: 184/255, green: 76/255, blue: 112/255)       // #B84C70
    private let background = Color(red: 254/255, green: 249/255, blue: 243/255)  // #FEF9F3
    private let titleColor = Color(red: 32/255, green: 61/255, blue: 46/255)     // #203D2E
    private let subtitleColor = Color(red: 89/255, green: 102/255, blue: 94/255) // #59665E

    func moodCard(title: String, text: String, icon: String) -> some View {
        let isSelected = selectedMood == title

        return Button {
            selectedMood = title
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                goTo = title
            }
        } label: {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(accent.opacity(0.15))
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(accent)
                }
                .frame(width: 72, height: 72)
                .padding(.top, 12)

                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(titleColor)
                    .padding(.top, 6)

                Text(text)
                    .font(.system(size: 12))
                    .foregroundColor(subtitleColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .frame(width: 176, height: 208)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? accent.opacity(0.15) : Color.white.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isSelected ? accent : Color.gray.opacity(0.35),
                                  lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? accent.opacity(0.25) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 16))
                    .foregroundColor(titleColor)
                }

                Text("What's your mood today?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(titleColor)
                    .padding(.top, 36)

                Text("Choose the energy that suits you")
                    .font(.system(size: 16))
                    .foregroundColor(subtitleColor)
                    .padding(.top, 4)

                LazyVGrid(columns: [GridItem(.fixed(176), spacing: 10), GridItem(.fixed(176))], spacing: 10) {
                    moodCard(title: "Easy Flow",
                             text: "Gentle moves to help you feel comfortable during your period",
                             icon: "drop")
                    moodCard(title: "Find My Calm",
                             text: "Slow down, release tension and find your calm through gentle movement",
                             icon: "bolt")
                    moodCard(title: "Switch My Vibe",
                             text: "Move your body, refresh your mood and feel a little brighter",
                             icon: "leaf")
                    moodCard(title: "Bloom with Energy",
                             text: "Turn your energy into movement and enjoy a fun challenge",
                             icon: "waveform.path.ecg")
                }
                .padding(.top, 32)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: Binding(
            get: { goTo != nil },
            set: { if !$0 { goTo = nil; selectedMood = nil } }
        )) {
            TimePageView()
        }
    }
}

#Preview {
    NavigationStack {
        MoodPage()
    }
}
