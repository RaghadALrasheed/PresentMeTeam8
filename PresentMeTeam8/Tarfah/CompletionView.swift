//
//  CompletionView.swift
//  PresentMeTeam8
//
//  Created by Tarfah Alsaleh on 11/05/1448 AH.
//



import SwiftUI

struct CompletionView: View {
    @ObservedObject var gardenManager: GardenProgressManager
    let workoutSessionID: String
    let completedMinutes: Int
    let flowerProgressMinutes: Int
    
    let onViewGarden: () -> Void
    let onBackHome: () -> Void
  
    private func saveCompletedWorkout() {
        gardenManager.recordWorkout(
            id: workoutSessionID,
            completedMinutes: completedMinutes
        )
    }
    
    var body: some View {
        ZStack {
            BloomoveColors.background
                .ignoresSafeArea()
    // Image
            VStack(spacing: 24) {
                Image("completionFlower")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280)
                
   // Great job
                Text("Well done!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(BloomoveColors.darkGreen)

// Green Card
                VStack(spacing: 12) {
                    Text("You completed")
                        .font(.system(size: 18))
                        .foregroundStyle(BloomoveColors.secondaryText)

                    Text("\(completedMinutes) Min")                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(BloomoveColors.darkGreen)

                    Text("of movement")
                        .font(.system(size: 18))
                        .foregroundStyle(BloomoveColors.secondaryText)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(BloomoveColors.softGreen)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)
                
                
                VStack(spacing: 8) {
                    Text(
                        gardenManager.hasGrowingFlower
                            ? "Your flower is growing! 🌱"
                            : gardenManager.availableMinutes >= 2
                                ? "Ready to plant your next flower! 🌸"
                                : flowerProgressMinutes >= 30
                                    ? "Your flower has fully bloomed! 🌷"
                                    : "Start growing your flower! 🌱"
                    )

                    Text(
                        gardenManager.hasGrowingFlower
                            ? "Flower Growth: \(flowerProgressMinutes) / 30 min"
                            : gardenManager.availableMinutes >= 2
                                ? "Available Minutes: \(gardenManager.availableMinutes) min"
                                : flowerProgressMinutes >= 30
                                    ? "Flower Growth: 30 / 30 min"
                                    : "Available Minutes: \(gardenManager.availableMinutes) min"
                    )
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(BloomoveColors.darkGreen)
                }
                .multilineTextAlignment(.center)
                
                
                Spacer(minLength: 20)
            
    //Buttom
                
                Button {
                    onViewGarden()
                } label: {                    Text("View My Garden")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(BloomoveColors.primaryPink)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal, 20)
//Second Buttom
                Button {
                    onBackHome()
                } label: {
                    Text("Return home")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(BloomoveColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .padding(.horizontal, 20)

            }
            .padding(.top, 40)
            .padding(.bottom, 20)
        }
        
        // Save the completed workout when the completion screen appears.
        // The session ID prevents the same workout from being counted twice.
        .onAppear {
            saveCompletedWorkout()
        }
    }
}
#Preview {
    CompletionView(
        gardenManager: GardenProgressManager(),
        workoutSessionID: "preview-workout-001",
        completedMinutes: 10,
        flowerProgressMinutes: 22,
        onViewGarden: {},
        onBackHome: {}
    )
}
