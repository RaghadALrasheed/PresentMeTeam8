//
//  EarlyCompletionView.swift
//  PresentMeTeam8
//
//  Created by Tarfah Alsaleh on 13/05/1448 AH.
//

import SwiftUI

struct EarlyCompletionView: View {
    
    @ObservedObject var gardenManager: GardenProgressManager
    
    let workoutSessionID: String
    
    let completedMinutes: Int
    let flowerProgressMinutes: Int
    
    var onViewGarden: () -> Void = {}
    var onBackHome: () -> Void = {}
    
    
    
    
    var workoutResult: (completed: Int, progress: Int) {
        (
            completed: completedMinutes,
            progress: flowerProgressMinutes
        )
    }
    
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
            
            
            VStack(spacing: 20) {
                
                Image("earlyWorkoutBud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                
                Text("You Did Your Best!")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(BloomoveColors.darkGreen)
                    .multilineTextAlignment(.center)
                
                
                VStack(spacing: 12) {
                    Text("You've Completed")
                        .font(.system(size: 18))
                        .foregroundStyle(BloomoveColors.secondaryText)
                    
                    Text("\(completedMinutes) Min")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(BloomoveColors.darkGreen)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(BloomoveColors.softGreen)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)
                
                
                Text(
                    gardenManager.hasGrowingFlower
                    ? "Your flower is growing! 🌱"
                    : gardenManager.availableMinutes >= 2
                    ? "Ready to plant your next flower! 🌸"
                    : flowerProgressMinutes >= 30
                    ? "Your flower has fully bloomed! 🌷"
                    : "Start growing your flower! 🌱"
                )
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(BloomoveColors.darkGreen)
                .multilineTextAlignment(.center)
                
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
                .multilineTextAlignment(.center)
                Spacer()
                    .frame(height: 36)
                Button {
                    onViewGarden()
                } label: {
                    
                    Text("View My Garden")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(BloomoveColors.primaryPink)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                
                .padding(.horizontal, 24)
                
                
                
                Button {
                    onBackHome()
                } label: {
                    Text("Back to Home")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(BloomoveColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .padding(.horizontal, 24)
                
            } // End VStack
            
        } // End ZStack
        
        // Save the minutes actually completed before ending the workout.
        // The session ID prevents recording the same workout twice.
        .onAppear {
            saveCompletedWorkout()
        }
        
    } // End body
    
    
}
    
    #Preview {
        EarlyCompletionView(
            gardenManager: GardenProgressManager(),
            workoutSessionID: "preview-early-workout-001",
            completedMinutes: 3,
            flowerProgressMinutes: 13
        )
    }

