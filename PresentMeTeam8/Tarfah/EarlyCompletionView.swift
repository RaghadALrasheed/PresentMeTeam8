//
//  EarlyCompletionView.swift
//  PresentMeTeam8
//
//  Created by Tarfah Alsaleh on 13/05/1448 AH.
//

import SwiftUI

struct EarlyCompletionView: View {
    
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
                
                
                Text("Your flower is growing! 🌱")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(BloomoveColors.darkGreen)
                    .multilineTextAlignment(.center)

                Text("Flower Growth: \(flowerProgressMinutes) / 30 min")
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
            }


                
            }

        }

    }


#Preview {
    EarlyCompletionView(
        completedMinutes: 3,
        flowerProgressMinutes: 13
    )
}
