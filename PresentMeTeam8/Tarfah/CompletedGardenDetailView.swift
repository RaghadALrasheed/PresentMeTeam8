import SwiftUI

struct CompletedGardenDetailView: View {

    let garden: CompletedGarden

    private let plantingSpots: [(id: Int, x: CGFloat, y: CGFloat)] = [
        (1, 0.26, 0.55),
        (2, 0.75, 0.55),
        (3, 0.20, 0.65),
        (4, 0.80, 0.65),
        (5, 0.22, 0.77),
        (6, 0.80, 0.77)
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("gardenBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()

                ForEach(plantingSpots, id: \.id) { spot in
                    if let flower = garden.flowers[spot.id] {

                        let imageName = "\(flower)_Bloom"

                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 85)
                            .position(
                                x: geometry.size.width * spot.x,
                                y: geometry.size.height * spot.y - 15
                            )
                    }
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
        .navigationTitle("Completed Garden")
        .navigationBarTitleDisplayMode(.inline)
    }
}
