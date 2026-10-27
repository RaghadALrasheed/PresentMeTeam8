import SwiftUI

struct MoodPage: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMood: String? = nil
    @State private var goTo: String? = nil

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
                    Circle().fill(Theme.greenLight)
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(Theme.green)
                }
                .frame(width: 72, height: 72)
                .padding(.top, 12)

                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 6)

                Text(text)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .frame(width: 176, height: 208)
            .background(RoundedRectangle(cornerRadius: 20).fill(isSelected ? Color(hex: "FBE5EB") : Theme.cardFill))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isSelected ? Theme.pink : Theme.cardBorder, lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? Theme.pink.opacity(0.25) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    var body: some View {
        ZStack {
            Theme.cardFill.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(Theme.textDark)
                    .padding(.horizontal, 14)
                    .frame(height: 41)
                    .background(Capsule().fill(Theme.background))
                }

                Text("What's your mood today?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textDark)
                    .padding(.top, 28)

                Text("Choose the energy that suit you")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textMuted)
                    .padding(.top, 8)

                LazyVGrid(columns: [GridItem(.fixed(176), spacing: 10), GridItem(.fixed(176))], spacing: 10) {
                    moodCard(title: "Easy Flow",
                             text: "Gentle moves to help you feel comfortable during your period",
                             icon: "drop")
                    moodCard(title: "Find My Calm",
                             text: "Slow down release tension and find your calm through gentle move",
                             icon: "bolt")
                    moodCard(title: "Switch My Vibe",
                             text: "Move your body refresh your mood and feel little brighter",
                             icon: "leaf")
                    moodCard(title: "Bloom with Energy",
                             text: "Turn your energy into movement and enjoy a fun challenge",
                             icon: "waveform.path.ecg")
                }
                .padding(.top, 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            selectedMood = nil
        }
        .navigationDestination(item: $goTo) { mood in
            switch mood {
            case "Easy Flow":
                EasyFlowFlow()
            case "Find My Calm":
                FindMyCalmFlow()
            case "Switch My Vibe":
                SwitchMyVibeFlow()
            default:
                BloomWithEnergyFlow()
            }
        }
    }
}

#Preview {
    NavigationStack {
        MoodPage()
    }
}
