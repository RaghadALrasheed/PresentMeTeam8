
import SwiftUI

// MARK: - Available Planting Minutes Card
// Displays saved minutes that are available for planting.

private struct GardenAvailableMinutesBar: View {

    let availableMinutes: Int

    private let plantingCost = 2

    private var canPlant: Bool {
        availableMinutes >= plantingCost
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 7) {

            // MARK: - Available Minutes

            HStack {

                Text("Available to Plant")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(BloomoveColors.darkGreen)

                Spacer()

                Text("\(availableMinutes) min")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(BloomoveColors.darkGreen)
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }

            // MARK: - Planting Availability Bar
            // This indicates whether the user can afford
            // the 2-minute cost of planting one seed.
            // It is not a 20 or 30-minute progress goal.

            GeometryReader { geometry in

                ZStack(alignment: .leading) {

                    Capsule()
                        .fill(
                            Color(
                                red: 231/255,
                                green: 238/255,
                                blue: 223/255
                            )
                        )

                    Capsule()
                        .fill(BloomoveColors.darkGreen)
                        .frame(
                            width: geometry.size.width *
                                min(
                                    max(
                                        CGFloat(availableMinutes) /
                                        CGFloat(plantingCost),
                                        0
                                    ),
                                    1
                                )
                        )
                }
            }
            .frame(height: 6)

            // MARK: - Planting Message

            Text(
                canPlant
                    ? "Ready to plant • 2 min per seed"
                    : "Move for 2 minutes to plant a new flower."
            )
            .font(.system(size: 10))
            .foregroundStyle(BloomoveColors.secondaryText)
        }
        .padding(10)
        .background(
            Color(
                red: 1,
                green: 0.98,
                blue: 0.95
            ),
            in: RoundedRectangle(cornerRadius: 22)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    BloomoveColors.darkGreen.opacity(0.12),
                    lineWidth: 1
                )
        }
        .shadow(
            color: .black.opacity(0.08),
            radius: 8,
            y: 3
        )
        .animation(
            .easeInOut(duration: 0.25),
            value: availableMinutes
        )
    }
}

// MARK: - Garden View

struct TarfahGardenView: View {
    
    @ObservedObject var gardenManager: GardenProgressManager
    
    // MARK: - Selection State
    
    @State private var selectedSpot: Int? = nil
    @State private var showFlowerSelection = false
    @State private var showGardenCompleteAlert = false
    @State private var selectedFlower: String? = nil
    @State private var showSavedGardens = false
    
    // MARK: - Saved Garden Data
    // Always use the existing GardenProgressManager.
    // Do not duplicate saved garden data.
    
    private var plantedFlowers: [Int: String] {
        gardenManager.plantedFlowers
    }
    
    private var flowerMinutes: [Int: Int] {
        gardenManager.flowerMinutes
    }
    
    // MARK: - Flower Types
    
    private let flowerTypes: [String] = [
        "Tulip",
        "Daisy",
        "Lavender",
        "Cosmos",
        "Camellia",
        "Rose"
    ]
    
    // MARK: - Original Tulip Growth Assets
    
    private let tulipGrowthStages: [String] = [
        "Tulip_Seed",
        "Tulip_Sprout",
        "Tulip_Leaves",
        "Tulip_Bud",
        "Tulip_Bloom"
    ]
    
    // MARK: - Garden Planting Spots
    // Preserve the six original positions.
    
    private let plantingSpots: [
        (id: Int, x: CGFloat, y: CGFloat)
    ] = [
        (1, 0.28, 0.52),
        (2, 0.77, 0.52),
        (3, 0.23, 0.63),
        (4, 0.80, 0.63),
        (5, 0.24, 0.75),
        (6, 0.81, 0.75)
    ]
    
    // MARK: - Growth Stage
    // Preserve existing flower growth thresholds.
    
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
    
    // MARK: - Add Movement Minutes
    // Keep existing garden progress behavior.
    
    private func addMovementMinutes(
        _ minutes: Int,
        to spot: Int
    ) {
        gardenManager.addMovementMinutes(
            minutes,
            to: spot
        )
    }
    
    // MARK: - Planting Availability
    
