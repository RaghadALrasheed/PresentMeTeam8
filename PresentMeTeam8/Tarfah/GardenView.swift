//
//  GardenView.swift
//  PresentMeTeam8
//
//  Created by Tarfah Alsaleh on 14/05/1448 AH.
//

import SwiftUI

struct TarfahGardenView: View {
    
    @ObservedObject var gardenManager: GardenProgressManager
    
    @State private var selectedSpot: Int? = nil
    @State private var showFlowerSelection = false
    @State private var showGardenCompleteAlert = false
    @State private var selectedFlower: String? = nil
   // @State private var plantedFlowers: [Int: String] = [:]
    //@State private var flowerMinutes: [Int: Int] = [:]
    
    
    private var plantedFlowers: [Int: String] {
        gardenManager.plantedFlowers
    }

    private var flowerMinutes: [Int: Int] {
        gardenManager.flowerMinutes
    }
    
    private let flowerTypes: [String] = [
        "Tulip",
        "Daisy",
        "Lavender",
        "Cosmos",
        "Camellia",
        "Rose"
    ]
    
    private let tulipGrowthStages: [String] = [
        "Tulip_Seed",
        "Tulip_Sprout",
        "Tulip_Leaves",
        "Tulip_Bud",
        "Tulip_Bloom"
    ]
    
    private let plantingSpots: [(id: Int, x: CGFloat, y: CGFloat)] = [
        (1, 0.26, 0.55),  // Top Left
        (2, 0.75, 0.55),  // Top Right
        
        (3, 0.20, 0.65),  // Middle Left
        (4, 0.80, 0.65),  // Middle Right
        
        (5, 0.22, 0.77),  // Bottom Left
        (6, 0.80, 0.77)   // Bottom Right
    ]
    
    private func growthStage(for minutes: Int) -> String {
        switch minutes {
        case 30...:
            return "Bloom"

        case 15..<30:
            return "Bud"

        case 10..<15:
            return "Leaves"

        case 5..<10:
            return "Sprout"

        case 2..<5:
            return "Seed"

        default:
            return "NotPlanted"
        }
    }
    
   

    private func addMovementMinutes(
        _ minutes: Int,
        to spot: Int
    ) {
        gardenManager.addMovementMinutes(minutes, to: spot)
    }
    
   
    
   
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                
                Image("gardenBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
                
                
                Text("Choose a Spot to Bloom")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(BloomoveColors.darkGreen)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 70)
                    .padding(.vertical, 12)
                    .background(
                        Color(red: 1, green: 0.98, blue: 0.95)
                            .opacity(0.85)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.top, geometry.safeAreaInsets.top + 100)
    // Button
                
                
                //Button
                            ForEach(plantingSpots, id: \.id) { spot in
                                if let flower = gardenManager.plantedFlowers[spot.id] {

                                    let minutes = flowerMinutes[spot.id] ?? 2
                                    let stage = growthStage(for: minutes)

                                    let imageName = "\(flower)_\(stage)"
                                    
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 75, height: 85)
                                        .position(
                                            x: geometry.size.width * spot.x,
                                            y: geometry.size.height * spot.y - 15
                                        )
                                        .allowsHitTesting(false)
                                }
                                
