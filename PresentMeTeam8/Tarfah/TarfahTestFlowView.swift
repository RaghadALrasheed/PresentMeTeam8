import SwiftUI

struct TarfahTestFlowView: View {

    @ObservedObject var gardenManager: GardenProgressManager

    @State private var path: [TestPage] = []
    @State private var workoutSessionID = UUID().uuidString
    @State private var earlyCompletedMinutes = 3
    @State private var showGardenSheet = false

    // Pages used for testing navigation
    private enum TestPage: Hashable {
        case completion
        case earlyCompletion
        case endConfirmation
        case garden
    }

    var body: some View {
        NavigationStack(path: $path) {

            VStack(spacing: 20) {

                Text("Bloomove Test Flow")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(BloomoveColors.darkGreen)

                Text("Test your workout completion and garden.")
                    .foregroundStyle(BloomoveColors.secondaryText)
                
                Button {
                    showGardenSheet = true
                } label: {
                    GardenPreviewView(gardenManager: gardenManager)
                        .frame(height: 320)
                        .padding(.horizontal, 24)
                }
                .buttonStyle(.plain)
                
                
                VStack(spacing: 8) {
                    Text("Total Activity Minutes")
                        .font(.system(size: 16))
                        .foregroundStyle(BloomoveColors.secondaryText)

                    Text("\(gardenManager.totalActivityMinutes) min")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(BloomoveColors.darkGreen)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(BloomoveColors.softGreen)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal, 24)
                
                
                
              
                
                
                // Full Workout Test
                Button {
                    workoutSessionID = UUID().uuidString

                    gardenManager.recordWorkout(
                        id: workoutSessionID,
                        completedMinutes: 5
                    )

                    path.append(.completion)

                } label: {
                    Text("Complete 5 Min Workout")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding()
                        .background(BloomoveColors.primaryPink)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Early Completion Test
                Button {
                    workoutSessionID = UUID().uuidString
                    earlyCompletedMinutes = 3

                    gardenManager.recordWorkout(
                        id: workoutSessionID,
                        completedMinutes: 3
                    )

                    path.append(.earlyCompletion)

                } label: {
                    Text("End Workout Early - 3 Min")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding()
                        .background(BloomoveColors.darkGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // End Workout Confirmation Test
                Button {
                    workoutSessionID = UUID().uuidString
                    earlyCompletedMinutes = 6

                    path.append(.endConfirmation)

                } label: {
                    Text("Test End Workout Confirmation")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding()
                        .background(BloomoveColors.primaryPink)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
             
            }
            
            
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BloomoveColors.background)
            
            .sheet(isPresented: $showGardenSheet) {
                TarfahGardenView(gardenManager: gardenManager)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }

            .navigationDestination(for: TestPage.self) { page in

                switch page {

                case .completion:
                    CompletionView(
                        gardenManager: gardenManager,
                        workoutSessionID: workoutSessionID,
                        completedMinutes: 5,
                        flowerProgressMinutes: gardenManager.currentFlowerProgress,
                        onViewGarden: {
                            path.append(.garden)
                        },
                        onBackHome: {
                            path.removeAll()
                        }
                    )

                case .earlyCompletion:
                    EarlyCompletionView(
                        gardenManager: gardenManager,
                        workoutSessionID: workoutSessionID,
                        completedMinutes: earlyCompletedMinutes,
                        flowerProgressMinutes: gardenManager.currentFlowerProgress,
                        onViewGarden: {
                            path.append(.garden)
                        },
                        onBackHome: {
                            path.removeAll()
                        }
                    )

                case .endConfirmation:
                    EndWorkoutConfirmationView(
                        totalMinutes: 10,
                        completedMinutes: 6,

                        onKeepExercising: {
                            path.removeLast()
                        },

                        onEndWorkout: {
                            gardenManager.recordWorkout(
                                id: workoutSessionID,
                                completedMinutes: 6
                            )
                            

                            earlyCompletedMinutes = 6
                            path.append(.earlyCompletion)
                        }
                    )

                case .garden:
                    TarfahGardenView(
                        gardenManager: gardenManager
                    )
                }
            }
        }
    }
}

#Preview {
    TarfahTestFlowView(
        gardenManager: GardenProgressManager()
    )
}
