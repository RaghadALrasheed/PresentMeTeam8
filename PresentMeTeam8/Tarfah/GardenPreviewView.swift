import SwiftUI

struct GardenPreviewView: View {

    @ObservedObject var gardenManager: GardenProgressManager

    private let plantingSpots: [(id: Int, x: CGFloat, y: CGFloat)] = [
        (1, 0.26, 0.55),
        (2, 0.75, 0.55),
        (3, 0.20, 0.65),
        (4, 0.80, 0.65),
        (5, 0.22, 0.77),
        (6, 0.80, 0.77)
    ]

    private func growthStage(for minutes: Int) -> String {
        switch minutes {
        case 30...: return "Bloom"
        case 15..<30: return "Bud"
        case 10..<15: return "Leaves"
        case 5..<10: return "Sprout"
        case 2..<5: return "Seed"
        default: return "NotPlanted"
        }
    }

    var body: some View {
        GeometryReader { geometry in

            let fullWidth = geometry.size.width
            let fullHeight = fullWidth * 2.15

            // Show the planting area at approximately 65% height.
            let focusY = fullHeight * 0.65

            ZStack(alignment: .topLeading) {

                ZStack {
                    Image("gardenBackground")
                        .resizable()
                        .scaledToFill()
                        .frame(width: fullWidth, height: fullHeight)
                        .clipped()

                    ForEach(plantingSpots, id: \.id) { spot in
                        if let flower = gardenManager.plantedFlowers[spot.id] {

                            let minutes = gardenManager.flowerMinutes[spot.id] ?? 2
                            let stage = growthStage(for: minutes)

                            Image("\(flower)_\(stage)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 85)
                                .position(
                                    x: fullWidth * spot.x,
                                    y: fullHeight * spot.y - 15
                                )
                        }
                    }
                }
                .frame(width: fullWidth, height: fullHeight)
                .offset(y: geometry.size.height / 2 - focusY)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .topLeading
            )
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    GardenPreviewView(gardenManager: GardenProgressManager())
}