    private var canPlantAtSelectedSpot: Bool {
        
        guard let spot = selectedSpot else {
            return false
        }
        
        return gardenManager.canPlantNewFlower &&
        plantedFlowers[spot] == nil &&
        gardenManager.availableMinutes >= 2
    }
    
    // MARK: - Main Garden Screen
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .top) {
                
                
                
                // MARK: - Garden Header

                ZStack(alignment: .topTrailing) {

                    // MARK: - Garden Title
                    // Keep the title centered at its current height.

                    Text("Choose a Spot to Bloom")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(BloomoveColors.darkGreen)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                        .background(
                            BloomoveColors.background.opacity(0.92),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 85)

                    // MARK: - Saved Gardens Button
                    // Move the button above the title,
                    // to the upper-right cloud area.

                    Button {
                        showSavedGardens = true
                    } label: {

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(BloomoveColors.darkGreen)
                            .frame(width: 44, height: 44)
                            .background(
                                BloomoveColors.background.opacity(0.92),
                                in: Circle()
                            )
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("My Gardens")
                    .padding(.trailing, 16)
                    .padding(.top, 35)
                }
                .zIndex(20)


                    
                    // MARK: - Planting Spots
                    // Display saved flowers at their original locations.
                    
                    ForEach(
                        plantingSpots,
                        id: \.id
                    ) { spot in
                        
                        if let flower = plantedFlowers[spot.id] {
                            
                            let minutes = flowerMinutes[spot.id] ?? 2
                            let stage = growthStage(for: minutes)
                            let imageName = "\(flower)_\(stage)"
                            
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: 75,
                                    height: 85
                                )
                                .position(
                                    x: geometry.size.width * spot.x,
                                    y: geometry.size.height * spot.y - 15
                                )
                                .allowsHitTesting(false)
                        }
                        
                        // MARK: - Spot Selection
                        
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
                                .frame(
                                    width: 80,
                                    height: 35
                                )
                                .contentShape(Ellipse())
                        }
                        .buttonStyle(.plain)
                        .position(
                            x: geometry.size.width * spot.x - 10,
                            y: geometry.size.height * spot.y + 20
                        )
                    }
                    
                    // MARK: - Bottom Garden Controls
                    // Keep the planting balance above Plant Here.
                    
                    VStack(spacing: 12) {
                        
                        Spacer()
                        
                        // MARK: - Development Test Controls
                        // Keep the original debug tools.
                        // These controls appear only in DEBUG builds.
                        

                        
                        // MARK: - Available Minutes Card
                        // Visible when the garden first opens.
                        // Hidden while choosing a flower.
                        // Restored with updated minutes after planting.
                        
                        if !showFlowerSelection {
                            
                            GardenAvailableMinutesBar(
                                availableMinutes:
                                    gardenManager.availableMinutes
                            )
                            .padding(.horizontal, 28)
                            .transition(
                                .move(edge: .bottom)
                                .combined(with: .opacity)
                            )
                        }
                        
                        // MARK: - Plant Here Button
                        
                        Button {
                            
                            guard canPlantAtSelectedSpot else {
                                return
                            }
                            
                            selectedFlower = nil
                            
                            withAnimation(
                                .easeInOut(duration: 0.25)
                            ) {
                                showFlowerSelection = true
                            }
                            
                        } label: {
                            
                            Text("Plant Here")
                                .font(
                                    .system(
                                        size: 20,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    canPlantAtSelectedSpot
                                    ? BloomoveColors.primaryPink
                                    : Color.gray,
                                    in: RoundedRectangle(
                                        cornerRadius: 18
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(!canPlantAtSelectedSpot)
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 28)
                    .zIndex(10)
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
            
            // MARK: - Full Screen Garden Background
            // Place the image behind the whole screen.
            // Extend it into the top and bottom safe areas.
            // Do not change the planting-spot coordinates.
            
            .background {
                
                Image("gardenBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(edges: .all)
            }
            
            // MARK: - Navigation
            // The custom My Gardens button is in the header.
            // Hide the system navigation bar on this garden screen.
            
            .toolbar(.hidden, for: .navigationBar)
            // MARK: - Saved Gardens Sheet
            
            .sheet(isPresented: $showSavedGardens) {
                
                NavigationStack {
                    
                    MyGardensView(
                        gardenManager: gardenManager
                    )
                }
            }
            // MARK: - Flower Selection Sheet
            
            .sheet(
                isPresented: $showFlowerSelection
            ) {
                
                VStack(spacing: 20) {
                    
                    // MARK: - Sheet Title
                    
                    Text("Choose Your Flower")
                        .font(
                            .system(
                                size: 24,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            BloomoveColors.darkGreen
                        )
                    
                    // MARK: - Sheet Description
                    
                    Text(
                        "Pick a flower to grow in your garden."
                    )
                    .font(.system(size: 16))
                    .foregroundStyle(
                        BloomoveColors.secondaryText
                    )
                    .multilineTextAlignment(.center)
                    
                    // MARK: - Horizontal Flower Selection
                    
                    ScrollView(
                        .horizontal,
                        showsIndicators: false
                    ) {
                        
                        HStack(spacing: 12) {
                            
                            ForEach(
                                flowerTypes,
                                id: \.self
                            ) { flower in
                                
                                VStack(spacing: 8) {
                                    
                                    Image(flower)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(
                                            width: 95,
                                            height: 85
                                        )
                                    
                                    Text(flower)
                                        .font(
                                            .system(
                                                size: 16,
                                                weight: .semibold
                                            )
                                        )
                                        .foregroundStyle(
                                            BloomoveColors.darkGreen
                                        )
                                }
                                .frame(
                                    width: 130,
                                    height: 120
                                )
                                .background(.white)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 16
                                    )
                                )
                                .overlay {
                                    
                                    RoundedRectangle(
                                        cornerRadius: 16
                                    )
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
                    
                    // MARK: - Plant My Seed Button
                    // GardenProgressManager handles the cost.
                    // Never subtract minutes again in this view.
                    
                    Button {
                        
                        guard
                            let flower = selectedFlower,
                            let spot = selectedSpot
                                else {
                            return
                        }
                        
                        let planted = gardenManager.plantFlower(
                            flower,
                            at: spot
                        )
                        
                        guard planted else {
                            
                            print("Planting not allowed")
                            return
                        }
                        
                        print(
                            "Planted \(flower) in spot \(spot)"
                        )
                        
                        // Dismiss the flower picker.
                        // The available-minutes card automatically
                        // shows the new balance.
                        
                        showFlowerSelection = false
                        selectedFlower = nil
                        selectedSpot = nil
                        
                    } label: {
                        
                        Text("Plant My Seed")
                            .font(
                                .system(
                                    size: 16,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                selectedFlower != nil &&
                                canPlantAtSelectedSpot
                                ? BloomoveColors.primaryPink
                                : Color.gray,
                                in: RoundedRectangle(
                                    cornerRadius: 12
                                )
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(
                        selectedFlower == nil ||
                        !canPlantAtSelectedSpot
                    )
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(BloomoveColors.background)
                .presentationDetents([
                    .height(300)
                ])
                .presentationDragIndicator(.visible)
            }
            
            // MARK: - Garden Completion Detection
            
            .onChange(
                of: gardenManager.isGardenComplete
            ) { _, isComplete in
                
                if isComplete {
                    
                    showGardenCompleteAlert = true
                }
            }
            
            .onAppear {
                
                if gardenManager.isGardenComplete {
                    
                    showGardenCompleteAlert = true
                }
            }
            
            // MARK: - Garden Completion Alert
            
            .alert(
                "Your Garden is in Full Bloom! 🌷",
                isPresented: $showGardenCompleteAlert
            ) {
                
                Button("Create New Garden") {
                    
                    let created =
                    gardenManager.createNewGarden()
                    
                    if created {
                        
                        selectedSpot = nil
                        selectedFlower = nil
                        
                        print(
                            "Saved gardens: \(gardenManager.completedGardens.count)"
                        )
                    }
                }
                
                Button(
                    "Keep My Garden",
                    role: .cancel
                ) {
                    
                    // Keep the completed garden unchanged.
                }
                
            } message: {
                
                Text(
                    "You've grown six beautiful flowers! Start a new garden whenever you're ready. Your completed garden will be saved."
                )
            }
        }
    }

    
    // MARK: - Preview
    
    #Preview {
        NavigationStack {
            TarfahGardenView(
                gardenManager: GardenProgressManager()
            )
        }
    }

