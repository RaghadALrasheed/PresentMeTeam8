import SwiftUI

@main
struct PresentMeTeam8App: App {

    @StateObject private var gardenManager = GardenProgressManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gardenManager)
        }
    }
}
