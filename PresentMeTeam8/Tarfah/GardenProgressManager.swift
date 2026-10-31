//
//  GardenProgressManager.swift
//  PresentMeTeam8
//
//  Created by Tarfah Alsaleh on 15/05/1448 AH.
//

import Foundation
import Combine



struct CompletedGarden: Identifiable, Codable {

    let id: UUID
    let completedAt: Date
    let flowers: [Int: String]
    let minutes: [Int: Int]

}
@MainActor
final class GardenProgressManager: ObservableObject {

    @Published var plantedFlowers: [Int: String] = [:]
    @Published var flowerMinutes: [Int: Int] = [:]
    @Published var availableMinutes: Int = 0
    @Published private(set) var totalActivityMinutes: Int = 0
    @Published private(set) var completedGardens: [CompletedGarden] = []
    private var recordedWorkoutIDs: Set<String> = []
    
    init() {
        loadGarden()
    }

    private func loadGarden() {

        // Load planted flowers
        if let data = UserDefaults.standard.data(
            forKey: "bloomovePlantedFlowers"
        ),
        let savedFlowers = try? JSONDecoder().decode(
            [Int: String].self,
            from: data
        ) {
            plantedFlowers = savedFlowers
        }

        // Load flower growth minutes
        if let data = UserDefaults.standard.data(
            forKey: "bloomoveFlowerMinutes"
        ),
        let savedMinutes = try? JSONDecoder().decode(
            [Int: Int].self,
            from: data
        ) {
            flowerMinutes = savedMinutes.mapValues { minutes in
                min(max(minutes, 2), 30)
            }
        }
        
        // Load previously recorded workout IDs
        let savedWorkoutIDs = UserDefaults.standard.stringArray(
            forKey: "bloomoveRecordedWorkoutIDs"
        ) ?? []

        recordedWorkoutIDs = Set(savedWorkoutIDs)
        
        availableMinutes = UserDefaults.standard.integer(
            forKey: "bloomoveAvailableMinutes"
        )
        
        // Load completed gardens
        if let data = UserDefaults.standard.data(
            forKey: "bloomoveCompletedGardens"
        ),
        let savedGardens = try? JSONDecoder().decode(
            [CompletedGarden].self,
            from: data
        ) {
            completedGardens = savedGardens
        }
        
        totalActivityMinutes = UserDefaults.standard.integer(
            forKey: "bloomoveTotalActivityMinutes"
        )
    }
    
    func saveGarden() {

        // Save planted flowers
        if let data = try? JSONEncoder().encode(plantedFlowers) {
            UserDefaults.standard.set(
                data,
                forKey: "bloomovePlantedFlowers"
            )
        }

        // Save flower growth minutes
        if let data = try? JSONEncoder().encode(flowerMinutes) {
            UserDefaults.standard.set(
                data,
                forKey: "bloomoveFlowerMinutes"
            )
        }
        
        UserDefaults.standard.set(
            availableMinutes,
            forKey: "bloomoveAvailableMinutes"
        )
        
        // Save completed gardens
        if let data = try? JSONEncoder().encode(completedGardens) {
            UserDefaults.standard.set(
                data,
                forKey: "bloomoveCompletedGardens"
            )
        }
        
        UserDefaults.standard.set(
            totalActivityMinutes,
            forKey: "bloomoveTotalActivityMinutes"
        )
    }
    
