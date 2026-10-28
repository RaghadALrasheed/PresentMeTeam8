import SwiftUI

struct ContentView: View {

    // Access the shared garden progress manager.
    @EnvironmentObject var gardenManager: GardenProgressManager

    var body: some View {

        // Launch the Home screen to test navigation and garden progress.
        HomePage()
    }
}

#Preview {
    ContentView()
        .environmentObject(GardenProgressManager())
}
