
import SwiftUI

// MARK: - Completed Garden Detail View
// Displays the flowers saved in a completed garden.

struct CompletedGardenDetailView: View {

    let garden: CompletedGarden
    @Environment(\.dismiss) private var dismiss

    // MARK: - Original Planting Spots
    // Keep the same coordinates as the main garden.

    private let plantingSpots: [
        (id: Int, x: CGFloat, y: CGFloat)
    ] = [
        (1, 0.26, 0.55),
        (2, 0.75, 0.55),
        (3, 0.20, 0.65),
        (4, 0.80, 0.65),
        (5, 0.22, 0.77),
        (6, 0.80, 0.77)
    ]

    // MARK: - Main Screen

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                // MARK: - Custom Garden Header

                VStack {

                    // MARK: - Back Button

                    HStack {

                        Button {
                            dismiss()
                        } label: {

                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(
                                    BloomoveColors.darkGreen
                                )
                                .frame(width: 44, height: 44)
                                .background(
                                    BloomoveColors.background.opacity(0.92),
                                    in: Circle()
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Back")

                        Spacer()
                    }

                    // MARK: - Garden Title

                    Text("Completed Garden")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(
                            BloomoveColors.darkGreen
                        )
                        .padding(.horizontal, 24)
                        .padding(.vertical, 13)
                        .background(
                            BloomoveColors.background.opacity(0.92),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                        .padding(.top, 12)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(20)

                // MARK: - Saved Flowers
                // Read flower types from the completed garden.
                // Every completed flower uses its Bloom asset.

                ForEach(plantingSpots, id: \.id) { spot in

                    if let flower = garden.flowers[spot.id] {

                        let imageName = "\(flower)_Bloom"

                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 75,
                                height: 85
                            )
                            .position(
                                x: geometry.size.width * spot.x,
                                y: geometry.size.height * spot.y - 23
                            )
                    }
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }

        // MARK: - Full Screen Background
        // Keep the background outside GeometryReader
        // so it fills the top and bottom safe areas.

        .background {

            Image("gardenBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }

        // MARK: - Navigation

        .toolbar(.hidden, for: .navigationBar)
    }
}