    func recordWorkout(
        id: String,
        completedMinutes: Int
    ) {
        guard !id.isEmpty, completedMinutes > 0 else {
            return
        }

        // Prevent duplicate workout records
        guard !recordedWorkoutIDs.contains(id) else {
            print("Workout already recorded — skipped")
            return
        }

        recordedWorkoutIDs.insert(id)
        
        // Add completed minutes to lifetime activity total
        totalActivityMinutes += completedMinutes
        
        print("Workout earned: \(completedMinutes) min")
        print("Total activity: \(totalActivityMinutes) min")

        // Find a flower that is still growing
        if let activeSpot = plantedFlowers.keys.first(where: {
            (flowerMinutes[$0] ?? 2) < 30
        }) {
            let currentMinutes = flowerMinutes[activeSpot] ?? 2
            let remainingMinutes = 30 - currentMinutes

            let minutesToAdd = min(completedMinutes, remainingMinutes)

            flowerMinutes[activeSpot] = currentMinutes + minutesToAdd

            // Keep any extra minutes for the next flower
            availableMinutes += completedMinutes - minutesToAdd

        } else {
            // No active flower: save all earned minutes
            availableMinutes += completedMinutes
        }

        // Save all changes
        saveGarden()

        UserDefaults.standard.set(
            Array(recordedWorkoutIDs),
            forKey: "bloomoveRecordedWorkoutIDs"
        )
    }
    
    
    func addMovementMinutes(_ minutes: Int, to spot: Int) {

        // Check that the spot contains a flower
        guard minutes > 0,
              plantedFlowers[spot] != nil else {
            return
        }

        // Get current growth minutes
        let currentMinutes = flowerMinutes[spot] ?? 2

        // Stop growth after 30 minutes
        guard currentMinutes < 30 else {
            return
        }

        // Update minutes without exceeding 30
        flowerMinutes[spot] = min(
            currentMinutes + minutes,
            30
        )

        // Save changes
        saveGarden()
    }
    
    var canPlantNewFlower: Bool {

        // Garden has only 6 planting spots
        guard plantedFlowers.count < 6 else {
            return false
        }

        // Require at least 2 earned minutes
        guard availableMinutes >= 2 else {
            return false
        }

        // All existing flowers must be fully grown
        return plantedFlowers.keys.allSatisfy { spot in
            (flowerMinutes[spot] ?? 2) >= 30
        }
    }
    
    func plantFlower(_ flower: String, at spot: Int) -> Bool {

        // Require at least 2 earned minutes
        guard availableMinutes >= 2 else {
            return false
        }

        // Check that the spot is empty
        guard plantedFlowers[spot] == nil else {
            return false
        }

        // Allow only one growing flower
        let hasGrowingFlower = plantedFlowers.keys.contains {
            (flowerMinutes[$0] ?? 2) < 30
        }

        guard !hasGrowingFlower else {
            return false
        }

        // Plant the flower
        plantedFlowers[spot] = flower

        // Use earned minutes for flower growth
        let usedMinutes = min(availableMinutes, 30)

        flowerMinutes[spot] = usedMinutes
        availableMinutes -= usedMinutes

        // Save the garden
        saveGarden()

        return true
    }
    
    var currentFlowerProgress: Int {
        if let activeSpot = plantedFlowers.keys.first(where: {
            (flowerMinutes[$0] ?? 2) < 30
        }) {
            return flowerMinutes[activeSpot] ?? 2
        }

        return plantedFlowers.isEmpty ? 0 : 30
    }
#if DEBUG
func resetTestGarden() {
    plantedFlowers = [:]
    flowerMinutes = [:]
    availableMinutes = 0
    recordedWorkoutIDs = []

    saveGarden()

    UserDefaults.standard.removeObject(
        forKey: "bloomoveRecordedWorkoutIDs"
    )
}
#endif
    
    var hasGrowingFlower: Bool {
        plantedFlowers.keys.contains { spot in
            (flowerMinutes[spot] ?? 2) < 30
        }
    }
    
    var isGardenComplete: Bool {

        // All 6 spots must contain flowers
        guard plantedFlowers.count == 6 else {
            return false
        }

        // Every flower must reach 30 minutes
        return plantedFlowers.keys.allSatisfy { spot in
            (flowerMinutes[spot] ?? 2) >= 30
        }
    }
    
    @discardableResult
    func createNewGarden() -> Bool {

        // Only allow creating a new garden when complete
        guard isGardenComplete else {
            return false
        }

        // Save a snapshot of the completed garden
        let finishedGarden = CompletedGarden(
            id: UUID(),
            completedAt: Date(),
            flowers: plantedFlowers,
            minutes: flowerMinutes
        )

        completedGardens.append(finishedGarden)

        // Start a new empty garden
        plantedFlowers = [:]
        flowerMinutes = [:]

        // Keep available minutes and workout history
        saveGarden()

        return true
    }
}