                                Button {
                                    selectedSpot = spot.id
                                } label: {
                                    Ellipse()
                                        .stroke(
                                            selectedSpot == spot.id
                                            ? BloomoveColors.primaryPink
                                            : Color.clear,
                                            lineWidth: 3
                                        )
                                        .frame(width: 100, height: 45)
                                        .contentShape(Ellipse())
                                }
                                .position(
                                    x: geometry.size.width * spot.x,
                                    y: geometry.size.height * spot.y
                                )
                            }
                VStack {
                    Spacer()
#if DEBUG
Button("Test: Clear Spot 1") {
    gardenManager.plantedFlowers.removeValue(forKey: 1)
    gardenManager.flowerMinutes.removeValue(forKey: 1)
    gardenManager.saveGarden()
    selectedSpot = nil
}
.foregroundStyle(.red)
#endif
                    
#if DEBUG
Button {
    gardenManager.recordWorkout(
        id: UUID().uuidString,
        completedMinutes: 2
    )
} label: {
    Text("Test Complete 2 Min")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(BloomoveColors.darkGreen)
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
}
#endif
                    
#if DEBUG
Button {
    if let spot = selectedSpot {
        addMovementMinutes(3, to: spot)
    }
} label: {
    Text("Test +3 Minutes")
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(BloomoveColors.darkGreen)
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
}
.disabled(
    selectedSpot == nil ||
    plantedFlowers[selectedSpot ?? -1] == nil ||
    (flowerMinutes[selectedSpot ?? -1] ?? 2) >= 30
)
#endif
                    Button {
                        print("Plant Here button tapped")
                        showFlowerSelection = true
                    } label: {
                        Text("Plant Here")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                selectedSpot != nil &&
                                gardenManager.canPlantNewFlower &&
                                plantedFlowers[selectedSpot ?? -1] == nil
                                    ? BloomoveColors.primaryPink
                                    : Color.gray
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .disabled(
                        selectedSpot == nil ||
                        !gardenManager.canPlantNewFlower ||
                        plantedFlowers[selectedSpot ?? -1] != nil
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 60)
                    .zIndex(10)
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )

                    }
        
        .ignoresSafeArea()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    MyGardensView(gardenManager: gardenManager)
                } label: {
                    Label("My Gardens", systemImage: "leaf.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(BloomoveColors.darkGreen)
                }
            }
        }
        
        

        .onAppear {
        
         
        }

        .sheet(isPresented: $showFlowerSelection) {
            VStack(spacing: 20) {
                
                // Title
                Text("Choose Your Flower")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(BloomoveColors.darkGreen)
                
                // Description
                Text("Pick a flower to grow in your garden.")
                    .font(.system(size: 16))
                    .foregroundStyle(BloomoveColors.secondaryText)
                    .multilineTextAlignment(.center)
                
// Horizontal Flower Scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(flowerTypes, id: \.self) { flower in
                            
                            VStack(spacing: 8) {
                                
                                Image(flower)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 95, height: 85)
                                
                                Text(flower)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(BloomoveColors.darkGreen)
                                
                            }
                            .frame(width: 130, height: 120)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        selectedFlower == flower
                                        ? BloomoveColors.primaryPink
                                        : Color.clear,
                                        lineWidth: 3
                                    )
                            }
                            .onTapGesture {
                                selectedFlower = flower
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .frame(height: 140)
                
                
                
// Plant Button
                
                    Button {
                        guard let flower = selectedFlower,
                              let spot = selectedSpot else { return }

                        let planted = gardenManager.plantFlower(flower, at: spot)

                        guard planted else {
                            print("Planting not allowed")
                            return
                        }

                        print("Planted \(flower) in spot \(spot)")

                        showFlowerSelection = false
                        selectedFlower = nil
                        selectedSpot = nil

                    } label: {
                    Text("Plant My Seed")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            selectedSpot != nil &&
                            gardenManager.availableMinutes >= 2 &&
                            gardenManager.canPlantNewFlower &&
                            plantedFlowers[selectedSpot ?? -1] == nil
                                ? BloomoveColors.primaryPink
                                : Color.gray
                        )
                }
                    .disabled(
                        selectedSpot == nil ||
                        gardenManager.availableMinutes < 2 ||
                        !gardenManager.canPlantNewFlower ||
                        plantedFlowers[selectedSpot ?? -1] != nil
                    )
            }
// End VStack
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(BloomoveColors.background)
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)

        } // End Sheet
        
        .onChange(of: gardenManager.isGardenComplete) { _, isComplete in
            if isComplete {
                showGardenCompleteAlert = true
            }
        }
        
        .onAppear {
            if gardenManager.isGardenComplete {
                showGardenCompleteAlert = true
            }
        }
        .alert(
            "Your Garden is in Full Bloom! 🌷",
            isPresented: $showGardenCompleteAlert
        ) {
            Button("Create New Garden") {
                let created = gardenManager.createNewGarden()

                if created {
                    selectedSpot = nil
                    selectedFlower = nil
                    
                    print("Saved gardens: \(gardenManager.completedGardens.count)")
                }
            }

            Button("Keep My Garden", role: .cancel) {
                // Keep the completed garden as it is
            }
        } message: {
            Text(
                "You've grown six beautiful flowers! Start a new garden whenever you're ready. Your completed garden will be saved."
            )
        }

    } // End body

} // End TarfahGardenView

#Preview {
    TarfahGardenView(
        gardenManager: GardenProgressManager()
    )
}
