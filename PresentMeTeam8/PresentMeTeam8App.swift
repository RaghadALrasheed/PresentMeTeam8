
import SwiftUI

@main
struct PresentMeTeam8App: App {

    // Share the same garden progress across all app screens.
    @StateObject private var gardenManager = GardenProgressManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gardenManager)
        }
    }
}
