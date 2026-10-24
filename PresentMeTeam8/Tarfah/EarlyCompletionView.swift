//
//  EarlyCompletionView.swift
//  PresentMeTeam8
//
//  Created by Tarfah Alsaleh on 13/05/1448 AH.
//

import SwiftUI

struct EarlyCompletionView: View {
    
    let completedMinutes: Int
    
    var onPlantFlower: () -> Void = {}
    var onBackHome: () -> Void = {}
    
    var earnedFlowerMinutes: Int {
        if completedMinutes >= 30 {
            return 30
        } else if completedMinutes >= 15 {
            return 15
        } else if completedMinutes >= 10 {
            return 10
        } else if completedMinutes >= 5 {
            return 5
        } else if completedMinutes >= 2 {
            return 2
        } else {
            return 0
        }
    }

    @State private var isPlanting = false
    
    
    var workoutResult: (completed: Int, flower: Int) {
        (
            completed: completedMinutes,
            flower: earnedFlowerMinutes
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
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(BloomoveColors.darkGreen)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(BloomoveColors.softGreen)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 24)
                
                
                if earnedFlowerMinutes > 0 {
                    Text("You've earned a \(earnedFlowerMinutes)-minute flower!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(BloomoveColors.darkGreen)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Every minute counts. Keep blooming!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(BloomoveColors.secondaryText)
                        .multilineTextAlignment(.center)
                    }

                Spacer(minLength: 20)
                 if earnedFlowerMinutes > 0 {
                   
                    
                     Button {
                         guard !isPlanting else { return }

                         isPlanting = true
                         onPlantFlower()
                     } label: {

                         Text("Plant Your Flower")

                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(BloomoveColors.primaryPink)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
         
                     .disabled(isPlanting)
                    .padding(.horizontal, 24)
                }


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
    EarlyCompletionView(completedMinutes: 13)
}
